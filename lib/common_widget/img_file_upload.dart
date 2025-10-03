import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

class UploadImageBox extends StatelessWidget {
  final String? label;
  final File? imageFile;
  final Future<File?> Function()? onPickFile; // changed to async file picker
  final FormFieldValidator<File>? validator;
  final FormFieldSetter<File>? onSaved;
  final AutovalidateMode autovalidateMode;

  const UploadImageBox({
    super.key,
    this.label,
    required this.imageFile,
    required this.onPickFile,
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.disabled,
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
              Text(
                label!,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
            ],

            GestureDetector(
              onTap: () async {
                final picked = await onPickFile?.call();
                if (picked != null) {
                  state.didChange(picked);
                }
              },
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
                child: state.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          state.value!,
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

            // 🔴 Validation error text (if any)
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

// class UploadFileBox extends StatelessWidget {
//   final String? label;
//   final File? file;
//   final VoidCallback onTap;

//   const UploadFileBox({
//     super.key,
//     this.label,
//     required this.file,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Show label only if provided
//         if (label != null) ...[
//           Text(
//             label!,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//         ],

//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             height: 100,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(10),
//               color: ElementColors.serviceField,
//               boxShadow: [
//                 BoxShadow(
//                   color: ElementColors.shadow,
//                   blurRadius: 3,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: file != null
//                 ? Center(
//                     child: Text(
//                       file!.path.split('/').last,
//                       style: const TextStyle(color: Colors.black87),
//                       textAlign: TextAlign.center,
//                     ),
//                   )
//                 : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: const [
//                       Icon(Icons.upload_file, size: 40, color: Colors.grey),
//                       SizedBox(height: 8),
//                       Text(
//                         "Upload File",
//                         style: TextStyle(color: Colors.black54),
//                       ),
//                     ],
//                   ),
//           ),
//         ),

//         const SizedBox(height: 6),
//         Center(
//           child: const Text(
//             "File format: PDF, DOCX.\nMax file size: 10MB.",
//             style: TextStyle(fontSize: 12, color: Colors.black54),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }
// }

class UploadFileBox extends StatelessWidget {
  final String? label;
  final File? file;
  final Future<File?> Function()? onPickFile;
  final FormFieldValidator<File>? validator;
  final FormFieldSetter<File>? onSaved;
  final AutovalidateMode autovalidateMode;

  const UploadFileBox({
    super.key,
    this.label,
    required this.file,
    required this.onPickFile,
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.disabled,
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

            GestureDetector(
              onTap: () async {
                final picked = await onPickFile?.call();
                if (picked != null) state.didChange(picked);
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
