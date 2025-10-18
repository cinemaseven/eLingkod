import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/pages/request_status.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double responsiveFont(double base) => base * (size.width / 390);
    double responsiveHeight(double base) => base * (size.height / 844);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: ElementColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Image.asset(
              "assets/images/logo.png",
              height: responsiveHeight(100),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              "You have successfully\nsubmitted your request form!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ElementColors.fontColor2,
                fontWeight: FontWeight.bold,
                fontSize: responsiveFont(25),
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              "Thank you for taking the time to fill out the form. "
              "We truly appreciate it and will keep you updated "
              "on the progress of your request.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ElementColors.fontColor2,
                fontSize: responsiveFont(15),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),

            // Check Request Status Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    CustomPageRoute(page: const RequestStatusPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElementColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Check Request Status"),
              ),
            ),
            const SizedBox(height: 12),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // just close the popup
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElementColors.tertiary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
