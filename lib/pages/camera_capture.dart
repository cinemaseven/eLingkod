import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCapturePage extends StatefulWidget {
  final Function(File) onCapture;

  const CameraCapturePage({super.key, required this.onCapture});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? controller;
  bool isInitialized = false;
  bool isGood = false;
  bool checkingFrame = false;
  int goodFrameCount = 0;
  bool photoTaken = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      controller = CameraController(cameras.first, ResolutionPreset.medium);
      await controller!.initialize();

      controller!.startImageStream((CameraImage image) {
        if (!checkingFrame && !photoTaken) {
          checkingFrame = true;
          _analyzeFrame(image).then((ok) async {
            if (!mounted) return;

            setState(() => isGood = ok);
            checkingFrame = false;

            if (ok) {
              goodFrameCount++;
            } else {
              goodFrameCount = 0;
            }

            // Auto-capture if ID is steady for ~1 second
            if (goodFrameCount > 5 && !photoTaken) {
              photoTaken = true;
              await capturePhoto();
            }
          });
        }
      });

      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  // Simple analyzer (always returns true)
  Future<bool> _analyzeFrame(CameraImage image) async {
    // Add blur/glare detection later
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Future<void> capturePhoto() async {
    if (controller == null || !controller!.value.isInitialized) return;
    try {
      await controller!.stopImageStream(); // stop streaming before capture
      final file = await controller!.takePicture();
      widget.onCapture(File(file.path));
      if (mounted) {
        Navigator.pop(context); // return to form
      }
    } catch (e) {
      debugPrint("Error taking photo: $e");
      photoTaken = false; // retry if capture fails
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Capture ID")),
      body: Stack(
        children: [
          CameraPreview(controller!),
          // Border overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isGood ? Colors.green : Colors.red,
                width: 6,
              ),
            ),
          ),
          // Auto-capture status
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isGood ? "Hold still... capturing ✅" : "Align your ID 📷",
                style: TextStyle(
                  color: isGood ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
