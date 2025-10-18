import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/otpVerify_popup.dart';
import 'package:elingkod/pages/login.dart';
import 'package:elingkod/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  bool useEmail = true;
  bool _obscurePassword = true;
  bool _obscureRePassword = true;

  // Initialize the TextEditingControllers
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();

  // Map for validation status
  Map<String, bool> _validationStatus = {
    'isLengthValid': false,
    'hasUppercase': false,
    'hasLowercase': false,
    'hasNumber': false,
  };

  // Adds a listener to monitor password validation
  @override
  void initState() {
    super.initState();
    password.addListener(_checkPasswordValidation);
  }

  // Removes listeners and disposes controllers
  @override
  void dispose() {
    password.removeListener(_checkPasswordValidation);
    password.dispose();
    email.dispose();
    phoneNumber.dispose();
    rePassword.dispose();
    super.dispose();
  }

  // Function call to check if password is valid
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

  // Returns password strength value
  double get _passwordStrength {
    int score = 0;
    if (_validationStatus['isLengthValid']!) score++;
    if (_validationStatus['hasUppercase']!) score++;
    if (_validationStatus['hasLowercase']!) score++;
    if (_validationStatus['hasNumber']!) score++;
    return score / 4.0;
  }

  // Validates that the input field is not empty
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Handles the signup process
  Future<void> _signup() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_formKey.currentState!.validate()) {
      try {
        if (useEmail) {
          // Sign up with email
          await AuthService().signUp(
            email: email.text.trim(),
            password: password.text,
          );
          
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Verification code sent to your email!', 
                style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold)),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ElementColors.fontColor2,
            ),
          );
          // Show OTP dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return OtpverifyPopup(email: email.text.trim());
            },
          );

        } else {
          // Sign up with phone number
          await AuthService().signUp(
            phoneNumber: phoneNumber.text.trim(),
            password: password.text,
          );
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('OTP sent to your phone number!',
                style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold)),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ElementColors.fontColor2,
            ),
          );
          // Show OTP dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return OtpverifyPopup(phoneNumber: phoneNumber.text.trim());
            },
          );
        }
      } on AuthException catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Auth Error: ${e.message}',
              style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.fontColor2,
          ),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e',
              style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.fontColor2,
          ),
        );
      }
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
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: media.height * 0.02),
              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  width: media.width * 0.5,
                ),
              ),
              SizedBox(height: media.height * 0.03),
              Container(
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
                      // Email field
                      if (useEmail)
                        TxtField(
                          type: TxtFieldType.regis,
                          controller: email,
                          hint: "Email (e.g., example@gmail.com)",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final requiredError = _requiredValidator(value);
                            if (requiredError != null) return requiredError;
                            if (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value!)) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        )
                      else
                        // Phone number field
                        TxtField(
                          type: TxtFieldType.regis,
                          controller: phoneNumber,
                          hint: "Contact Number (e.g., 0928xxxxxxx)",
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final requiredError = _requiredValidator(value);
                            if (requiredError != null) return requiredError;
                            if (value!.length != 11) {
                              return 'Contact number must be 11 digits';
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: media.height * 0.02),
                      // Password field
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
                        validator: (value) {
                          final requiredError = _requiredValidator(value);
                          if (requiredError != null) return requiredError;
                          if (!_validationStatus.values.every((element) => element)) {
                            return 'Please meet all password requirements';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // Displays password strength requirements
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
                      // Re-enter password field
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
                        validator: (value) {
                          final requiredError = _requiredValidator(value);
                          if (requiredError != null) return requiredError;
                        
                          if (value != password.text) {
                            return 'Passwords do no match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: media.height * 0.05),
                      // Signup button
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
                      // Buttons for other signup options
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
                              phoneNumber.clear();
                              password.clear();
                              rePassword.clear();
                            });
                          },
                        ),
                      ),
                      SizedBox(height: media.height * 0.03),
                      // Login text
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
            ],
          ),
        ),
      ),
    );
  }

  // Builds a row showing a validation indicator
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