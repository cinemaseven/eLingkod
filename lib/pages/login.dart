import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/pages/forgot_password.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/signup.dart';
import 'package:elingkod/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool useEmail = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Initialize the TextEditingControllers
  final TextEditingController email = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController password = TextEditingController();

  // Validates that the input field is not empty
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

void _login() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true; // Start loading
      });
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      // Determine which credential to use
      final String credential = useEmail 
          ? email.text.trim() 
          : contactNumber.text.trim();
      final String userPassword = password.text.trim();

      try {
        await _authService.signInWithCredentials(
          emailOrPhone: credential,
          password: userPassword,
        );

        // Success: Supabase session is established.
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Login successful!',
            style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary
          ),
          
        );

        // Navigate to the HomePage. The AuthWrapper ensures correct landing 
        Navigator.of(context).pushReplacement(
          CustomPageRoute(page: const Home()),
        );

      } on AuthException catch (e) {
        // Handle Supabase specific errors (e.g., Invalid credentials, User not found)
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Login Failed: ${e.message}',
              style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
          ),
        );
      } catch (e) {
        // Handle unexpected errors
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred.',
              style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Stop loading, even if an error occurred
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
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
                        "Log In",
                        style: TextStyle(
                          fontSize: media.width * 0.08 > 32
                              ? 32
                              : media.width * 0.08,
                          color: ElementColors.fontColor2,
                        ),
                      ),
                      SizedBox(height: media.height * 0.04),
                      // Email / Phone number field
                      TxtField(
                        type: TxtFieldType.regis,
                        controller: useEmail ? email : contactNumber,
                        hint: useEmail ? "Email (e.g., example@gmail.com)" : "Contact Number (e.g., 0928xxxxxxx)",
                        keyboardType: useEmail
                            ? TextInputType.emailAddress
                            : TextInputType.number,
                        validator: (value) {
                          final requiredError = _requiredValidator(value);
                          if (requiredError != null) return requiredError;
                          // Specific format validation.
                          if (useEmail && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!)) {
                            return 'Please enter a valid email address.';
                          }
                          if (!useEmail && value!.length != 11) {
                            return 'Contact number must be 11 digits.';
                          }
              
                          return null;
                        },
                      ),
                      // Password field
                      SizedBox(height: media.height * 0.02),
                      TxtField(
                        type: TxtFieldType.regis,
                        controller: password,
                        hint: "Password",
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
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: _requiredValidator,
                      ),
                      // Forgot password that navigates to reset password page when clicked
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRoute(page: ForgotPassword()),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: ElementColors.fontColor2,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: media.height * 0.05),
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: Buttons(
                          title: "Log In",
                          type: BtnType.secondary,
                          fontSize: media.width * 0.04,
                          height: media.height * 0.065,
                          onClick: _login,
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
                        // Buttons for login options
                        child: Buttons(
                          title: useEmail
                              ? "Log in using contact number"
                              : "Log in using email",
                          type: BtnType.tertiary,
                          fontSize: media.width * 0.04,
                          height: media.height * 0.065,
                          onClick: () {
                            setState(() {
                              useEmail = !useEmail;
                              email.clear();
                              contactNumber.clear();
                              password.clear();
                            });
                          },
                        ),
                      ),
                      SizedBox(height: media.height * 0.03),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(page: const Signup()),
                          );
                        },
                        // Signup text
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: ElementColors.fontColor2,
                              fontSize: media.width * 0.035,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
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
      ),
    );
  }
}