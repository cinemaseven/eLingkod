import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';

class BusinessClearancePopup extends StatefulWidget {
  final VoidCallback? onConfirmed; 
  

  const BusinessClearancePopup({super.key, this.onConfirmed});

  @override
  State<BusinessClearancePopup> createState() => _BusinessClearancePopupState();
}

class _BusinessClearancePopupState extends State<BusinessClearancePopup> {
  int _pageIndex = 0; // 0 = Important Info, 1 = Applicant Undertaking
  bool _checked = false;

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
            // Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _pageIndex == 0
                    ? "IMPORTANT INFORMATION"
                    : "APPLICANT UNDERTAKING",
                style: TextStyle(
                  color: ElementColors.fontColor2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Body
            SizedBox(
              height: 400,
              child: SingleChildScrollView(
                child: _pageIndex == 0
                    ? _buildImportantInfo()
                    : _buildApplicantUndertaking(),
              ),
            ),

            const SizedBox(height: 12),

            // Footer
            if (_pageIndex == 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _pageIndex = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElementColors.secondary,
                    foregroundColor: ElementColors.fontColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Next"),
                ),
              )
            else
              Column(
                children: [
                  CheckboxListTile(
                    value: _checked,
                    onChanged: (val) => setState(() => _checked = val ?? false),
                    title: Text(
                      "I have read and agreed to the Important Information & Applicant Undertaking",
                      style: TextStyle(color: ElementColors.fontColor2, fontSize: 13),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: ElementColors.secondary,
                    checkColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checked
                          ? () {
                              Navigator.pop(context); // close popup
                              widget.onConfirmed?.call();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ElementColors.secondary,
                        foregroundColor: ElementColors.fontColor2,
                        disabledBackgroundColor: Colors.grey,
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Confirm"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 First Page
  Widget _buildImportantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _BulletItem(
          text:
              "1. The Barangay may reject applications if:\nA. Required fields are not filled out or writing is unclear.\nB. Documents are incomplete or do not meet requirements.\nC. False information is provided.\nD. Altered or fake documents are submitted.",
        ),
        _BulletItem(
          text:
              "2. The Barangay will check and may verify the details of the application and attached documents. Any irregularities or dealings with unauthorized personnel will not be accepted.",
        ),
        _BulletItem(
          text:
              "3. Depending on the size and type of business, the Barangay may forward the application to the Barangay Council for further review during Barangay Sessions. Processing will follow Barangay rules and procedures.",
        ),
        _BulletItem(
          text:
              "4. Inspections may be done at random times. If the owner, manager, employee, or representative refuses entry to inspectors at a reasonable time, the application will be denied.",
        ),
        _BulletItem(
          text:
              "5. Penalties for not renewing Barangay Clearance: 25% of total taxes and service fees (including penalties and surcharges) plus a 2% monthly surcharge until payment is completed.",
        ),
        _BulletItem(
          text:
              "6. The Barangay may also ask for additional documents if needed.",
        ),
      ],
    );
  }

  // 🔹 Second Page
  Widget _buildApplicantUndertaking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "By completing and signing this form, I/We agree to follow all laws, regulations, conditions, and policies set by the Barangay and other government agencies related to the proper operation of our commercial/industrial business. I/We also acknowledge and agree to the following:",
          textAlign: TextAlign.justify,
          style: TextStyle(color: ElementColors.fontColor2, height: 1.4),
        ),
        SizedBox(height: 12),
        _BulletItem(text: "1. Not to cause harm or disturbance to the public."),
        _BulletItem(
            text:
                "2. To allow the Barangay, its officials, and authorized personnel to inspect our business premises during reasonable hours without delay."),
        _BulletItem(
            text:
                "3. That all information provided in this form, including attached documents, is true and correct to the best of our knowledge."),
        _BulletItem(
            text:
                "4. That the Barangay may impose sanctions such as non-renewal, disapproval, revocation, or suspension of our clearance if we fail to comply with rules, regulations, or this undertaking."),
        _BulletItem(
            text:
                "5. That compliance with this undertaking shall also apply to company members, employees, representatives, heirs, affiliates, and third parties acting on behalf of our business."),
      ],
    );
  }
}

// 🔹 Reusable Bullet Item
class _BulletItem extends StatelessWidget {
  final String text;
  final int indentLevel; // 0 = main item, 1 = sub-item

  const _BulletItem({
    required this.text,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Detect prefix (1., 2., A., B., etc.)
    final match = RegExp(r'^\d+\.\s*|^[A-Z]\.\s*').firstMatch(text);
    final prefix = match?.group(0) ?? "";
    final body = text.replaceFirst(prefix, "");

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: indentLevel * 20.0, // add extra space for sub-items
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prefix (number or letter)
          Text(
            prefix,
            style: TextStyle(
              color: ElementColors.fontColor2,
              height: 1.4,
            ),
          ),
          const SizedBox(width: 6),
          // Body text (justified, wraps nicely)
          Expanded(
            child: Text(
              body,
              textAlign: TextAlign.justify,
              style: TextStyle(color: ElementColors.fontColor2, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

