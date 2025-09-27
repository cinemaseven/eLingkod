import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:elingkod/services/auth_service.dart';
import 'package:flutter/material.dart';

class OtpverifyPopup extends StatefulWidget {
  final String phoneNumber;
  const OtpverifyPopup({super.key, required this.phoneNumber});

  @override
  State<OtpverifyPopup> createState() => _OtpverifyPopupState();
}

class _OtpverifyPopupState extends State<OtpverifyPopup> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> _verifyOtp() async {
    try {
      await AuthService().verifyOtp(
        phoneNumber: widget.phoneNumber,
        token: _otpController.text.trim(),
      );

      // Dismiss the dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to the next screen on success
      if (mounted) {
        Navigator.push(
          context,
          CustomPageRoute(
            page: ProfileInfo(
              emailOrContact: widget.phoneNumber,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP Verification Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter OTP'),
      backgroundColor: ElementColors.primary,
      content: TextField(
        controller: _otpController,
        decoration: const InputDecoration(
          hintText: "Enter the code sent to your phone",
        ),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _verifyOtp,
          child: const Text('Verify'),
        ),
      ],
    );
  }
}