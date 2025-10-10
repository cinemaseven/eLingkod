// camera_capture.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

  // ⏱️ NEW: Timeout State Variables
  DateTime? _startTime;
  bool _isWrongIdTimeout = false;
  final int _timeoutSeconds = 8;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _initCamera();
    // ⏱️ Initialize start time when the screen loads
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

      await _controller!.initialize();
      if (!mounted) return;

      setState(() => _isCameraReady = true);
      _startImageStream();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

// --------------------------------------------------
// 🔹 Helper: Detect ID Type (KEEP)
// --------------------------------------------------
  String _detectIdType(String ocrText) {
    final text = ocrText.toUpperCase();
    final normalized = text.replaceAll(RegExp(r'[^A-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.contains('SENIOR') ||
        normalized.contains('SEN10R') ||
        normalized.contains('CITIZEN') ||
        normalized.contains('OSCA') ||
        normalized.contains('OFFICE OF THE SENIOR CITIZEN AFFAIRS') ||
        normalized.contains('REPUBLIC OF THE PHILIPPINES')) {
      return 'senior';
    }

    if (normalized.contains('PWD') ||
        normalized.contains('PERSON WITH DISABILITY') ||
        normalized.contains('DISABILITY AFFAIRS')) {
      return 'pwd';
    }

    return 'none';
  }

// --------------------------------------------------
// 🔹 Helper: Extract Senior Citizen ID fields (FIXED FOR SEPARATE LINES)
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
      final labeledMatch = RegExp(r'(SCN|ID|NO|NUMBER|OSCA|TIN)[\s#:]*([0-9\-\/]{5,25})')
          .firstMatch(line);

      if (labeledMatch != null) {
        idNum = labeledMatch.group(2)?.trim();
        break;
      }
    }

    // 2. FIX: Check for numeric string followed by ID label on the next line.
    if (idNum == null || idNum!.length < 5) {
      idNum = null;

      for (int i = 0; i < searchScope; i++) {
        final currentLine = lines[i];

        // Match a line that contains ONLY a potential numeric ID (no letters, 5-25 chars)
        final numMatch = RegExp(r'^([0-9\-\/]{5,25})$').firstMatch(currentLine);

        if (numMatch != null) {
          final candidate = numMatch.group(1)!;

          // Exclude obvious dates
          if (RegExp(r'^\d{1,2}[\-\/]\d{1,2}[\-\/]\d{2,4}$').hasMatch(candidate) ||
              RegExp(r'^(?:19|20)\d{2}$').hasMatch(candidate))
          {
            continue;
          }

          // Check the NEXT line for a common ID label
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            if (nextLine.contains('SCN') || nextLine.contains('ID NO') || nextLine.contains('NUMBER') || nextLine.contains('OSCA')) {
              idNum = candidate;
              break;
            }
          }
        }
      }
    }


    // 3. Fallback (Original Date-Aware Check - If all labeled search failed)
    if (idNum == null || idNum!.length < 5) {
      idNum = null;

      for (int i = 0; i < searchScope; i++) {
        final line = lines[i];

        if (line.contains('DATE') || line.contains('ISSUE') || line.contains('EXPIRY') || line.contains('VALID') || line.contains('BIRTH')) {
          continue;
        }

        // Look for a long numeric string
        final matches = RegExp(r'([0-9\-\/]{8,25})').allMatches(line);

        for (var m in matches) {
          final candidate = m.group(1)!;

          if (RegExp(r'^\d{1,2}[\-\/]\d{1,2}[\-\/]\d{2,4}$').hasMatch(candidate) ||
              RegExp(r'^(?:19|20)\d{2}$').hasMatch(candidate)
          )
          {
            continue;
          }

          idNum = candidate;
          break;
        }
        if (idNum != null) break;
      }
    }

    // --- Final Cleanup and Validation ---
    if (idNum != null) {
      // Cleanup keeps only digits, dashes, or slashes
      idNum = idNum!.replaceAll(RegExp(r'[^0-9\-\/]'), '').trim();
      if (idNum!.length < 5) idNum = null;
    }

    return {
      'senior_id_number': idNum ?? '',
    };
  }

// --------------------------------------------------
// 🔹 Helper: Extract general/PWD fields (STRICT NUMERIC)
// --------------------------------------------------
  Map<String, String> _extractFieldsFromText(String recognizedText) {
    final lower = recognizedText.toLowerCase();

    Map<String, String> out = {};

    // 1️⃣ PWD ID Number (Only keeping this logic)
    if (lower.contains('pwd') ||
        lower.contains('disability') ||
        lower.contains('person with disability')) {

      // Pattern captures strictly [0-9\-\/] and looks for common labels
      final idMatch = RegExp(
        r'(?:ID|PWD|NO|NUMBER)[:\s#]*([0-9\-\/]{4,20})',
        caseSensitive: false,
      ).firstMatch(recognizedText);

      if (idMatch != null) {
        // Group 1 is the number. Clean it up to enforce strict numeric/dash/slash
        String cleanedId = idMatch.group(1)!.replaceAll(RegExp(r'[^0-9\-\/]'), '').trim();
        if (cleanedId.length >= 4) {
          out['pwd_id_number'] = cleanedId;
        }
      }
    }

    return out;
  }

