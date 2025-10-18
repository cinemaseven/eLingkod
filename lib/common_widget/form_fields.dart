import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';

// for textfields
enum TxtFieldType { regis, services }

class TxtField extends StatefulWidget {
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
  final EdgeInsets? customPadding;
  final String? Function(String?)? validator; 

  TxtField({
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
    this.customPadding,
    this.validator,
  });

  @override
  State<TxtField> createState() => _TxtFieldState();
}

class _TxtFieldState extends State<TxtField> {
  InputDecoration _getDecoration() {
    final TextStyle errorTextStyle = TextStyle(
      color: ElementColors.tertiary,
      fontSize: 12,
      height: 1.2,
    );
    
    switch (widget.type) {
      case TxtFieldType.regis:
        return InputDecoration(
          hintText: widget.hint,
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
          suffixIcon: widget.suffixIcon,
          errorStyle: errorTextStyle,
        );

      case TxtFieldType.services:
        return InputDecoration(
          hintText: widget.hint,
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
          suffixIcon: widget.suffixIcon,
          errorStyle: errorTextStyle,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscure,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: const TextStyle(fontSize: 13),
      decoration: _getDecoration(),
      validator: widget.validator,
    );

    Widget fieldWidget = textField;

    if (widget.width != null) {
      fieldWidget = SizedBox(width: widget.width, child: textField);
    }

    if (widget.type == TxtFieldType.services) {
      return Padding(
        padding: widget.customPadding ?? const EdgeInsets.fromLTRB(30, 5, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: widget.labelFontSize,
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

class RadioButtons extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? initialValue;
  final Function(String?) onChanged;
  final bool inline;
  final bool showOther;
  final String? Function(String?)? validator;

  const RadioButtons({
    super.key,
    required this.label,
    required this.options,
    this.initialValue,
    required this.onChanged,
    this.inline = false,
    this.showOther = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: initialValue,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${label}:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: ElementColors.fontColor1,
                ),
              ),
              const SizedBox(height: 6),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: [
                      if (inline)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ...options.map((option) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    value: option,
                                    groupValue: state.value,
                                    fillColor: WidgetStateProperty.resolveWith<Color>(
                                      (states) => states.contains(WidgetState.selected)
                                          ? ElementColors.primary
                                          : ElementColors.buttonField,
                                    ),
                                    onChanged: (value) {
                                      state.didChange(value);
                                      onChanged(value);
                                      setState(() {});
                                    },
                                  ),
                                  Text(option, style: const TextStyle(fontSize: 15)),
                                ],
                              );
                            }),
                            if (showOther) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    value: "Other:",
                                    groupValue: state.value?.startsWith("Other:") == true ? "Other:" : state.value,
                                    fillColor: WidgetStateProperty.resolveWith<Color>(
                                      (states) => states.contains(WidgetState.selected)
                                          ? ElementColors.primary
                                          : ElementColors.buttonField,
                                    ),
                                    onChanged: (value) {
                                      state.didChange("Other:");
                                      onChanged("Other:");
                                      setState(() {});
                                    },
                                  ),
                                  const Text("Other:", style: TextStyle(fontSize: 15)),
                                ],
                              ),
                              if (state.value?.startsWith("Other:") == true)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0, top: 5.0),
                                  child: TxtField(
                                    type: TxtFieldType.services,
                                    hint: "Please specify",
                                    controller: TextEditingController(),
                                    validator: (val) {
                                      if (state.value?.startsWith("Other:") == true && (val == null || val.isEmpty)) {
                                        return "Please specify the 'Other' option.";
                                      }
                                      return null;
                                    },
                                    onTap: () {},
                                  ),
                                ),
                            ],
                          ],
                        ),
                      if (!inline) ...[
                        ...options.map((option) {
                          return RadioListTile<String>(
                            value: option,
                            groupValue: state.value,
                            activeColor: ElementColors.primary,
                            title: Text(option),
                            onChanged: (value) {
                              state.didChange(value);
                              onChanged(value);
                            },
                          );
                        }),
                        if (showOther) ...[
                          RadioListTile<String>(
                            value: "Other:",
                            groupValue: state.value,
                            activeColor: ElementColors.primary,
                            title: const Text("Other:"),
                            onChanged: (value) {
                              state.didChange(value);
                              onChanged(value);
                            },
                          ),
                        ],
                      ],
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                          child: Text(
                            state.errorText ?? '',
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CheckBoxes extends FormField<List<String>> {
  CheckBoxes({
    super.key,
    required String label,
    required List<String> options,
    required Function(List<String>) onChanged,
    bool showOther = false,
    String? Function(List<String>?)? validator,
  }) : super(
          validator: validator,
          builder: (FormFieldState<List<String>> state) {
            return _CheckBoxesContent(
              label: label,
              options: options,
              onChanged: onChanged,
              showOther: showOther,
              formFieldState: state,
            );
          },
        );
}

class _CheckBoxesContent extends StatefulWidget {
  final String label;
  final List<String> options;
  final Function(List<String>) onChanged;
  final bool showOther;
  final FormFieldState<List<String>> formFieldState;

  const _CheckBoxesContent({
    required this.label,
    required this.options,
    required this.onChanged,
    required this.showOther,
    required this.formFieldState,
  });

  @override
  _CheckBoxesContentState createState() => _CheckBoxesContentState();
}

class _CheckBoxesContentState extends State<_CheckBoxesContent> {
  List<String> selectedValues = [];
  bool otherSelected = false;
  final TextEditingController otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedValues = widget.formFieldState.value ?? [];
    otherController.addListener(() {
      _updateOtherValue();
    });
  }

  void _updateSelection(String value, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedValues.add(value);
      } else {
        selectedValues.remove(value);
      }
      widget.onChanged(selectedValues);
      widget.formFieldState.didChange(selectedValues);
    });
  }

  void _updateOtherValue() {
    setState(() {
      final otherText = "Other: ${otherController.text}";
      selectedValues.removeWhere((v) => v.startsWith("Other:"));
      if (otherController.text.isNotEmpty) {
        selectedValues.add(otherText);
      }
      widget.onChanged(selectedValues);
      widget.formFieldState.didChange(selectedValues);
    });
  }

  @override
  void dispose() {
    otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ElementColors.fontColor1,
            ),
          ),
          const SizedBox(height: 8),
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
                    otherController.clear();
                    selectedValues.removeWhere((v) => v.startsWith("Other:"));
                  }
                  widget.onChanged(selectedValues);
                  widget.formFieldState.didChange(selectedValues);
                });
              },
            ),
            if (otherSelected)
              TxtField(
                type: TxtFieldType.services,
                controller: otherController,
                hint: "Please specify",
                validator: (value) {
                  if (otherSelected && (value == null || value.isEmpty)) {
                    return "Please specify the 'Other' option.";
                  }
                  return null;
                },
              ),
          ],
          if (widget.formFieldState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0),
              child: Text(
                widget.formFieldState.errorText ?? '',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}