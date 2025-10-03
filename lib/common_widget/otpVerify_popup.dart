// import 'package:elingkod/common_style/colors_extension.dart';
// import 'package:elingkod/common_widget/custom_pageRoute.dart';
// import 'package:elingkod/pages/profile_info.dart';
// import 'package:elingkod/services/auth_service.dart';
// import 'package:flutter/material.dart';

// class OtpverifyPopup extends StatefulWidget {
//   final String phoneNumber;
//   const OtpverifyPopup({super.key, required this.phoneNumber});

//   @override
//   State<OtpverifyPopup> createState() => _OtpverifyPopupState();
// }

// class _OtpverifyPopupState extends State<OtpverifyPopup> {
//   final TextEditingController _otpController = TextEditingController();

//   Future<void> _verifyOtp() async {
//     try {
//       await AuthService().verifyOtp(
//         phoneNumber: widget.phoneNumber,
//         token: _otpController.text.trim(),
//       );

//       // Dismiss the dialog
//       if (mounted) Navigator.of(context).pop();

//       // Navigate to the next screen on success
//       if (mounted) {
//         Navigator.push(
//           context,
//           CustomPageRoute(
//             page: ProfileInfo(),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('OTP Verification Failed: $e',
//           style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold)),
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: ElementColors.fontColor2),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Enter OTP', style: TextStyle(color: ElementColors.fontColor2)),
//       backgroundColor: ElementColors.tertiary,
//       content: TextField(
//         controller: _otpController,
//         style: TextStyle(color: ElementColors.fontColor2),
//         decoration: InputDecoration(
//           hintText: "Enter the code sent to your phone",
//           hintStyle: TextStyle(color: ElementColors.placeholder)
//         ),
//         keyboardType: TextInputType.number,
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text('Cancel', style: TextStyle(color: ElementColors.fontColor2)),
//         ),
//         TextButton(
//           onPressed: _verifyOtp,
//           child: Text('Verify', style: TextStyle(color: ElementColors.fontColor2)),
//         ),
//       ],
//     );
//   }
// }

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:elingkod/services/auth_service.dart';
import 'package:flutter/material.dart';

class OtpverifyPopup extends StatefulWidget {
  // We make both optional, but require at least one using an assert
  final String? phoneNumber;
  final String? email;
  final VoidCallback? onVerified;

  const OtpverifyPopup({
    super.key,
    this.phoneNumber,
    this.email,
    this.onVerified,
  }) : assert(phoneNumber != null || email != null, 'Either phoneNumber or email must be provided for verification.');

  @override
  State<OtpverifyPopup> createState() => _OtpverifyPopupState();
}

class _OtpverifyPopupState extends State<OtpverifyPopup> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> _verifyOtp() async {
    try {
      if (widget.email != null && widget.email!.isNotEmpty) {
        // --- EMAIL OTP VERIFICATION ---
        await AuthService().verifyOtp(
          email: widget.email,
          token: _otpController.text.trim(),
        );
      } else if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
        // --- PHONE OTP VERIFICATION ---
        await AuthService().verifyOtp(
          phoneNumber: widget.phoneNumber,
          token: _otpController.text.trim(),
        );
      } else {
        // This case should be caught by the assert, but remains for safety
        throw Exception("Verification target (email or phone) is missing.");
      }

      // Dismiss the dialog on success
      if (mounted) Navigator.of(context).pop();

      if (widget.onVerified != null) {
        widget.onVerified!();
      } else {
        if (mounted) {
          Navigator.push(
            context,
            CustomPageRoute(page: ProfileInfo()),
          );
        }
      }
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP Verification Failed: $e',
            style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.fontColor2,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the type of contact for the dynamic hint text
    final String target = widget.email != null ? 'email' : 'phone number';

    return AlertDialog(
      title: Text('Enter OTP', style: TextStyle(color: ElementColors.fontColor2)),
      backgroundColor: ElementColors.tertiary,
      content: TextField(
        controller: _otpController,
        style: TextStyle(color: ElementColors.fontColor2),
        decoration: InputDecoration(
          // Dynamic hint text
          hintText: "Enter the code sent to your $target",
          hintStyle: TextStyle(color: ElementColors.placeholder),
        ),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: TextStyle(color: ElementColors.fontColor2)),
        ),
        TextButton(
          onPressed: _verifyOtp,
          child: Text('Verify', style: TextStyle(color: ElementColors.fontColor2)),
        ),
      ],
    );
  }
}
