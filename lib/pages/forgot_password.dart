import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/otpVerify_popup.dart';
import 'package:elingkod/pages/change_password.dart';
import 'package:elingkod/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController inputController = TextEditingController();

  String? _wrongMethodMsg; // Inline error message

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Fetch user by email first, then phone if not found
  Future<Map<String, dynamic>?> _getUserDetails(String input) async {
    final supabase = Supabase.instance.client;

    // Try fetching by email
    final emailResult = await supabase
        .from('user_details')
        .select('user_id, email, contactNumber, signUp_method')
        .eq('email', input)
        .maybeSingle();

    if (emailResult != null) return emailResult;

    // Try fetching by phone
    final phoneResult = await supabase
        .from('user_details')
        .select('user_id, email, contactNumber, signUp_method')
        .eq('contactNumber', input)
        .maybeSingle();

    return phoneResult; // may be null
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final input = inputController.text.trim();
    final scaffold = ScaffoldMessenger.of(context);

    try {
      final userDetails = await _getUserDetails(input);

      if (userDetails == null) {
        setState(() {
          _wrongMethodMsg = 'No account found with that email or phone number.';
        });
        return;
      }

      final signupMethod = userDetails['signUp_method'];
      final registeredEmail = userDetails['email'];
      final registeredPhone = userDetails['contactNumber'];
      final isEmailInput = input.contains('@');

      if (isEmailInput && signupMethod == 'phone') {
        setState(() {
          _wrongMethodMsg =
              'This account was registered with your phone number: $registeredPhone. Please use that number to reset your password.';
        });
        return;
      } else if (!isEmailInput && signupMethod == 'email') {
        setState(() {
          _wrongMethodMsg =
              'This account was registered with your email: $registeredEmail. Please use that email to reset your password.';
        });
        return;
      }

      // Send OTP
      if (signupMethod == 'email') {
        await AuthService().sendOtp(email: registeredEmail);
        scaffold.showSnackBar(
          SnackBar(
            content: const Text('Verification code sent to your email!'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary,
          ),
        );

        showDialog(
          context: context,
          builder: (_) => OtpverifyPopup(
            email: registeredEmail,
            onVerified: () {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const ChangePassword()),
              );
            },
          ),
        );
      } else {
        await AuthService().sendOtp(phoneNumber: registeredPhone);
        scaffold.showSnackBar(
          SnackBar(
            content: const Text('OTP sent to your phone number!'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary,
          ),
        );

        showDialog(
          context: context,
          builder: (_) => OtpverifyPopup(
            phoneNumber: registeredPhone,
            onVerified: () {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const ChangePassword()),
              );
            },
          ),
        );
      }
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary,
        ),
      );
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
                      "Reset Your Password",
                      style: TextStyle(
                        fontSize: media.height * 0.033,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.height * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: media.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TxtField(
                        type: TxtFieldType.services,
                        label: "Email or Phone:",
                        controller: inputController,
                        hint: "example@gmail.com OR 09xx xxx xxxx",
                        validator: _requiredValidator,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: media.height * 0.01),
                      if (_wrongMethodMsg != null)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: media.width * 0.08),
                          child: Text(
                            _wrongMethodMsg!,
                            style: TextStyle(
                              color: ElementColors.tertiary,
                              fontSize: media.width * 0.03,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: media.height * 0.02),
                Buttons(
                  title: "Send OTP",
                  type: BtnType.secondary,
                  fontSize: media.width * 0.035,
                  width: media.width * 0.4,
                  height: media.height * 0.05,
                  onClick: () {
                    setState(() {
                      _wrongMethodMsg = null; // clear previous
                    });
                    if (_formKey.currentState!.validate()) {
                      _requestOtp();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}