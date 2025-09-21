import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

class UploadImageBox extends StatelessWidget {
  final String? label;
  final File? imageFile;
  final VoidCallback onTap;

  const UploadImageBox({
    super.key,
    this.label,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show label only if provided
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
        ],

        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: ElementColors.serviceField,
              boxShadow: [
                BoxShadow(
                  color: ElementColors.shadow,
                  blurRadius: 3,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "Upload Photo",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 6),
        const Center(
          child: Text(
            "File format: JPG, PNG.\nMax file size: 5MB.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class UploadFileBox extends StatelessWidget {
  final String? label;
  final File? file;
  final VoidCallback onTap;

  const UploadFileBox({
    super.key,
    this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show label only if provided
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
        ],

        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: ElementColors.serviceField,
              boxShadow: [
                BoxShadow(
                  color: ElementColors.shadow,
                  blurRadius: 3,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: file != null
                ? Center(
                    child: Text(
                      file!.path.split('/').last,
                      style: const TextStyle(color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.upload_file, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "Upload File",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 6),
        Center(
          child: const Text(
            "File format: PDF, DOCX.\nMax file size: 10MB.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
