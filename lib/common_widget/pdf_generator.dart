import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfFormGenerator {
  /// === PUBLIC FUNCTIONS ===

  static Future<void> generateBarangayClearance() async {
    await _generateBlankForm(
      title: "BARANGAY CLEARANCE APPLICATION FORM",
      sections: {
        "APPLICATION DETAILS": [
          "Application Date / Clearance Number",
          "Residency Type (radio)",
        ],
        "PERSONAL INFORMATION": [
          "Full Name (LFM)",
          "Gender (radio) / Age",
          "Civil Status (radio)",
          "Date of Birth / Place of Birth",
          "Nationality / Contact Number / Email",
        ],
        "RESIDENTIAL ADDRESS": [
          "House Number / Street",
          "City / Province / Zip Code",
        ],
        "PURPOSE": [
          "Clearance Purpose",
        ],
      },
    );
  }

  static Future<void> generateBarangayId() async {
    await _generateBlankForm(
      title: "BARANGAY IDENTIFICATION CARD APPLICATION",
      sections: {
        "PERSONAL INFORMATION": [
          "Full Name",
          "Gender (radio) / Age",
          "Date of Birth / Nationality",
          "Contact Number / Email Address",
        ],
        "ADDRESS": [
          "House Number / Street",
          "City / Province / Zip Code",
        ],
        "PURPOSE": [
          "ID Purpose (checkbox)",
        ],
      },
    );
  }

  static Future<void> generateBusinessClearance() async {
    await _generateBlankForm(
      title: "BARANGAY BUSINESS CLEARANCE",
      sections: {
        "BUSINESS INFORMATION": [
          "Application Type (radio) / Clearance Number",
          "Complete Business Name",
          "Business Type / Nature of Business",
          "Business Ownership Type (radio) / Business Location Status (radio)",
        ],
        "BUSINESS ADDRESS": [
          "House/Unit Number / Building/Unit Number",
          "Street / Village / Zip Code",
        ],
        "OTHER BUSINESS INFORMATION": [
          "Establishment Total Area / Capitalization (PHP)",
          "Gross Sales (Precedent Year)",
          "Business Owner/Manager / Contact Number / Email Address",
        ],
      },
    );
  }

  /// === PRIVATE CORE ===
  static Future<void> _generateBlankForm({
    required String title,
    required Map<String, List<String>> sections,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            ...sections.entries.expand((entry) => [
                  pw.Text(entry.key,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  ...entry.value.map((field) => _formRow(field)),
                  pw.SizedBox(height: 15),
                ]),

            // === SUPPORTING DOCUMENTS SECTION ===
            if (title.contains("IDENTIFICATION CARD")) ...[
              pw.SizedBox(height: 25),
              pw.Text("SUPPORTING DOCUMENTS:",
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Bullet(text: "Valid ID", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "Proof of Residency", style: const pw.TextStyle(fontSize: 10)),
            ],

            if (title.contains("BUSINESS CLEARANCE")) ...[
              pw.SizedBox(height: 25),
              pw.Text("SUPPORTING DOCUMENTS:",
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Bullet(text: "D.T.I Certificate (for Single Proprietor)", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "S.E.C Certificate (for Partnership or Corporation)", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "Cooperative Development Authority Certificate (for Cooperative)", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "Previous Barangay Clearance (for Renewal Application)", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "Land Title / Tax Declaration (must be under the name of land owner/lessor)", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "Duly Notarized Contracts and/or Agreements", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "4R Format Full-View Establishment Picture", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "2x2 Owner Picture", style: const pw.TextStyle(fontSize: 10)),
              pw.Bullet(text: "Association Endorsement", style: const pw.TextStyle(fontSize: 10)),
            ],

            pw.SizedBox(height: 30),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _signatureBox("Applicant Signature over Printed Name"),
                _signatureBox("Barangay Captain Signature"),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// === FORM ROW HANDLER ===
  static pw.Widget _formRow(String label) {
    switch (label) {
      /// Barangay Clearance
      case "Application Date / Clearance Number":
        return _gridRow([
          {"Application Date": 1},
          {"Clearance Number": 2},
        ]);
      case "Residency Type (radio)":
        return _radioRow("Residency Type", ["Own", "Rent"], span: 3);
      case "Full Name (LFM)":
        return _gridRow([
          {"Last Name": 1},
          {"First Name": 1},
          {"Middle Initial": 1},
        ]);
      case "Gender (radio) / Age":
        return _gridRow([
          {"Gender": 2},
          {"Age": 1},
        ]);
      case "Civil Status (radio)":
        return _radioRow(
            "Civil Status", ["Single", "Married", "Widowed", "Separated"],
            span: 3);
      case "Clearance Purpose":
        return _gridRow([
          {"Clearance Purpose": 3},
        ]);

      /// Barangay ID
      case "Full Name":
        return _gridRow([
          {"Last Name": 1},
          {"First Name": 1},
          {"Middle Name": 1},
        ]);
      case "Gender (radio) / Age":
        return _gridRow([
          {"Gender": 2},
          {"Age": 1},
        ]);
      case "Date of Birth / Nationality":
        return _gridRow([
          {"Date of Birth": 1},
          {"Nationality": 2},
        ]);
      case "Contact Number / Email Address":
        return _gridRow([
          {"Contact Number": 1},
          {"Email Address": 2},
        ]);
      case "ID Purpose (checkbox)":
        return _checkboxColumn("ID Purpose", [
          "Employment",
          "School",
          "General Use",
          "Other: __________________________",
        ]);

      /// Business Clearance
      case "Application Type (radio) / Clearance Number":
        return _gridRow([
          {"Application Type": 2},
          {"Clearance Number": 1},
        ]);
      case "Complete Business Name":
        return _gridRow([
          {"Complete Business Name": 3},
        ]);
      case "Business Type / Nature of Business":
        return _gridRow([
          {"Business Type": 1},
          {"Nature of Business": 2},
        ]);
      case "Business Ownership Type (radio) / Business Location Status (radio)":
        return _gridRow([
          {"Ownership Type": 2},
          {"Location Status": 1},
        ]);
      case "Establishment Total Area / Capitalization (PHP)":
        return _gridRow([
          {"Total Area": 1},
          {"Capitalization (PHP)": 2},
        ]);
      case "Business Owner/Manager / Contact Number / Email Address":
        return _gridRow([
          {"Owner/Manager": 1},
          {"Contact No.": 1},
          {"Email": 1},
        ]);

      /// Shared fields
      case "Date of Birth / Place of Birth":
        return _gridRow([
          {"Date of Birth": 1},
          {"Place of Birth": 2},
        ]);
      case "Nationality / Contact Number / Email":
        return _gridRow([
          {"Nationality": 1},
          {"Contact No.": 1},
          {"Email": 1},
        ]);
      case "House Number / Street":
        return _gridRow([
          {"House Number": 1},
          {"Street": 2},
        ]);
      case "City / Province / Zip Code":
        return _gridRow([
          {"City": 1},
          {"Province": 1},
          {"Zip Code": 1},
        ]);
      case "House/Unit Number / Building/Unit Number":
        return _gridRow([
          {"House/Unit No.": 1},
          {"Building/Unit No.": 2},
        ]);
      case "Street / Village / Zip Code":
        return _gridRow([
          {"Street/Avenue": 1},
          {"Village/Subdivision": 1},
          {"Zip Code": 1},
        ]);

      default:
        return _gridRow([
          {label: 3}
        ]);
    }
  }

  /// === GRID HELPERS ===
  static pw.Widget _gridRow(List<Map<String, int>> fields) {
    const totalWidth = 420.0;
    const unitWidth = totalWidth / 3;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: fields.map((f) {
        final label = f.keys.first;
        final span = f.values.first;
        return _labeledBoxOrSpecial(label, unitWidth * span);
      }).toList(),
    );
  }

  static pw.Widget _labeledBoxOrSpecial(String label, double width) {
    switch (label) {
      case "Residency Type":
        return _radioRow("Residency Type", ["Own", "Rent"], width: width);
      case "Gender":
        return _radioRow("Gender", ["Male", "Female"], width: width);
      case "Civil Status":
        return _radioRow(
            "Civil Status", ["Single", "Married", "Divorced", "Widowed", "Separated"],
            width: width);
      case "Application Type":
        return _radioRow("Application Type",
            ["New Application", "Renewal Application", "Temporary"],
            width: width);
      case "Ownership Type":
        return _radioRow("Ownership Type",
            ["Single Proprietor", "Partnership", "Corporation", "Cooperative"],
            width: width, column: true);
      case "Location Status":
        return _radioRow("Location Status", ["Owned", "Rented", "Free Lease"],
            width: width, column: true);
      default:
        return _labeledLine(label, width);
    }
  }

  /// === LABELED LINE ===
  static pw.Widget _labeledLine(String subLabel, double width) {
    return pw.Container(
      width: width,
      margin: const pw.EdgeInsets.only(bottom: 12, right: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(subLabel, style: const pw.TextStyle(fontSize: 9)),
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 4),
            child: pw.Divider(
              thickness: 1,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// === RADIO ROW ===
  static pw.Widget _radioRow(String label, List<String> options,
      {double width = 420, bool column = false, int span = 1}) {
    return pw.Container(
      width: width,
      margin: const pw.EdgeInsets.only(bottom: 8, right: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          column
              ? pw.Column(
                  children: options
                      .map((opt) => pw.Row(
                            children: [
                              pw.Container(
                                width: 8,
                                height: 8,
                                decoration: pw.BoxDecoration(
                                  shape: pw.BoxShape.circle,
                                  border: pw.Border.all(width: 1),
                                ),
                              ),
                              pw.SizedBox(width: 5),
                              pw.Text(opt,
                                  style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ))
                      .toList(),
                )
              : pw.Row(
                  children: options
                      .map((opt) => pw.Row(
                            children: [
                              pw.Container(
                                width: 8,
                                height: 8,
                                decoration: pw.BoxDecoration(
                                  shape: pw.BoxShape.circle,
                                  border: pw.Border.all(width: 1),
                                ),
                              ),
                              pw.SizedBox(width: 5),
                              pw.Text(opt,
                                  style: const pw.TextStyle(fontSize: 9)),
                              pw.SizedBox(width: 15),
                            ],
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  /// === CHECKBOX COLUMN ===
  static pw.Widget _checkboxColumn(String label, List<String> options) {
    return pw.Container(
      width: 420,
      margin: const pw.EdgeInsets.only(bottom: 8, right: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          ...options.map((opt) => pw.Row(
                children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(opt, style: const pw.TextStyle(fontSize: 9)),
                ],
              )),
        ],
      ),
    );
  }

  /// === SIGNATURE BOX ===
  static pw.Widget _signatureBox(String label) {
    return pw.Column(
      children: [
        pw.Container(
          height: 50,
          width: 150,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}
