import 'package:elingkod/common_style/colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisplayrequestDetails extends StatefulWidget {
  final int requestId;
  final String requestType;

  const DisplayrequestDetails({
    super.key,
    required this.requestId,
    required this.requestType,
  });

  @override
  State<DisplayrequestDetails> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<DisplayrequestDetails> {
  final SupabaseClient supabase = Supabase.instance.client;

  Map<String, dynamic>? _requestData;
  bool _loading = true;

  final Map<String, Map<String, String>> fieldLabels = {
    "barangay_id_request": {
      "applicationDate": "Application Date",
      "fullName": "Full Name",
      "birthDate": "Date of Birth",
      "gender": "Gender",
      "age": "Age",
      "contactNumber": "Contact Number",
      "email": "Email",
      "houseNum": "House Number",
      "street": "Street",
      "city": "City",
      "province": "Province",
      "zipCode": "Zip Code",
      "idPurpose": "ID Purpose",
      "validImageURL": "Valid ID",
      "residencyImageURL": "Proof of Residency",
      "signatureImageURL": "Applicant Signature over Printed Name"
    },
    "barangay_clearance_request": {
      "applicationDate": "Application Date",
      "residencyType": "Residency Type",
      "lengthStay": "Length of Stay",
      "clearanceNum": "Clearance Number",
      "fullName": "Full Name",
      "gender": "Gender",
      "houseNum": "House Number",
      "street": "Street",
      "city": "City",
      "province": "Province",
      "zipCode": "Zip Code",
      "birthDate": "Date of Birth",
      "age": "Age",
      "contactNumber": "Contact Number",
      "birthPlace": "Place of Birth",
      "nationality": "Nationality",
      "civilStatus": "Civil Status",
      "email": "Email",
      "purpose": "Clearance Purpose",
      "signatureImageURL": "Applicant Signature over Printed Name"
    },
    "business_clearance_request": {
      "applicationDate": "Application Date",
      "appType": "Application Type",
      "businessName": "Complete Business Name",
      "houseNum": "House/Unit Number",
      "bldgUnit": "Building/Unit Number",
      "street": "Street / Avenue",
      "village": "Village / Subdivision / Area",
      "natureOfBusiness": "Nature of Business",
      "ownershipType": "Business Ownership Type",
      "locationStatus": "Business Location Status",
      "totalArea": "Establishment Total Area",
      "capitalization": "Capitalization (₱)",
      "grossSales": "Gross Sales and Receipts (Precedent Year)",
      "ownerName": "Business Owner / Manager",
      "contactNumber": "Contact Number",
      "email": "Email",
      "dtiCertFileURL": "Valid D.T.I Certificate",
      "secCertFileURL": "Valid S.E.C Certificate",
      "cdaFileURL": "Valid Cooperative Development Authority Certificate",
      "barangayClrncImageURL": "Previous Barangay Clearance",
      "landTitleFileURL": "Land Title or Tax Declaration",
      "contractsFileURL": "Duly Notarized Contracts and/or Agreements",
      "establishmentImageURl": "4R Format Full-View Establishment Picture",
      "ownerImageURL": "2x2 Owner Picture",
      "endorsementFileURL": "Association Endorsement",
      "signatureImageURL": "Applicant Signature over Printed Name"
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  Future<void> _fetchRequestDetails() async {
    String idColumn;

    switch (widget.requestType) {
      case "barangay_id_request":
        idColumn = "barangay_id_id";
        break;
      case "barangay_clearance_request":
        idColumn = "barangay_clearance_id";
        break;
      case "business_clearance_request":
        idColumn = "business_clearance_id";
        break;
      default:
        throw Exception("Unknown request type: ${widget.requestType}");
    }

    final res = await supabase
        .from(widget.requestType)
        .select()
        .eq(idColumn, widget.requestId)
        .maybeSingle();

    setState(() {
      _requestData = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = fieldLabels[widget.requestType];

    final Map<String, String> serviceTitles = {
      "barangay_id_request": "Barangay ID Details",
      "barangay_clearance_request": "Barangay Clearance Details",
      "business_clearance_request": "Business Clearance Details",
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: ElementColors.fontColor2),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requestData == null
              ? const Center(child: Text("No data found."))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Text(
                        serviceTitles[widget.requestType] ?? "Request Details",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: ElementColors.fontColor1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...labels!.entries.map((field) {
                      final key = field.key;
                      final label = field.value;
                      final value = _requestData![key];

                      if (widget.requestType == "barangay_clearance_request") {
                        if (key == "lengthStay" &&
                            _requestData!["residencyType"] != "rent") {
                          return const SizedBox.shrink();
                        }
                      }

                      if (widget.requestType == "business_clearance_request") {
                        final ownership = _requestData!["ownershipType"];
                        final appType = _requestData!["appType"];

                        if (key == "dtiCertFileURL" &&
                            ownership != "Single Proprietor") {
                          return const SizedBox.shrink();
                        }
                        if (key == "secCertFileURL" &&
                            ownership != "Partnership" &&
                            ownership != "Corporation") {
                          return const SizedBox.shrink();
                        }
                        if (key == "cdaFileURL" && ownership != "Cooperative") {
                          return const SizedBox.shrink();
                        }
                        if (key == "barangayClrncImageURL" &&
                            appType != "Renewal Application") {
                          return const SizedBox.shrink();
                        }
                      }

                      String displayValue;
                      if (key == "idPurpose" && value is List) {
                        displayValue =
                            value.map((e) => e.toString()).join(", ");
                      } else {
                        displayValue = value?.toString() ?? "";
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 4),
                            child: Text(
                              label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.fromLTRB(15, 0, 15, 25),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: ElementColors.fontColor2.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: ElementColors.shadow.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                  spreadRadius: 1, 
                                ),
                              ],
                            ),
                            child: Text(
                              displayValue,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
    );
  }
}
