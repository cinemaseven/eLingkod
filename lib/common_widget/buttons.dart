import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

enum BtnType { primary, secondary, tertiary, lightSecondary }

class Buttons extends StatelessWidget {
  final VoidCallback onClick;
  final String title;
  final BtnType type;
  final IconData? icon;
  final double? fontSize;
  final double? width;
  final double? height;
  final Color? customFontColor;

  const Buttons({
    super.key,
    required this.title,
    required this.onClick,
    this.type = BtnType.primary,
    this.icon,
    this.fontSize,
    this.width,
    this.height,
    this.customFontColor,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case BtnType.primary:
        return ElementColors.primary;
      case BtnType.secondary:
        return ElementColors.secondary;
      case BtnType.tertiary:
        return ElementColors.tertiary;
      case BtnType.lightSecondary:
        return ElementColors.lightSecondary;
    }
  }

  // Default font color = white, but allow override
  Color _getFontColor() {
    return customFontColor ?? ElementColors.fontColor2;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final textColor = _getFontColor();

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor, // ripple + icon color
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onClick,
        icon: icon != null ? Icon(icon, size: 20, color: Colors.white) : const SizedBox.shrink(),
        label: Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 20,
            color: textColor, // always white text
          ),
        ),
      ),
    );
  }
}
