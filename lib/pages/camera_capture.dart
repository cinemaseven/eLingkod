// camera_capture.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img_pkg;
import 'package:path_provider/path_provider.dart';

/// CameraCapturePage
/// onCapture: `(File capturedImage, Map<String,String> extractedFields, String detectedType)`
/// detectedType: 'senior' | 'pwd' | 'none'
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
  final int _requiredGoodFrames = 6;
  File? _lastSavedFile;

  Map<String, String> _extractedFields = {};
  String _detectedType = 'none';

  late final TextRecognizer _textRecognizer;
  final int frameDelayMs = 350;

  // ⏱️ Timeout State Variables
  DateTime? _startTime;
  bool _isWrongIdTimeout = false;
  final int _timeoutSeconds = 8; // keep 8s as requested

  // 🆕 NEW: Determine if this capture is for the PWD Back ID
  late final bool _isPwdBackCapture;
  // 🆕 NEW: Normalized ID number from profile for matching (for PWD Front)
  late final String _targetPwdIdNum;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    // Determine the capture target
    _isPwdBackCapture = widget.profileData['capture_target'] == 'pwdBack';

    // Normalize target PWD ID by removing all non-numeric/non-dash/non-slash characters
    String targetId = widget.profileData['pwd_id_number'] ?? '';
    _targetPwdIdNum = targetId.replaceAll(RegExp(r'[^0-9\-\/]'), '').trim();

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

      // Use safe access just in case the initialization fails quickly
      await _controller?.initialize();
      if (!mounted) return;

      // Check if initialization was successful before starting stream
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

  // --------------------------------------------------
  // 🔹 Helper: Detect ID Type (Kept for Senior and PWD Front initial check)
  // --------------------------------------------------
  String _detectIdType(String text) {
    final normalized = text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\s]'), '');

    // Check PWD first
    if (normalized.contains('PWD') ||
        normalized.contains('PERSON WITH DISABILITY') ||
        normalized.contains('DISABILITY')) {
      return 'pwd';
    }

    // Senior second
    if (normalized.contains('SENIOR') ||
        normalized.contains('SEN10R') ||
        normalized.contains('CITIZEN') ||
        normalized.contains('OSCA') ||
        normalized.contains('OFFICE OF THE SENIOR CITIZEN AFFAIRS')) {
      return 'senior';
    }

    return 'none';
  }

  // --------------------------------------------------
  // 🔹 Helper: Extract Senior Citizen ID fields (UNCHANGED)
  // --------------------------------------------------
  Map<String, String> extractSeniorIdFields(String ocrText) {
    String? idNum;

    // Split into lines and normalize:
    final lines = ocrText
        .split('\n')
        .map((l) => l.trim().toUpperCase())
        .where((l) => l.isNotEmpty)
        .toList();

    // --- Search only the first 6 lines where the ID is typically located ---
    final searchScope = min(6, lines.length);

    // 1. Primary Search (Labeled Search - in case it is on one line)
    for (int i = 0; i < searchScope; i++) {
      final line = lines[i];
      // ID number is strictly [0-9\-\/]
      final labeledMatch = RegExp(
          r'(SCN|ID|NO|NUMBER|OSCA|TIN|SENIOR\s*ID|SENIOR\s*NO)[\s#:]*([0-9\-\/]{5,25})')
          .firstMatch(line);

      if (labeledMatch != null) {
        idNum = labeledMatch.group(2)?.trim();
        break;
      }
    }

    // 2. Check for numeric string followed by ID label on the next line.
    if (idNum == null || idNum.length < 5) {
      idNum = null;

      for (int i = 0; i < searchScope; i++) {
        final currentLine = lines[i];

        // Match a line that contains ONLY a potential numeric ID (no letters, 5-25 chars)
        final numMatch = RegExp(r'^([0-9\-\/]{5,25})$').firstMatch(currentLine);

        if (numMatch != null) {
          final candidate = numMatch.group(1)!;

          // Exclude obvious dates
          if (RegExp(r'^\d{1,2}[\-\/]\d{1,2}[\-\/]\d{2,4}$')
              .hasMatch(candidate) ||
              RegExp(r'^(?:19|20)\d{2}$').hasMatch(candidate)) {
            continue;
          }

          // Check the NEXT line for a common ID label
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

    // --- Final Cleanup and Validation ---
    if (idNum != null) {
      // Cleanup keeps only digits, dashes, or slashes
      idNum = idNum.replaceAll(RegExp(r'[^0-9\-\/]'), '').trim();
      if (idNum.length < 5) idNum = null;
    }

    return {
      'senior_id_number': idNum ?? '',
    };
  }

  // --------------------------------------------------
  // 🔹 Helper: Extract PWD ID fields (Strict PWD ID Only)
  // --------------------------------------------------
  Map<String, String> _extractPwdIdFields(String recognizedText) {
    String? pwdIdNum;

    // 1️⃣ PWD ID Number
    // Pattern captures strictly [0-9\-\/] and looks for common labels
    final idMatch = RegExp(
      r'(?:ID|PWD|NO|NUMBER|PWD\.? NO\.?|PWD NO)[:\s#]*([0-9\-\/]{4,20})',
      caseSensitive: false,
    ).firstMatch(recognizedText);

    if (idMatch != null) {
      String cleanedId =
      idMatch.group(1)!.replaceAll(RegExp(r'[^0-9\-\/]'), '').trim();
      if (cleanedId.length >= 4) {
        pwdIdNum = cleanedId;
      }
    }

    return {
      'pwd_id_number': pwdIdNum ?? '',
    };
  }

  // --------------------------------------------------
  // 🔹 Camera Stream & Processing
  // --------------------------------------------------
  void _startImageStream() {
    // 🛑 Prevent multiple starts
    if (_controller == null || !_controller!.value.isInitialized || _controller!.value.isStreamingImages) {
      debugPrint('Stream not starting: Controller is null, not initialized, or already streaming.');
      return;
    }

    _controller!.startImageStream((CameraImage image) async {
      // 🧠 Prevent overlapping frame processing
      if (_isProcessing || _controller == null || !_controller!.value.isInitialized) return;

      _isProcessing = true;

      try {
        // 🕒 Timeout check
        final elapsed = DateTime.now().difference(_startTime!).inSeconds;
        final bool isTimeout = elapsed > _timeoutSeconds;

        // ✅ Check plane existence
        if (image.planes.length < 3) {
          debugPrint('Error: CameraImage does not have enough planes. Skipping frame.');
          return;
        }

        // 🖼️ Convert frame to file
        final file = await _convertCameraImageToFile(image);
        final bytes = await file.readAsBytes();
        final qualityOk = await _isFrameQualityGood(bytes);

        if (qualityOk) {
          String detected = 'none';
          Map<String, String> extracted = {};
          bool shouldAutoCapture = false;

          if (_isPwdBackCapture) {
            // 🔸 PWD Back: skip OCR
            detected = 'pwd';
            shouldAutoCapture = true;
            extracted = {};
          } else {
            // 🔸 Senior / PWD Front: run OCR
            final recognizedText = await _runTextRecognition(file);
            detected = _detectIdType(recognizedText);

            if (detected == 'senior') {
              extracted = extractSeniorIdFields(recognizedText);

              // 🧠 Cache Senior ID number
              final current = extracted['senior_id_number'] ?? '';
              if (current.isNotEmpty) {
                _lastDetectedSeniorId = current;
              } else if (_lastDetectedSeniorId.isNotEmpty) {
                extracted['senior_id_number'] = _lastDetectedSeniorId;
              }

              shouldAutoCapture = true;
            } else if (detected == 'pwd') {
              extracted = _extractPwdIdFields(recognizedText);

              // 🧠 Cache PWD ID number
              final current = extracted['pwd_id_number'] ?? '';
              if (current.isNotEmpty) {
                _lastDetectedPwdId = current;
              } else if (_lastDetectedPwdId.isNotEmpty) {
                extracted['pwd_id_number'] = _lastDetectedPwdId;
              }

              // ✅ If target ID check is still needed
              final extractedPwdIdNum = extracted['pwd_id_number']
                  ?.replaceAll(RegExp(r'[^0-9\-\/]'), '')
                  .trim() ??
                  '';
              final idMatchesProfile =
                  _targetPwdIdNum.isNotEmpty && extractedPwdIdNum == _targetPwdIdNum;

              shouldAutoCapture = idMatchesProfile; // 👈 still checks match
            }
          }

          if (mounted) {
            setState(() {
              _isGoodFrame = true;
              _detectedType = detected;
            });

            if (_detectedType != 'none') {
              // 🧼 Delete old saved file
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

          // ⏳ Reset timeout tracker if detected type is valid
          if (_detectedType != 'none') {
            _startTime = DateTime.now();
            _isWrongIdTimeout = false;
          }

          // 📸 Auto-capture logic
          if (_consecutiveGoodFrames >= _requiredGoodFrames &&
              _lastSavedFile != null &&
              _detectedType != 'none') {

            // 🚫 For PWD front, only auto capture if ID matches
            if (!_isPwdBackCapture && _detectedType == 'pwd' && !shouldAutoCapture) {
              if (mounted) setState(() => _consecutiveGoodFrames = 0);
            } else {
              await _controller?.stopImageStream();
              if (!mounted) return;

              widget.onCapture(_lastSavedFile!, _extractedFields, _detectedType);

              if (mounted) Navigator.pop(context);
            }
          }
        } else {
          // ❌ Bad frame quality
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




  // --- Helper Functions (Conversion, Quality, OCR) ---

  Future<File> _convertCameraImageToFile(CameraImage image) async {
    // Plane access is safe here because we checked image.planes.length >= 3 in _startImageStream()
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

      // Blur check (lower variance = more blur). You can adjust this value (e.g., 35.0) if needed.
      if (variance < 40.0) return false;

      // Overexposure/Brightness check
      int bright = 0;
      int sampled = 0;
      for (int y = 0; y < gray.height; y += 6) {
        for (int x = 0; x < gray.width; x += 6) {
          sampled++;
          final px = gray.getPixel(x, y).r;
          if (px > 245) bright++;
        }
      }

      // If more than 8% of the sampled area is pure white (overexposed)
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


  //--------------------------------------------------
  // 🔹 Build Status Rows (Detailed bottom panel)
  // --------------------------------------------------
  String _lastDetectedSeniorId = '';
  String _lastDetectedPwdId = '';

  Widget _buildStatusRows() {
    // Determine the ID number to display
    final idKey = _detectedType == 'senior' ? 'senior_id_number' : 'pwd_id_number';
    final idNumber = _extractedFields[idKey] ?? 'N/A';

    final idNumberColor = idNumber == 'N/A' ? Colors.grey : Colors.greenAccent;

    // Main Status Message
    String statusMessage;
    Color statusColor;
    String idMatchMessage = '';
    Color idMatchColor = Colors.white70;

    // PWD Front specific check
    final bool isPwdFrontCapture = !_isPwdBackCapture && widget.profileData['capture_target'] == 'pwdFront';
    // Use safe access (?? '') since _extractedFields might not have the key or it might be null
    final extractedPwdIdNum = isPwdFrontCapture ? (_extractedFields['pwd_id_number']?.replaceAll(RegExp(r'[^0-9\-\/]'), '').trim() ?? '') : '';
    final bool idMatchesProfile = isPwdFrontCapture && _targetPwdIdNum.isNotEmpty && extractedPwdIdNum == _targetPwdIdNum;


    if (_isPwdBackCapture) {
      // Status for PWD Back: Focus on framing/auto-capture state (Framing Only)
      if (_consecutiveGoodFrames >= _requiredGoodFrames) {
        statusMessage = "Auto-Capturing PWD Back ID...";
        statusColor = Colors.lightGreenAccent;
      } else {
        statusMessage = "Align PWD Back ID. Auto-capture pending.";
        statusColor = Colors.cyanAccent;
      }

    } else if (isPwdFrontCapture) {
      // Status for PWD Front
      if (_detectedType != 'pwd') {
        statusMessage = "Wrong ID Type Detected. Please use PWD Front ID.";
        statusColor = Colors.redAccent;
      } else if (idMatchesProfile && _consecutiveGoodFrames >= _requiredGoodFrames) {
        statusMessage = "PWD ID Verified! Auto-Capturing...";
        statusColor = Colors.lightGreenAccent;
      } else if (idMatchesProfile && _consecutiveGoodFrames > 0) {
        statusMessage = "PWD ID Matched! Keep steady to capture ($idNumber)";
        statusColor = Colors.greenAccent;
      } else if (extractedPwdIdNum.isNotEmpty) {
        statusMessage = "PWD ID Mismatch. Please check orientation and number.";
        statusColor = Colors.orangeAccent;
        idMatchMessage = "Target ID: $_targetPwdIdNum";
        idMatchColor = Colors.orangeAccent;
      } else {
        statusMessage = "PWD Front Card Detected. Extracting ID...";
        statusColor = Colors.cyanAccent;
      }

    } else if (widget.profileData['capture_target'] == 'senior') {
      // Status for Senior ID
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
      statusMessage =
      "🛑 ERROR: Wrong ID or ID Type not recognized. Please use the correct ID.";
      statusColor = Colors.orangeAccent;
    } else if (_isGoodFrame) {
      // Fallback for good frame quality but no recognized type
      statusMessage = "Card detected, but type is wrong or ID not found.";
      statusColor = Colors.redAccent;
    } else {
      statusMessage = "Align ID inside the frame and keep steady";
      statusColor = Colors.redAccent;
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
        Text(
          // Use capture_target for a clearer initial state
          'Capture Target: ${widget.profileData['capture_target'].toString().toUpperCase()}',
          style:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Only display ID number if it's not the PWD back and an ID was extracted
        if (!_isPwdBackCapture && idNumber != 'N/A') ...[
          const SizedBox(height: 4),
          Text(
            "ID Extracted: $idNumber",
            style: TextStyle(color: idNumberColor, fontWeight: FontWeight.bold),
          ),
          if (idMatchMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(idMatchMessage, style: TextStyle(color: idMatchColor, fontWeight: FontWeight.bold)),
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
          // 1. Camera View
          CameraPreview(_controller!),

          // 2. ID Card Area Overlay (Targeting Box)
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
                  _isPwdBackCapture ? 'PWD Back Area' : 'ID Card Area',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
            ),
          ),

          // 3. Manual Capture Button
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
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
                    // PWD Back: Manual capture skips OCR
                    detected = 'pwd';
                    extracted = {}; // Ensure fields are empty
                  } else {
                    final text = await _runTextRecognition(file);
                    detected = _detectIdType(text);
                    extracted = detected == 'senior'
                        ? extractSeniorIdFields(text)
                        : _extractPwdIdFields(text);
                  }

                  if (!mounted) return;

                  // Delete previous file before saving the new one
                  if (_lastSavedFile != null && await _lastSavedFile!.exists()) {
                    try {
                      await _lastSavedFile!.delete();
                      debugPrint(
                          'Deleted previous capture: ${_lastSavedFile!.path}');
                    } catch (e) {
                      debugPrint('Could not delete previous file: $e');
                    }
                  }

                  widget.onCapture(file, extracted, detected);
                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
          ),

          // 4. Status/Control Panel (Bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.9), // Increased opacity
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRows(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}