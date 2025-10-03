import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

enum TxtFieldType { regis, services, profile }

class TxtField extends StatelessWidget {
  final TxtFieldType type;
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscure;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

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
          contentPadding: const EdgeInsets.symmetric(
            vertical: .5,
            horizontal: 15,
          ),
          suffixIcon: suffixIcon,
        );

      case TxtFieldType.services:
        return InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ElementColors.placeholder),
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 15,
          ),
          suffixIcon: suffixIcon,
        );

      case TxtFieldType.profile:
        return InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ElementColors.placeholder),
          filled: true,
          fillColor: ElementColors.fontColor2,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black26, width: 1), // border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ElementColors.secondary, width: 1.5), // active border
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 15,
          ),
          suffixIcon: suffixIcon,
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
      decoration: _getDecoration().copyWith(
    suffixIcon: suffixIcon),
    );

    if (type == TxtFieldType.services) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
              const SizedBox(height: 6),
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

    if (type == TxtFieldType.profile) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: const Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: -2,
              ),
            ],
          ),
          child: textField,
        ),
      );
    }
    return textField;
  }
}
