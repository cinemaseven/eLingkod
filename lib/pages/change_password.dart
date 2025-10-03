import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureRePassword = true;
  
  // ★ NEW: Controllers are local to this state
  final TextEditingController password = TextEditingController();
  final TextEditingController rePassword = TextEditingController();

  Map<String, bool> _validationStatus = {
    'isLengthValid': false,
    'hasUppercase': false,
    'hasLowercase': false,
    'hasNumber': false,
  };

  @override
  void initState() {
    super.initState();
    // ★ NEW: Initialize and listen to local controllers
    password.addListener(_checkPasswordValidation);
    _checkPasswordValidation();
  }

  @override
  void dispose() {
    // ★ NEW: Dispose local controllers
    password.removeListener(_checkPasswordValidation);
    password.dispose();
    rePassword.dispose();
    super.dispose();
  }

  void _checkPasswordValidation() {
    setState(() {
      String text = password.text;
      _validationStatus['isLengthValid'] = text.length >= 8;
      _validationStatus['hasUppercase'] = text.contains(RegExp(r'[A-Z]'));
      _validationStatus['hasLowercase'] = text.contains(RegExp(r'[a-z]'));
      _validationStatus['hasNumber'] = text.contains(RegExp(r'[0-9]'));
    });
  }

    double get _passwordStrength {
    int score = 0;
    if (_validationStatus['isLengthValid']!) score++;
    if (_validationStatus['hasUppercase']!) score++;
    if (_validationStatus['hasLowercase']!) score++;
    if (_validationStatus['hasNumber']!) score++;
    return score / 4.0;
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Update password
  Future<void> _updatePassword() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_formKey.currentState!.validate()) {
      try {
        // Use the local password controller
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: password.text.trim()),
        );
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Password updated successfully',
              style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.fontColor2,
          ),
        );
        // Navigate to Login after successful password update
        Navigator.pushReplacement(context, CustomPageRoute(page: const Login()));
      } on AuthException catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Auth Error: ${e.message}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary,
          ),
        );
      }
    }
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2.0),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle : Icons.circle_outlined,
              color: isValid ? Colors.green : ElementColors.fontColor1, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : ElementColors.fontColor1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ElementColors.fontColor2,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ElementColors.primary,
        iconTheme: IconThemeData(color: ElementColors.fontColor2),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ElementColors.tertiary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Text(
                      "Set New Password",
                      style: TextStyle(
                        fontSize: media.height * 0.033,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.height * 0.03),
                // Use local controllers
                TxtField(
                  type: TxtFieldType.services,
                  label: "New Password",
                  controller: password,
                  hint: "New Password",
                  obscure: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: ElementColors.primary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    final requiredError = _requiredValidator(value);
                    if (requiredError != null) return requiredError;
                    if (!_validationStatus.values.every((e) => e)) {
                      return 'Please meet all password requirements';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildValidationRow(
                        '8 or more characters',
                        _validationStatus['isLengthValid']!,
                      ),
                      _buildValidationRow(
                        'Uppercase & lowercase letters',
                        _validationStatus['hasUppercase']! &&
                            _validationStatus['hasLowercase']!,
                      ),
                      _buildValidationRow(
                        'At least one number',
                        _validationStatus['hasNumber']!,
                      ),
                      SizedBox(height: 7),
                      Padding(
                        padding: const EdgeInsets.only(left: 45.0),
                        child: Text(
                          'Password Strength:',
                          style: TextStyle(color: ElementColors.fontColor1, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45.0),
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: ElementColors.fontColor2,
                          color: _passwordStrength > 0.75
                            ? Colors.green
                            : _passwordStrength > 0.5
                            ? Colors.yellow
                            : ElementColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: "Re-enter Password",
                  controller: rePassword,
                  hint: "Re-enter Password",
                  obscure: _obscureRePassword,
                  keyboardType: TextInputType.visiblePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRePassword ? Icons.visibility_off : Icons.visibility,
                      color: ElementColors.primary,
                    ),
                    onPressed: () {
                      setState(() => _obscureRePassword = !_obscureRePassword);
                    },
                  ),
                  validator: (value) {
                    final requiredError = _requiredValidator(value);
                    if (requiredError != null) return requiredError;
                    // Compare against the local password controller
                    if (value != password.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Buttons(
                  title: "Save New Password",
                  type: BtnType.secondary,
                  fontSize: media.width * 0.04,
                  width: media.width * 0.7,
                  height: media.height * 0.05,
                  onClick: _updatePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}