// --------------------------------------------------
// 🔹 Camera Stream & Processing (UPDATED FOR TIMEOUT)
// --------------------------------------------------
  void _startImageStream() {
    if (_controller == null || _controller!.value.isStreamingImages) return;

    _controller!.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        final file = await _convertCameraImageToFile(image);
        final bytes = await file.readAsBytes();
        final qualityOk = await _isFrameQualityGood(bytes);

        // ⏱️ Check for timeout
        final elapsed = DateTime.now().difference(_startTime!).inSeconds;
        bool isTimeout = elapsed > _timeoutSeconds;


        if (qualityOk) {
          final recognizedText = await _runTextRecognition(file);
          final detected = _detectIdType(recognizedText);

          final extracted = detected == 'senior'
              ? extractSeniorIdFields(recognizedText)
              : _extractFieldsFromText(recognizedText);

          if(mounted){
            setState(() {
              _isGoodFrame = true;
              _detectedType = detected;

              if (_detectedType != 'none') {
                // Reset timeout on success
                _isWrongIdTimeout = false;
                _consecutiveGoodFrames++;
                _lastSavedFile = file;
                _extractedFields = extracted;
                // Since we successfully detected the type, we restart the timer
                // for the next capture sequence, but it's not strictly necessary
                // as the capture completes right after.
              } else if (isTimeout) {
                // Detected a frame with text, but couldn't identify ID type and timed out
                _isWrongIdTimeout = true;
                _consecutiveGoodFrames = 0;
                _extractedFields = {};
              } else {
                // Still within the time limit, reset consecutive frames
                _consecutiveGoodFrames = 0;
                _extractedFields = {};
              }
            });
          }
        } else {
          // Bad frame quality, only check for timeout
          if(mounted){
            setState(() {
              _isGoodFrame = false;
              _consecutiveGoodFrames = 0;
              _detectedType = 'none';
              _extractedFields = {}; // Clear fields on bad frame

              if (isTimeout && !_isWrongIdTimeout) {
                // Only set timeout state if we haven't already
                _isWrongIdTimeout = true;
              }
            });
          }
        }

        // ⏱️ If a successful ID type is detected, reset timeout tracker.
        if (_detectedType != 'none') {
          _startTime = DateTime.now();
          _isWrongIdTimeout = false;
        }


        // Final check to capture
        if (_consecutiveGoodFrames >= _requiredGoodFrames &&
            _lastSavedFile != null &&
            _detectedType != 'none') {
          await _controller?.stopImageStream();
          if (!mounted) return;
          widget.onCapture(_lastSavedFile!, _extractedFields, _detectedType);
          // Auto-capture completes and navigates back
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Stream processing error: $e');
      } finally {
        await Future.delayed(Duration(milliseconds: frameDelayMs));
        _isProcessing = false;
      }
    });
  }

// --- Helper Functions (Conversion, Quality, OCR) - Kept as is ---

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
        final uvIndex =
            (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2) * uPlane.bytesPerPixel!;
        final up = uPlane.bytes[uvIndex];
        final vp = vPlane.bytes[uvIndex];

        int r = (yp + 1.402 * (vp - 128)).round().clamp(0, 255);
        int g =
        (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round().clamp(0, 255);
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

      // Blur check (lower variance = more blur)
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

  // --------------------------------------------------
  // 🔹 Build Status Rows (UPDATED FOR TIMEOUT)
  // --------------------------------------------------
  Widget _buildStatusRows() {
    // Determine the ID number to display
    final idNumber = _extractedFields.values.isNotEmpty
        ? _extractedFields.values.first
        : 'N/A';

    final idNumberColor = idNumber == 'N/A' ? Colors.grey : Colors.greenAccent;

    // ⏱️ Main Status Message
    String statusMessage;
    Color statusColor;

    if (_isWrongIdTimeout) {
      statusMessage = "🛑 ERROR: Wrong ID or ID Type not recognized. Please use a Senior/PWD ID.";
      statusColor = Colors.orangeAccent;
    } else if (_isGoodFrame) {
      statusMessage = "✅ Good frame — detecting ID fields...";
      statusColor = Colors.greenAccent;
    } else {
      statusMessage = "❌ Align ID inside the frame and keep steady";
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
          'Detected ID Type: ${_detectedType.toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          "ID Extracted: $idNumber",
          style: TextStyle(color: idNumberColor, fontWeight: FontWeight.bold),
        ),
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
              child: const Center(
                child: Text(
                  'ID Card Area',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
            ),
          ),

          // 3. Manual Capture Button (Moved to not obstruct the bottom status panel)
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
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

                  final text = await _runTextRecognition(file);
                  final detected = _detectIdType(text);

                  final extracted = detected == 'senior'
                      ? extractSeniorIdFields(text)
                      : _extractFieldsFromText(text);

                  if (!mounted) return;

                  widget.onCapture(file, extracted, detected);
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // 4. Status/Control Panel (Bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.9), // Increased opacity for better visibility
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simplified Status Rows (contains the new timeout message)
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