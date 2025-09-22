import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';

class TermsPopup extends StatefulWidget {
  final VoidCallback? onConfirmed; // make optional

  const TermsPopup({super.key, this.onConfirmed});

  @override
  State<TermsPopup> createState() => _TermsAndAgreementDialogState();
}

class _TermsAndAgreementDialogState extends State<TermsPopup> {
  bool _checked1 = false;
  bool _checked2 = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ElementColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (no close button anymore)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "TERMS AND AGREEMENT",
                style: TextStyle(
                  color: ElementColors.fontColor2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Terms (scrollable)
            SizedBox(
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _TermItem(
                      number: "1.",
                      title: "Accuracy of Information",
                      text:
                          "I hereby declare that all information provided in this application is true, correct, and complete to the best of my knowledge.",
                    ),
                    _TermItem(
                      number: "2.",
                      title: "Supporting Documents",
                      text:
                          "I understand that I am required to upload valid supporting documents, and that any falsified, tampered, or fraudulent documents may result in rejection of my application and possible legal consequences.",
                    ),
                    _TermItem(
                      number: "3.",
                      title: "Barangay Policies",
                      text:
                          "I agree to comply with all existing policies, requirements, and procedures set by the Barangay for the issuance of Barangay Clearance / ID.",
                    ),
                    _TermItem(
                      number: "4.",
                      title: "Data Privacy",
                      text:
                          "I understand that the personal information I provide will be collected, stored, and processed solely for identity verification and record-keeping, in compliance with RA 10173 (Data Privacy Act). The Barangay commits to keeping my data secure and confidential, and will not disclose it without my consent except as required by law.",
                    ),
                    _TermItem(
                      number: "5.",
                      title: "Acknowledgment",
                      text:
                          "I understand that the Barangay Clearance / ID is for identification purposes within the barangay and its partners, and it does not replace national IDs. Misuse of the Barangay Clearance / ID, or allowing others to use it, may result in confiscation or invalidation.",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Checkboxes
            CheckboxListTile(
              value: _checked1,
              onChanged: (val) => setState(() => _checked1 = val ?? false),
              title: Text(
                "I have read and understood the Terms and Agreement",
                style: TextStyle(color: ElementColors.fontColor2, fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: ElementColors.secondary,
              checkColor: Colors.white,
            ),
            CheckboxListTile(
              value: _checked2,
              onChanged: (val) => setState(() => _checked2 = val ?? false),
              title: Text(
                "I certify that the information provided is true and correct",
                style: TextStyle(color: ElementColors.fontColor2, fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: ElementColors.secondary,
              checkColor: Colors.white,
            ),

            const SizedBox(height: 8),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_checked1 && _checked2)
                  ? () {
                      Navigator.of(context, rootNavigator: true).pop(); // close only the popup
                      widget.onConfirmed?.call(); // let the parent decide what to do
                    }
                  : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor: ElementColors.secondary,
                  foregroundColor: Colors.white, 
                  disabledBackgroundColor: Colors.grey,
                  disabledForegroundColor: Colors.white70, // light text when disabled
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Term item widget
class _TermItem extends StatelessWidget {
  final String number;
  final String title;
  final String text;

  const _TermItem({
    required this.number,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number (like "1.")
          Text(
            number,
            style: TextStyle(
              color: ElementColors.fontColor2,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(width: 8),
          // Body text (title + description, indented + justified)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ElementColors.fontColor2,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: ElementColors.fontColor2,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

