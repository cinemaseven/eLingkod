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
  bool useEmail = true;

  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();

  @override
  void dispose() {
    password.dispose();
    email.dispose();
    phoneNumber.dispose();
    rePassword.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Step 1 → Request OTP
  Future<void> _requestOtp() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (useEmail) {
        await AuthService().sendOtp(email: email.text.trim());
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Verification code sent to your email!',
              style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
          ),
        );
        showDialog(
          context: context,
          builder: (_) => OtpverifyPopup(
            email: email.text.trim(),
            onVerified: () {
              Navigator.pushReplacement(context,
              CustomPageRoute(page: const ChangePassword()));
            },
          ),
        );
      } else {
        await AuthService().sendOtp(phoneNumber: phoneNumber.text.trim());
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'OTP sent to your phone number!',
              style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
          ),
        );
        showDialog(
          context: context,
          builder: (_) => OtpverifyPopup(
            phoneNumber: phoneNumber.text.trim(),
            onVerified: () {
              Navigator.pushReplacement(context,
              CustomPageRoute(page: const ChangePassword()));
            },
          ),
        );
      }
    } on AuthException catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Auth Error: ${e.message}',
            style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary
      ));
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
                // OTP Request Fields
                Column(
                  children: [
                    if (useEmail)
                      TxtField(
                        type: TxtFieldType.services,
                        label: "Enter your email:",
                        controller: email,
                        hint: "Email (e.g., example@gmail.com)",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final requiredError = _requiredValidator(value);
                          if (requiredError != null) return requiredError;
                          if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value!)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      )
                    else
                      TxtField(
                        type: TxtFieldType.services,
                        label: "Enter your contact number:",
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
                    SizedBox(height: media.height * 0.035),
                    Buttons(
                      title: "Send OTP",
                      type: BtnType.secondary,
                      fontSize: media.width * 0.035,
                      width: media.width * 0.7,
                      height: media.height * 0.05,
                      onClick: _requestOtp,
                    ),
                    const SizedBox(height: 20),
                    Buttons(
                      title: useEmail
                          ? "Change Using Contact Number"
                          : "Change Using Email",
                      type: BtnType.tertiary,
                      fontSize: media.width * 0.035,
                      width: media.width * 0.7,
                      height: media.height * 0.05,
                      onClick: () {
                        setState(() {
                          useEmail = !useEmail;
                          email.clear();
                          phoneNumber.clear();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:elingkod/common_style/colors_extension.dart';
// import 'package:elingkod/common_widget/buttons.dart';
// import 'package:elingkod/common_widget/custom_pageRoute.dart';
// import 'package:elingkod/common_widget/form_fields.dart';
// import 'package:elingkod/common_widget/otpVerify_popup.dart';
// import 'package:elingkod/pages/change_password.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ForgotPassword extends StatefulWidget {
//   const ForgotPassword({super.key});

//   @override
//   State<ForgotPassword> createState() => _ForgotPasswordState();
// }

// class _ForgotPasswordState extends State<ForgotPassword> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController inputController = TextEditingController();

//   String? _asyncError; // store async validation messages

//   @override
//   void dispose() {
//     inputController.dispose();
//     super.dispose();
//   }

//   String? _requiredValidator(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'This field is required';
//     }
//     // also show async errors if present
//     if (_asyncError != null) {
//       final msg = _asyncError;
//       _asyncError = null; // clear after showing once
//       return msg;
//     }
//     return null;
//   }

// Future<void> _requestOtp() async {
//   final supabase = Supabase.instance.client;
//   var input = inputController.text.trim();

//   // 🔹 Normalize phone input → 639 format
//   String normalizePhone(String value) {
//     if (value.startsWith('+63')) {
//       return value.substring(1); // +639 → 639
//     } else if (value.startsWith('09')) {
//       return '63${value.substring(1)}'; // 09 → 639
//     } else {
//       return value;
//     }
//   }

//   final normalizedInput = normalizePhone(input);
//   print('🔍 Checking for user: input=$input | normalized=$normalizedInput');

//   try {
//     // 🔹 Step 1 → Lookup user in user_details (case-insensitive email match)
//     final userDetails = await supabase
//         .from('user_details')
//         .select('user_id, email, contactNumber')
//         .or('email.ilike.$input,contactNumber.eq.$input,contactNumber.eq.$normalizedInput')
//         .maybeSingle();

//     print('📄 user_details result: $userDetails');

//     if (userDetails == null) {
//       setState(() {
//         _asyncError = 'No account found for that email or phone number.';
//       });
//       _formKey.currentState!.validate();
//       return;
//     }

//     final userId = userDetails['user_id'];
//     print('✅ Found user_id: $userId');

//     // 🔹 Step 2 → Lookup auth data from your view
//     final authUser = await supabase
//         .from('auth_user_view')
//         .select('email, phone')
//         .eq('user_id', userId)
//         .maybeSingle();

//     print('📄 auth_user_view result: $authUser');

//     if (authUser == null) {
//       setState(() {
//         _asyncError = 'Error: account not found in authentication view.';
//       });
//       _formKey.currentState!.validate();
//       return;
//     }

//     final registeredEmail = authUser['email'] as String?;
//     final registeredPhone = authUser['phone'] as String?;

//     print('📧 Registered email: $registeredEmail | 📱 Registered phone: $registeredPhone');

//     // 🔹 Step 3 → Handle based on registration method
//     if (registeredEmail != null && registeredEmail.isNotEmpty) {
//       // User registered with email
//       if (input.toLowerCase() != registeredEmail.toLowerCase()) {
//         setState(() {
//           _asyncError =
//               'This account was registered with your email: $registeredEmail.\nPlease use that email to reset your password.';
//         });
//         _formKey.currentState!.validate();
//         return;
//       }

//       // ✅ Send OTP via email
//       await supabase.auth.resetPasswordForEmail(registeredEmail);
//       showDialog(
//         context: context,
//         builder: (_) => OtpverifyPopup(
//           email: registeredEmail,
//           onVerified: () {
//             Navigator.pushReplacement(
//               context,
//               CustomPageRoute(page: const ChangePassword()),
//             );
//           },
//         ),
//       );
//       return;
//     }

//     if (registeredPhone != null && registeredPhone.isNotEmpty) {
//       // User registered with phone
//       if (normalizedInput != registeredPhone &&
//           '+$normalizedInput' != registeredPhone &&
//           input != registeredPhone) {
//         setState(() {
//           _asyncError =
//               'This account was registered with your phone number: +$registeredPhone.\nPlease use that number to reset your password.';
//         });
//         _formKey.currentState!.validate();
//         return;
//       }

//       // ✅ Send OTP via phone
//       await supabase.auth.signInWithOtp(phone: '+$registeredPhone');
//       showDialog(
//         context: context,
//         builder: (_) => OtpverifyPopup(
//           phoneNumber: '+$registeredPhone',
//           onVerified: () {
//             Navigator.pushReplacement(
//               context,
//               CustomPageRoute(page: const ChangePassword()),
//             );
//           },
//         ),
//       );
//       return;
//     }

//     // 🔹 Fallback
//     setState(() {
//       _asyncError = 'Error: this account has no valid login method.';
//     });
//     _formKey.currentState!.validate();
//   } on AuthException catch (e) {
//     print('⚠️ AuthException: ${e.message}');
//     setState(() {
//       _asyncError = 'Auth Error: ${e.message}';
//     });
//     _formKey.currentState!.validate();
//   } catch (e) {
//     print('❌ Unexpected error: $e');
//     setState(() {
//       _asyncError = 'Unexpected error: $e';
//     });
//     _formKey.currentState!.validate();
//   }
// }



//   @override
//   Widget build(BuildContext context) {
//     var media = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: ElementColors.fontColor2,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: ElementColors.primary,
//         iconTheme: IconThemeData(color: ElementColors.fontColor2),
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 50),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: ElementColors.tertiary,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       "Reset Your Password",
//                       style: TextStyle(
//                         fontSize: media.height * 0.033,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: media.height * 0.03),

//                 // Single input field (email OR phone)
//                 TxtField(
//                   type: TxtFieldType.services,
//                   label: "Enter your email or phone number:",
//                   controller: inputController,
//                   hint: "e.g., example@gmail.com or 0928xxxxxxx",
//                   keyboardType: TextInputType.text,
//                   validator: _requiredValidator,
//                 ),

//                 SizedBox(height: media.height * 0.035),
//                 Buttons(
//                   title: "Send OTP",
//                   type: BtnType.secondary,
//                   fontSize: media.width * 0.035,
//                   width: media.width * 0.7,
//                   height: media.height * 0.05,
//                   onClick: () {
//                     if (_formKey.currentState!.validate()) {
//                       _requestOtp();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
