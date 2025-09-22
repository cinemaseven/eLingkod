import 'dart:convert';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/pages/login.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool useEmail = true;
  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  TextEditingController email = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();

  // New state variables for password validation
  Map<String, bool> _validationStatus = {
    'isLengthValid': false,
    'hasUppercase': false,
    'hasLowercase': false,
    'hasNumber': false,
  };

  @override
  void initState() {
    super.initState();
    password.addListener(_checkPasswordValidation);
  }

  @override
  void dispose() {
    password.removeListener(_checkPasswordValidation);
    password.dispose();
    email.dispose();
    contactNumber.dispose();
    rePassword.dispose();
    super.dispose();
  }

  void _checkPasswordValidation() {
    setState(() {
      _validationStatus['isLengthValid'] = password.text.length >= 8;
      _validationStatus['hasUppercase'] = password.text.contains(
        RegExp(r'[A-Z]'),
      );
      _validationStatus['hasLowercase'] = password.text.contains(
        RegExp(r'[a-z]'),
      );
      _validationStatus['hasNumber'] = password.text.contains(RegExp(r'[0-9]'));
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

  Future<void> _signup() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Front-end email and contact number validation
    if (useEmail &&
        !RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
        ).hasMatch(email.text)) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address.'),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!useEmail && contactNumber.text.length != 11) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Contact number must be exactly 11 digits.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_validationStatus.values.every((element) => element)) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Please meet all password requirements.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.text != rePassword.text) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final url = Uri.parse('http://localhost:3000/signup');
    final body = {
      'emailOrContact': useEmail ? email.text : contactNumber.text,
      'password': password.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final resBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Sign up successful!'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.push(
          context,
          CustomPageRoute(
            page: ProfileInfo(
              emailOrContact: useEmail ? email.text : contactNumber.text,
            ),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(resBody['message'] ?? 'Sign up failed'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      body: Column(
        children: [
          SizedBox(height: media.height * 0.02),
          Center(
            child: Image.asset(
              "assets/images/logo.png",
              width: media.width * 0.5,
            ),
          ),
          SizedBox(height: media.height * 0.03),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ElementColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: media.width * 0.1,
                vertical: media.height * 0.03,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: media.width * 0.08,
                        color: ElementColors.fontColor2,
                      ),
                    ),
                    SizedBox(height: media.height * 0.04),
                    if (useEmail)
                      TxtField(
                        type: TxtFieldType.regis,
                        controller: email,
                        hint: "Email",
                        keyboardType: TextInputType.emailAddress,
                      )
                    else
                      TxtField(
                        type: TxtFieldType.regis,
                        controller: contactNumber,
                        hint: "Contact Number",
                        keyboardType: TextInputType.number,
                      ),
                    SizedBox(height: media.height * 0.02),
                    TxtField(
                      type: TxtFieldType.regis,
                      controller: password,
                      hint: "Password",
                      obscure: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: ElementColors.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    // Password Validation Checklist
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
                          SizedBox(height: 10),
                          Text(
                            'Password Strength:',
                            style: TextStyle(color: ElementColors.fontColor2),
                          ),
                          SizedBox(height: 5),
                          LinearProgressIndicator(
                            value: _passwordStrength,
                            backgroundColor: ElementColors.primary,
                            color: _passwordStrength > 0.75
                                ? Colors.green
                                : _passwordStrength > 0.5
                                ? Colors.yellow
                                : ElementColors.tertiary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: media.height * 0.02),
                    TxtField(
                      type: TxtFieldType.regis,
                      controller: rePassword,
                      hint: "Re-enter password",
                      obscure: _obscureRePassword,
                      keyboardType: TextInputType.visiblePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureRePassword ? Icons.visibility_off : Icons.visibility,
                          color: ElementColors.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureRePassword = !_obscureRePassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: media.height * 0.05),
                    SizedBox(
                      width: double.infinity,
                      child: Buttons(
                        title: "Sign Up",
                        type: BtnType.secondary,
                        fontSize: media.width * 0.04,
                        height: media.height * 0.065,
                        onClick: _signup,
                      ),
                    ),
                    SizedBox(height: media.height * 0.02),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: ElementColors.fontColor2,
                            thickness: 1,
                            endIndent: 10,
                          ),
                        ),
                        Text(
                          "or",
                          style: TextStyle(color: ElementColors.fontColor2),
                        ),
                        Expanded(
                          child: Divider(
                            color: ElementColors.fontColor2,
                            thickness: 1,
                            indent: 10,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: media.height * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: Buttons(
                        title: useEmail
                            ? "Sign up using contact number"
                            : "Sign up using email",
                        type: BtnType.tertiary,
                        fontSize: media.width * 0.04,
                        height: media.height * 0.065,
                        onClick: () {
                          setState(() {
                            useEmail = !useEmail;
                            email.clear();
                            contactNumber.clear();
                            password.clear();
                            rePassword.clear();
                          });
                        },
                      ),
                    ),
                    SizedBox(height: media.height * 0.03),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, CustomPageRoute(page: Login()));
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: ElementColors.fontColor2,
                            fontWeight: FontWeight.normal,
                            fontSize: media.width * 0.035,
                          ),
                          children: [
                            TextSpan(
                              text: "Log In",
                              style: TextStyle(
                                color: ElementColors.fontColor2,
                                fontWeight: FontWeight.bold,
                                fontSize: media.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : Colors.white,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : ElementColors.fontColor2,
          ),
        ),
      ],
    );
  }
}
