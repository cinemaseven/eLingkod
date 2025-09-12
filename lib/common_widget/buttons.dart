import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

enum BtnType { bgPrimary, txtPrimary }

class Buttons extends StatelessWidget {
  final VoidCallback onClick;
  final String title;
  final BtnType type;
  final IconData? icon;
  final double? fontSize;
  final double? width;
  final double? height;

  const Buttons({
    super.key,
    required this.title,
    required this.onClick,
    this.type = BtnType.bgPrimary,
    this.icon,
    this.fontSize,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,   
      height: height, 
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: type == BtnType.bgPrimary ? ElementColors.primary : ElementColors.secondary,
          foregroundColor: type == BtnType.bgPrimary ? ElementColors.tertiary : ElementColors.primary,
          minimumSize: const Size.fromHeight(60), // default height if not overridden
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: type == BtnType.bgPrimary
                ? BorderSide.none
                : BorderSide(color: ElementColors.primary, width: 1),
          ),
        ),
        onPressed: onClick,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
