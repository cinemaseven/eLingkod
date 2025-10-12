import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

class UploadImageBox extends StatelessWidget {
  final String? label;
  final File? imageFile;
  final Future<File?> Function()? onPickFile;
  final FormFieldValidator<File>? validator;
  final FormFieldSetter<File>? onSaved;
  final AutovalidateMode autovalidateMode;
  final void Function(File?)? onChanged;

  const UploadImageBox({
    super.key,
    this.label,
    required this.imageFile,
    required this.onPickFile,
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<File>(
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      initialValue: imageFile,
      builder: (FormFieldState<File> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(label!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
            ],

            Stack(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await onPickFile?.call();
                    if (picked != null) {
                      state.didChange(picked);
                      onChanged?.call(picked);
                    }
                  },
                  child: Container(
                    height: 150,
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
                    // 🟢 Show file name instead of image preview
                    child: state.value != null
                        ? Center(
                            child: Text(
                              state.value!.path.split('/').last,
                              style: const TextStyle(color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Upload Photo", style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                  ),
                ),

                // ❌ Remove image button
                if (state.value != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: ElementColors.primary,
                            title: Text("Remove image", style: TextStyle(color: ElementColors.fontColor2)),
                            content: Text(
                              "Are you sure you want to remove this image?",
                              style: TextStyle(color: ElementColors.fontColor2),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("No", style: TextStyle(color: ElementColors.fontColor2)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text("Yes", style: TextStyle(color: ElementColors.fontColor2)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          state.didChange(null);
                          onChanged?.call(null);
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),
            const Center(
              child: Text(
                "File format: JPG, PNG.\nMax file size: 5MB.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),

            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


class UploadFileBox extends StatelessWidget {
  final String? label;
  final File? file;
  final Future<File?> Function()? onPickFile;
  final FormFieldValidator<File>? validator;
  final FormFieldSetter<File>? onSaved;
  final AutovalidateMode autovalidateMode;
  final void Function(File?)? onChanged; // ✅ NEW

  const UploadFileBox({
    super.key,
    this.label,
    required this.file,
    required this.onPickFile,
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onChanged, // ✅ NEW
  });

  @override
  Widget build(BuildContext context) {
    return FormField<File>(
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      initialValue: file,
      builder: (FormFieldState<File> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(label!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
            ],

            Stack(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await onPickFile?.call();
                    if (picked != null) {
                      state.didChange(picked);
                      onChanged?.call(picked); // ✅ sync with parent
                    }
                  },
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
                    child: state.value != null
                        ? Center(
                            child: Text(
                              state.value!.path.split('/').last,
                              style: const TextStyle(color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.upload_file, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Upload File", style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                  ),
                ),

                // ✅ Remove button when file exists
                if (state.value != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: ElementColors.primary,
                            title: Text("Remove file", style: TextStyle(color: ElementColors.fontColor2)),
                            content: Text("Are you sure you want to remove this file?", style: TextStyle(color: ElementColors.fontColor2)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("No", style: TextStyle(color: ElementColors.fontColor2)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text("Yes", style: TextStyle(color: ElementColors.fontColor2)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          state.didChange(null);
                          onChanged?.call(null); // ✅ clear parent too
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),
            const Center(
              child: Text(
                "File format: PDF, DOCX.\nMax file size: 10MB.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),

            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}