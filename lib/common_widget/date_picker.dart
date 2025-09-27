// common_date_picker.dart

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showCustomDatePicker(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: ElementColors.primary,
            onPrimary: ElementColors.fontColor2,
            onSurface: ElementColors.fontColor1,
          ),
          dialogBackgroundColor: ElementColors.fontColor2,
        ),
        child: child!,
      );
    },
  );
  return pickedDate;
}