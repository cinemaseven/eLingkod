import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:elingkod/common_style/colors_extension.dart';


class CameraCapturePage extends StatefulWidget {
  final Function(File, Map<String, String>, String) onCapture;
  final Map<String, dynamic> profileData;

  const CameraCapturePage({
    super.key,
    required this.onCapture,
    required this.profileData,
  });

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  bool _isProcessing = false;

  bool _isGoodFrame = false;
  int _consecutiveGoodFrames = 0;
  final int _requiredGoodFrames = 5;
  File? _lastSavedFile;

  Map<String, String> _extractedFields = {};
  String _detectedType = 'none';

  late final TextRecognizer _textRecognizer;
  final int frameDelayMs = 350;

  DateTime? _startTime;
  bool _isWrongIdTimeout = false;
  final int _timeoutSeconds = 8;

  late final String _captureTarget;
  late final bool _isPwdBackCapture;

  String _lastDetectedSeniorId = '';
  String _lastDetectedPwdId = '';

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    _captureTarget = widget.profileData['capture_target'] ?? 'none';
    _isPwdBackCapture = _captureTarget == 'pwdBack';

    _initCamera();
    _startTime = DateTime.now();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('No camera found')));
        }
        return;
      }

      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller?.initialize();
      if (!mounted) return;

      if (_controller != null && _controller!.value.isInitialized) {
        setState(() => _isCameraReady = true);
        _startImageStream();
      } else {
        debugPrint('Camera controller failed to initialize.');
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  //detect ID types
  String _detectIdType(String text) {
    final normalized = text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\s]'), '');

    // PWD!!!
    if (_captureTarget == 'pwdFront' && (normalized.contains('PWD') ||
        normalized.contains('PERSON WITH DISABILITY') ||
        normalized.contains('DISABILITY'))) {
      return 'pwd';
    }

    // SENIOR!!!
    if (_captureTarget == 'senior' && (normalized.contains('SENIOR') ||
        normalized.contains('SEN10R') ||
        normalized.contains('CITIZEN') ||
        normalized.contains('OSCA') ||
        normalized.contains('OFFICE OF THE SENIOR CITIZEN AFFAIRS'))) {
      return 'senior';
    }

    // VALID!!!
    if (_captureTarget == 'validId') {
      if (normalized.contains('POSTAL IDENTIFICATION CARD') || normalized.contains('POSTAL') || normalized.contains('PHLPOST')) {
        return 'postal_id';
      }
      if (normalized.contains('PROFESSIONAL IDENTIFICATION') || normalized.contains('PROFESSIONAL')) {
        return 'professional';
      }
      if (normalized.contains('DRIVER\'S LICENSE') || normalized.contains('DRIVER LICENSE') || normalized.contains('DRIVER') || normalized.contains('DRIVER\'S')) {
        return 'driver_license';
      }
      if (normalized.contains('PAMBANSANG PAGKAKAKILANLAN') || normalized.contains('PHILIPPINE IDENTIFICATION CARD') || normalized.contains('PHILSYS')) {
        return 'national_id';
      }
      if (normalized.contains('PASSPORT') || normalized.contains('PASAPORTE')) {
        return 'passport';
      }
    }

    return 'none';
  }

  // extract senior citizen ID no
  Map<String, String> extractSeniorIdFields(String ocrText) {
    String? idNum;

    final lines = ocrText
        .split('\n')
        .map((l) => l.trim().toUpperCase())
        .where((l) => l.isNotEmpty)
        .toList();

    final searchScope = min(6, lines.length);

    for (int i = 0; i < searchScope; i++) {
      final line = lines[i];
      final labeledMatch = RegExp(
          r'(SCN|ID|NO|NUMBER|OSCA|TIN|SENIOR\s*ID|SENIOR\s*NO)[\s#:]*([0-9\-\/]{5,25})')
          .firstMatch(line);

      if (labeledMatch != null) {
        idNum = labeledMatch.group(2)?.trim();
        break;
      }
    }

    if (idNum == null || idNum.length < 5) {
      idNum = null;

      for (int i = 0; i < searchScope; i++) {
        final currentLine = lines[i];

        final numMatch = RegExp(r'^([0-9\-\/]{5,25})$').firstMatch(currentLine);

        if (numMatch != null) {
          final candidate = numMatch.group(1)!;

          //exclude obvious dates
          if (RegExp(r'^\d{1,2}[\-\/]\d{1,2}[\-\/]\d{2,4}$')
              .hasMatch(candidate) ||
              RegExp(r'^(?:19|20)\d{2}$').hasMatch(candidate)) {
            continue;
          }

          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            if (nextLine.contains('SCN') ||
                nextLine.contains('ID NO') ||
                nextLine.contains('NUMBER') ||
                nextLine.contains('OSCA') ||
                nextLine.contains('SENIOR')) {
              idNum = candidate;
              break;
            }
          }
        }
      }
    }

    // cleanup and validation
    if (idNum != null) {
      idNum = idNum.replaceAll(RegExp(r'[^0-9\-\/]'), '').trim();
      if (idNum.length < 5) idNum = null;
    }

    return {
      'senior_id_number': idNum ?? '',
    };
  }

  // extract PWD ID fields
  Map<String, String> extractPwdIdFields(String ocrText) {
    final lines = ocrText.split('\n');
    String? pwdIdNum;

    for (var line in lines) {
      final normalized = line.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      if (normalized.contains('PWD') || normalized.contains('IDNO') || normalized.contains('PWDNO')) {
        final match = RegExp(r'([0-9\-\/]{4,19})').firstMatch(line);
        if (match != null) {
          pwdIdNum = match.group(0);
          break;
        }
      }
    }

    // final cleanup
    if (pwdIdNum != null) {
      pwdIdNum = pwdIdNum.replaceAll(RegExp(r'[^0-9\-\/]'), '').trim();
      if (pwdIdNum.length < 4 || pwdIdNum.length > 19) {
        pwdIdNum = null;
      }
    }

    return {
      'pwd_id_number': pwdIdNum ?? '',
    };
  }

  //camera stream & processing
  void _startImageStream() {
    if (_controller == null || !_controller!.value.isInitialized || _controller!.value.isStreamingImages) {
      debugPrint('Stream not starting: Controller is null, not initialized, or already streaming.');
      return;
    }

    _controller!.startImageStream((CameraImage image) async {
      if (_isProcessing || _controller == null || !_controller!.value.isInitialized) return;

      _isProcessing = true;

      try {
        final elapsed = DateTime.now().difference(_startTime!).inSeconds;
        final bool isTimeout = elapsed > _timeoutSeconds;

        if (image.planes.length < 3) {
          debugPrint('Error: CameraImage does not have enough planes. Skipping frame.');
          return;
        }

        final file = await _convertCameraImageToFile(image);
        final bytes = await file.readAsBytes();
        final qualityOk = await _isFrameQualityGood(bytes);

        if (qualityOk) {
          String detected = 'none';
          Map<String, String> extracted = {};
          bool shouldAutoCapture = false;

          if (_isPwdBackCapture) {
            detected = 'pwd_back_frame';
            extracted = {};
            shouldAutoCapture = true;
          } else {
            // OCR for Senior, PWD Front, and Valid ID
            final recognizedText = await _runTextRecognition(file);
            detected = _detectIdType(recognizedText);

            if (_captureTarget == 'validId') {
              // valid ID - only detect type
              if (detected != 'none') {
                shouldAutoCapture = true;
                extracted = {};
              }
            } else if (detected == 'senior') {
              extracted = extractSeniorIdFields(recognizedText);

              final current = extracted['senior_id_number'] ?? '';
              if (current.isNotEmpty) {
                _lastDetectedSeniorId = current;
              } else if (_lastDetectedSeniorId.isNotEmpty) {
                extracted['senior_id_number'] = _lastDetectedSeniorId;
              }

              shouldAutoCapture = true;
            } else if (detected == 'pwd') {
              extracted = extractPwdIdFields(recognizedText);

              final current = extracted['pwd_id_number'] ?? '';
              if (current.isNotEmpty) {
                _lastDetectedPwdId = current;
              } else if (_lastDetectedPwdId.isNotEmpty) {
                extracted['pwd_id_number'] = _lastDetectedPwdId;
              }

              if (extracted['pwd_id_number'] != null && extracted['pwd_id_number']!.isNotEmpty) {
                shouldAutoCapture = true;
              } else {
                shouldAutoCapture = false;
              }
            }
          }

          final publicDetectedType = detected == 'pwd_back_frame' ? 'pwd' : detected;

          if (mounted) {
            setState(() {
              _isGoodFrame = true;
              _detectedType = publicDetectedType;
            });

            if (_detectedType != 'none') {
              // deletes old saved files (para d dumodoble sa supabase)
              if (_lastSavedFile != null && await _lastSavedFile!.exists()) {
                try {
                  await _lastSavedFile!.delete();
                  debugPrint('Deleted previous capture: ${_lastSavedFile!.path}');
                } catch (e) {
                  debugPrint('Could not delete previous file: $e');
                }
              }

              _isWrongIdTimeout = false;
              _consecutiveGoodFrames++;
              _lastSavedFile = file;
              _extractedFields = extracted;
            } else if (isTimeout) {
              setState(() {
                _isWrongIdTimeout = true;
                _consecutiveGoodFrames = 0;
                _extractedFields = {};
                _lastDetectedPwdId = '';
                _lastDetectedSeniorId = '';
              });
            } else {
              setState(() {
                _consecutiveGoodFrames = 0;
                _extractedFields = {};
              });
            }
          }

          if (_detectedType != 'none') {
            _startTime = DateTime.now();
            _isWrongIdTimeout = false;
          }

          // validator for auto capture (ndi nag aauto pag malabo or has too much glare)
          if (_consecutiveGoodFrames >= _requiredGoodFrames &&
              _lastSavedFile != null &&
              _detectedType != 'none') {

            final isPwdFront = _captureTarget == 'pwdFront';
            if (isPwdFront && _detectedType == 'pwd' && !shouldAutoCapture) {
              if (mounted) setState(() => _consecutiveGoodFrames = 0);
            } else {
              await _controller?.stopImageStream();
              if (!mounted) return;

              widget.onCapture(_lastSavedFile!, _extractedFields, _detectedType);

              if (mounted) Navigator.pop(context);
            }
          }
        } else {

          if (mounted) {
            setState(() {
              _isGoodFrame = false;
              _consecutiveGoodFrames = 0;
              _detectedType = 'none';
              _extractedFields = {};
              _lastDetectedPwdId = '';
              _lastDetectedSeniorId = '';
              if (isTimeout && !_isWrongIdTimeout) {
                _isWrongIdTimeout = true;
              }
            });
          }
        }
      } catch (e) {
        debugPrint('Stream processing error: $e');
      } finally {
        await Future.delayed(Duration(milliseconds: frameDelayMs));
        _isProcessing = false;
      }
    });
  }


  // conversion | quality | OCR
  Future<File> _convertCameraImageToFile(CameraImage image) async {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final img = img_pkg.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yp = yPlane.bytes[y * yPlane.bytesPerRow + x];
        // Use safe access for bytesPerPixel
        final bytesPerPixel = uPlane.bytesPerPixel ?? 1;
        final uvIndex =
            (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2) * bytesPerPixel;
        final up = uPlane.bytes[uvIndex];
        final vp = vPlane.bytes[uvIndex];

        // Convert YUV -> RGB approximation
        int r = (yp + 1.402 * (vp - 128)).round().clamp(0, 255);
        int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128))
            .round()
            .clamp(0, 255);
        int b = (yp + 1.772 * (up - 128)).round().clamp(0, 255);

        img.setPixel(x, y, img_pkg.ColorInt8.rgb(r, g, b));
      }
    }

    final jpg = img_pkg.encodeJpg(img, quality: 85);
    final tmpDir = await getTemporaryDirectory();
    final path =
        '${tmpDir.path}/frame_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(jpg);
    return file;
  }

  Future<bool> _isFrameQualityGood(Uint8List jpegBytes) async {
    try {
      final image = img_pkg.decodeImage(jpegBytes);
      if (image == null) return false;
      final gray = img_pkg.grayscale(image);

      double mean = 0;
      final vals = <double>[];

      for (int y = 1; y < gray.height - 1; y += 2) {
        for (int x = 1; x < gray.width - 1; x += 2) {
          final center = gray.getPixel(x, y).r;
          final left = gray.getPixel(x - 1, y).r;
          final right = gray.getPixel(x + 1, y).r;
          final top = gray.getPixel(x, y - 1).r;
          final bottom = gray.getPixel(x, y + 1).r;

          final lap = (left + right + top + bottom) - (4 * center);
          vals.add(lap.abs().toDouble());
          mean += lap.abs();
        }
      }

      if (vals.isEmpty) return false;
      mean = mean / vals.length;
      double variance = 0;
      for (var v in vals) {
        variance += pow(v - mean, 2) as double;
      }
      variance = variance / vals.length;

      // blur check
      if (variance < 40.0) return false;

      // overexposure/brightness check
      int bright = 0;
      int sampled = 0;
      for (int y = 0; y < gray.height; y += 6) {
        for (int x = 0; x < gray.width; x += 6) {
          sampled++;
          final px = gray.getPixel(x, y).r;
          if (px > 245) bright++;
        }
      }

      if (bright / max(1, sampled) > 0.08) return false;

      return true;
    } catch (e) {
      debugPrint('Quality check error: $e');
      return false;
    }
  }

  Future<String> _runTextRecognition(File file) async {
    final input = InputImage.fromFile(file);
    final result = await _textRecognizer.processImage(input);
    return result.text;
  }

  Future<File?> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    try {
      final xfile = await _controller!.takePicture();
      return File(xfile.path);
    } catch (e) {
      debugPrint('takePicture error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }


  //converts detected type for display
  String _typeToDisplay(String detectedType) {
    switch (detectedType) {
      case 'senior':
        return 'Senior Citizen ID';
      case 'pwd':
        return 'PWD ID (Front)';
      case 'pwd_back_frame':
        return 'PWD ID (Back)';
      case 'professional':
        return 'Professional ID';
      case 'driver_license':
        return 'Driver\'s License';
      case 'national_id':
        return 'National ID';
      case 'passport':
        return 'Passport';
      case 'postal_id':
        return 'Postal ID';
      default:
        return 'Unknown/None';
    }
  }

  Widget _buildStatusRows() {
    // determines the ID number to display
    final idKey = _detectedType == 'senior' ? 'senior_id_number' : 'pwd_id_number';
    final idNumber = (_captureTarget != 'validId' && _captureTarget != 'pwdBack')
        ? (_extractedFields[idKey] ?? 'N/A')
        : 'N/A (Type Check Only)';

    final idNumberColor = idNumber.contains('N/A') ? Colors.grey : Colors.greenAccent;

    // status messages
    String statusMessage;
    Color statusColor;

    final bool isPwdFrontCapture = _captureTarget == 'pwdFront';
    final bool isIdTypeDetected = _detectedType != 'none';

    final bool pwdIdExtracted = isPwdFrontCapture && (_extractedFields['pwd_id_number']?.isNotEmpty ?? false);

    if (_isPwdBackCapture) {
      if (_consecutiveGoodFrames >= _requiredGoodFrames) {
        statusMessage = "Auto-Capturing PWD Back ID.";
        statusColor = Colors.lightGreenAccent;
      } else {
        statusMessage = "Align PWD Back ID. Auto-capture pending.";
        statusColor = Colors.cyanAccent;
      }
    } else if (_captureTarget == 'validId') {
      final type = _typeToDisplay(_detectedType);
      if (_detectedType != 'none' && _consecutiveGoodFrames >= _requiredGoodFrames) {
        statusMessage = "$type Detected! Auto-Capturing...";
        statusColor = Colors.lightGreenAccent;
      } else if (_detectedType != 'none' && _consecutiveGoodFrames > 0) {
        statusMessage = "Detected ID Type: $type. Keep steady.";
        statusColor = Colors.greenAccent;
      } else if (_detectedType != 'none') {
        statusMessage = "Detected ID Type: $type. Poor quality/alignment.";
        statusColor = Colors.orangeAccent;
      } else {
        statusMessage = "Align a Valid ID. Searching for keywords...";
        statusColor = Colors.cyanAccent;
      }

    } else if (isPwdFrontCapture) {
      // status messages for pwd
      if (_detectedType != 'pwd') {
        statusMessage = "Wrong ID Type Detected. Please use PWD Front ID.";
        statusColor = Colors.redAccent;
      } else if (pwdIdExtracted && _consecutiveGoodFrames >= _requiredGoodFrames) {
        statusMessage = "PWD ID Detected! Auto-Capturing...";
        statusColor = Colors.lightGreenAccent;
      } else {
        statusMessage = "PWD Card Detected. Keep steady.";
        statusColor = Colors.greenAccent;
      }

    } else if (_captureTarget == 'senior') {
      // status messages for senior
      if (_detectedType != 'senior') {
        statusMessage = "Wrong ID Type Detected. Please use Senior Citizen ID.";
        statusColor = Colors.redAccent;
      } else if (_consecutiveGoodFrames >= _requiredGoodFrames) {
        statusMessage = "Senior ID Detected! Auto-Capturing...";
        statusColor = Colors.lightGreenAccent;
      } else {
        statusMessage = "Senior Citizen Card Detected. Keep steady.";
        statusColor = Colors.greenAccent;
      }

    } else if (_isWrongIdTimeout) {
      if (_captureTarget == 'validId') {
        statusMessage =
        "ERROR: wrong ID type, please ensure a valid ID. (National ID, Passport, Driver's Liscence, Professional ID, or Postal ID)";
        statusColor = Colors.redAccent;
      } else {
        statusMessage =
        "ERROR: Wrong ID or ID Type not recognized. Please use the correct ID.";
        statusColor = Colors.orangeAccent;
      }
    } else {
      statusColor = Colors.redAccent;

      if (_isGoodFrame && !isIdTypeDetected) {
        // fallback for good frame quality but no recognized type
        statusMessage = "Card detected, but type is wrong or ID not found.";
      } else {
        statusMessage = "Align ID inside the frame and keep steady";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusMessage,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        const SizedBox(height: 8),
        if (_captureTarget != 'validId')
          Text(
            'Capture Target: ${_typeToDisplay(_captureTarget).toUpperCase()}',
            style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        if ((_captureTarget == 'senior' || _captureTarget == 'pwdFront') && idNumber != 'N/A (Type Check Only)') ...[
          const SizedBox(height: 4),
          Text(
            "ID Extracted: $idNumber",
            style: TextStyle(color: idNumberColor, fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          "Consecutive Good Frames: $_consecutiveGoodFrames / $_requiredGoodFrames",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 320,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isGoodFrame ? Colors.green : Colors.red,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _captureTarget == 'pwdBack' ? 'PWD Back Area' : 'ID Card Area',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
            ),
          ),

          // manual capture button
          Positioned(
            bottom: 170,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElementColors.tertiary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  "Capture Manually",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  await _controller?.stopImageStream();
                  final file = await _takePicture();
                  if (file == null) return;

                  String detected = 'none';
                  Map<String, String> extracted = {};

                  if (_isPwdBackCapture) {
                    detected = 'pwd';
                    extracted = {};
                  } else {
                    final text = await _runTextRecognition(file);
                    detected = _detectIdType(text);

                    if (_captureTarget == 'senior') {
                      extracted = extractSeniorIdFields(text);
                    } else if (_captureTarget == 'pwdFront') {
                      extracted = extractPwdIdFields(text);
                    } else if (_captureTarget == 'validId' && detected != 'none') {
                      extracted = {};
                    }
                  }

                  if (!mounted) return;

                  if (_lastSavedFile != null && await _lastSavedFile!.exists()) {
                    try {
                      await _lastSavedFile!.delete();
                      debugPrint('Deleted temporary file during manual capture: ${_lastSavedFile!.path}');
                    } catch (e) {
                      debugPrint('Could not delete temporary file: $e');
                    }
                  }

                  _lastSavedFile = file;

                  widget.onCapture(file, extracted, detected);

                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
          ),

          //live status messages while on cam
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.black54,
              child: _buildStatusRows(),
            ),
          ),

          Positioned(
            top: 40,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
