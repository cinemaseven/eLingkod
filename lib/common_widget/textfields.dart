import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

enum TxtFieldType { regis, services, profile }

// class TxtField extends StatelessWidget {
//   final TxtFieldType type;
//   final String hint;
//   final TextEditingController? controller;
//   final bool obscure;
//   final bool readOnly;

//   const TxtField({
//     super.key,
//     required this.type,
//     required this.hint,
//     this.controller,
//     this.obscure = false,
//     this.readOnly = false,
//   });

//   InputDecoration _getDecoration() {
//     switch (type) {
//       case TxtFieldType.regis:
//         return InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: ElementColors.placeholder),
//           filled: true,
//           fillColor: ElementColors.fontColor2,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: .5,
//             horizontal: 15,
//           ),
//         );

//       case TxtFieldType.services:
//         return InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: ElementColors.placeholder),
//           filled: true,
//           fillColor: ElementColors.fontColor2,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.black26),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 12,
//             horizontal: 10,
//           ),
//         );

//       case TxtFieldType.profile:
//         return InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: ElementColors.placeholder),
//           filled: true,
//           fillColor: ElementColors.fontColor2,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 10,
//             horizontal: 12,
//           ),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       readOnly: readOnly,
//       style: const TextStyle(fontSize: 13),
//       decoration: _getDecoration(),
//     );
//   }
// }


class TxtField extends StatelessWidget {
  final TxtFieldType type;
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscure;
  final bool readOnly;
  final Widget? suffixIcon;   // 🔹 for icons like calendar / dropdown
  final VoidCallback? onTap;  // 🔹 to handle picker taps

  const TxtField({
    super.key,
    required this.type,
    required this.hint,
    this.label,
    this.controller,
    this.obscure = false,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
  });

  InputDecoration _getDecoration() {
    switch (type) {
      case TxtFieldType.regis:
        return InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ElementColors.placeholder),
          filled: true,
          fillColor: ElementColors.fontColor2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: .5, horizontal: 15),
        );

      case TxtFieldType.services:
        return InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ElementColors.placeholder),
          filled: true,
          fillColor: Colors.grey[300], // 🔹 light gray bg
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // 🔹 rounded corners
            borderSide: BorderSide(color: Colors.grey.shade200), // 🔹 no border line
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 15,
          ),
        );


      case TxtFieldType.profile:
        return InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ElementColors.placeholder),
          filled: true,
          fillColor: ElementColors.fontColor2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          suffixIcon: suffixIcon, // 🔹 also works here
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 13),
      decoration: _getDecoration(),
    );

    if (type == TxtFieldType.services) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 🔹 aligns label to left
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: ElementColors.fontColor1,
                ),
              ),
              const SizedBox(height: 6), // space between label & field
            ],
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: ElementColors.shadow,
                    blurRadius: 3,
                    offset: const Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: textField,
            ),
          ],
        ),
      );
    }

    return textField;
  }
}