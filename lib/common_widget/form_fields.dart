import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

// for textfields
enum TxtFieldType { regis, services, profile }

class TxtField extends StatelessWidget {
  final TxtFieldType type;
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final double? width;
  final double labelFontSize;
  final EdgeInsets? customPadding; // 🔹 NEW flag

  const TxtField({
    super.key,
    required this.type,
    required this.hint,
    this.label,
    this.controller,
    this.keyboardType,
    this.obscure = false,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
    this.width,
    this.labelFontSize = 16,
    this.customPadding, // 🔹 default = false
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
        );

      case TxtFieldType.services:
        return InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ElementColors.placeholder),
          filled: true,
          fillColor: ElementColors.serviceField,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          suffixIcon: suffixIcon,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 13),
      decoration: _getDecoration(),
    );

    Widget fieldWidget = textField;

    // 🔹 Wrap with SizedBox if width is specified
    if (width != null) {
      fieldWidget = SizedBox(width: width, child: textField);
    }

    if (type == TxtFieldType.services) {
      return Padding(
        padding: customPadding ?? EdgeInsets.fromLTRB(30, 5, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: TextStyle(
                  fontSize: labelFontSize, // 🔹 adjustable
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
              child: fieldWidget,
            ),
          ],
        ),
      );
    }

    return fieldWidget;
  }
}

class RadioButtons extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? initialValue;
  final Function(String?) onChanged;
  final bool inline;
  final bool showOther;

  const RadioButtons({
    super.key,
    required this.label,
    required this.options,
    this.initialValue,
    required this.onChanged,
    this.inline = false,
    this.showOther = false,
  });

  @override
  State<RadioButtons> createState() => _RadioButtonsState();
}

class _RadioButtonsState extends State<RadioButtons> {
  String? selectedValue;
  TextEditingController otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    bool isInline = widget.inline;

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label
          Text(
            "${widget.label}:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ElementColors.fontColor1,
            ),
          ),
          const SizedBox(height: 6),

          // Inline style
          if (isInline)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...widget.options.map((option) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: selectedValue,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => states.contains(WidgetState.selected)
                              ? ElementColors.primary
                              : ElementColors.buttonField,
                        ),
                        onChanged: (value) {
                          setState(() => selectedValue = value);
                          widget.onChanged(value);
                        },
                      ),
                      Text(option, style: const TextStyle(fontSize: 15)),
                    ],
                  );
                }),
                if (widget.showOther) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: "Other:",
                        groupValue: selectedValue,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => states.contains(WidgetState.selected)
                              ? ElementColors.primary
                              : ElementColors.buttonField,
                        ),
                        onChanged: (value) {
                          setState(() => selectedValue = value);
                          widget.onChanged(otherController.text);
                        },
                      ),
                      const Text("Other:", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ],
            ),

          // Stacked style
          if (!isInline) ...[
            ...widget.options.map((option) {
              return RadioListTile<String>(
                value: option,
                groupValue: selectedValue,
                activeColor: ElementColors.primary,
                title: Text(option),
                onChanged: (value) {
                  setState(() => selectedValue = value);
                  widget.onChanged(value);
                },
              );
            }),

            if (widget.showOther) ...[
              RadioListTile<String>(
                value: "Other:",
                groupValue: selectedValue,
                activeColor: ElementColors.primary,
                title: const Text("Other:"),
                onChanged: (value) {
                  setState(() => selectedValue = value);
                  widget.onChanged(otherController.text);
                },
              ),
              if (selectedValue == "Other:")
                TxtField(
                  type: TxtFieldType.services,
                  controller: otherController,
                  hint: "Please specify",
                  onTap: () => widget.onChanged(otherController.text),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class CheckBoxes extends StatefulWidget {
  final String label;
  final List<String> options;
  final Function(List<String>) onChanged;
  final bool showOther;

  const CheckBoxes({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.showOther = false,
  });

  @override
  State<CheckBoxes> createState() => _CheckBoxesState();
}

class _CheckBoxesState extends State<CheckBoxes> {
  List<String> selectedValues = [];
  bool otherSelected = false;
  TextEditingController otherController = TextEditingController();

  void _updateSelection(String value, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedValues.add(value);
      } else {
        selectedValues.remove(value);
      }
      widget.onChanged(selectedValues);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ElementColors.fontColor1,
            ),
          ),
          const SizedBox(height: 8),

          // Standard options
          ...widget.options.map((option) {
            return CheckboxListTile(
              value: selectedValues.contains(option),
              activeColor: ElementColors.primary,
              title: Text(option),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) {
                _updateSelection(option, checked ?? false);
              },
            );
          }).toList(),

          // "Other" option if enabled
          if (widget.showOther) ...[
            CheckboxListTile(
              value: otherSelected,
              activeColor: ElementColors.primary,
              title: const Text("Other"),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) {
                setState(() {
                  otherSelected = checked ?? false;
                  if (!otherSelected) {
                    selectedValues.removeWhere((v) => v.startsWith("Other:"));
                  }
                });
                widget.onChanged(selectedValues);
              },
            ),
            if (otherSelected)
              TxtField(
                type: TxtFieldType.services,
                controller: otherController,
                hint: "Please specify",
                onTap: () {
                  setState(() {
                    selectedValues.removeWhere((v) => v.startsWith("Other:"));
                    selectedValues.add("Other: ${otherController.text}");
                  });
                  widget.onChanged(selectedValues);
                },
              ),
          ],
        ],
      ),
    );
  }
}
