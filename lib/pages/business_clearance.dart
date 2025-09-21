import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/textfields.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';

class BusinessClearance extends StatefulWidget {
  const BusinessClearance({super.key});

  @override
  State<BusinessClearance> createState() => _BusinessClearanceState();
}

class _BusinessClearanceState extends State<BusinessClearance> {
  // Controllers
  final TextEditingController appMonthController = TextEditingController();
  final TextEditingController appDayController = TextEditingController();
  final TextEditingController appYearController = TextEditingController();

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController houseNoController = TextEditingController();
  final TextEditingController buildingUnitController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController natureOfBusinessController =
  TextEditingController();

  final TextEditingController totalAreaController = TextEditingController();
  final TextEditingController capitalizationController = TextEditingController();
  final TextEditingController grossSalesController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Application Type
  String appType = "";

  // Ownership Type
  String ownershipType = "";

  // Location Status
  String locationStatus = "";
  final TextEditingController contractExpiryMonth = TextEditingController();
  final TextEditingController contractExpiryDay = TextEditingController();
  final TextEditingController contractExpiryYear = TextEditingController();

  final double menuIconSize = 28;
  final TextStyle labelStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final isSmallScreen = media.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        CustomPageRoute(page: const Home()),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ElementColors.tertiary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Business Clearance button tapped!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                      });
                    },
                    icon: Icon(Icons.article,
                        size: menuIconSize, color: Colors.white),
                    label: Text("Business Clearance", style: labelStyle),
                  ),
                ],
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  const Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child:
                    Text("Form to be Accomplished", style: labelStyle),
                  ),
                  const Expanded(child: Divider(thickness: 1)),
                ],
              ),
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Application Date
                  Text("Application Date", style: labelStyle),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isSmallScreen) {
                        return Column(
                          children: [
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "MM",
                                controller: appMonthController),
                            const SizedBox(height: 10),
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "DD",
                                controller: appDayController),
                            const SizedBox(height: 10),
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "YYYY",
                                controller: appYearController),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "MM",
                                  controller: appMonthController),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "DD",
                                  controller: appDayController),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "YYYY",
                                  controller: appYearController),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Application Type
                  Text("Application Type", style: labelStyle),
                  RadioListTile(
                    title: const Text("New Application"),
                    value: "New",
                    groupValue: appType,
                    onChanged: (val) => setState(() => appType = val!),
                  ),
                  RadioListTile(
                    title: const Text("Renewal Application"),
                    value: "Renewal",
                    groupValue: appType,
                    onChanged: (val) => setState(() => appType = val!),
                  ),
                  RadioListTile(
                    title: const Text("Temporary"),
                    value: "Temporary",
                    groupValue: appType,
                    onChanged: (val) => setState(() => appType = val!),
                  ),
                  const SizedBox(height: 16),

                  // Business Name
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Company / Business Name",
                      label: "Complete Business Name",
                      controller: businessNameController),
                  const SizedBox(height: 16),

                  // Address
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "House / Unit Number",
                      label: "House/Unit Number",
                      controller: houseNoController),
                  const SizedBox(height: 16),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Building / Unit",
                      label: "Building/Unit Number",
                      controller: buildingUnitController),
                  const SizedBox(height: 16),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Street / Avenue",
                      label: "Street / Avenue",
                      controller: streetController),
                  const SizedBox(height: 16),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Village / Subdivision / Area",
                      label: "Village / Subdivision / Area",
                      controller: villageController),
                  const SizedBox(height: 16),

                  // Nature of Business
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Nature of Business",
                      label: "Nature of Business",
                      controller: natureOfBusinessController),
                  const SizedBox(height: 16),

                  // Ownership
                  Text("Business Ownership Type", style: labelStyle),
                  RadioListTile(
                    title: const Text("Partnership"),
                    value: "Partnership",
                    groupValue: ownershipType,
                    onChanged: (val) => setState(() => ownershipType = val!),
                  ),
                  RadioListTile(
                    title: const Text("Corporation"),
                    value: "Corporation",
                    groupValue: ownershipType,
                    onChanged: (val) => setState(() => ownershipType = val!),
                  ),
                  RadioListTile(
                    title: const Text("Cooperative"),
                    value: "Cooperative",
                    groupValue: ownershipType,
                    onChanged: (val) => setState(() => ownershipType = val!),
                  ),
                  RadioListTile(
                    title: const Text("Others"),
                    value: "Others",
                    groupValue: ownershipType,
                    onChanged: (val) => setState(() => ownershipType = val!),
                  ),
                  const SizedBox(height: 16),

                  // Business Location Status
                  Text("Business Location Status", style: labelStyle),
                  RadioListTile(
                    title: const Text("Owned"),
                    value: "Owned",
                    groupValue: locationStatus,
                    onChanged: (val) => setState(() => locationStatus = val!),
                  ),
                  RadioListTile(
                    title: const Text("Rented"),
                    value: "Rented",
                    groupValue: locationStatus,
                    onChanged: (val) => setState(() => locationStatus = val!),
                  ),
                  if (locationStatus == "Rented") ...[
                    const SizedBox(height: 6),
                    Text("Specify Contract Expiry Date", style: labelStyle),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (isSmallScreen) {
                          return Column(
                            children: [
                              TxtField(
                                  type: TxtFieldType.services,
                                  hint: "MM",
                                  controller: contractExpiryMonth),
                              const SizedBox(height: 10),
                              TxtField(
                                  type: TxtFieldType.services,
                                  hint: "DD",
                                  controller: contractExpiryDay),
                              const SizedBox(height: 10),
                              TxtField(
                                  type: TxtFieldType.services,
                                  hint: "YYYY",
                                  controller: contractExpiryYear),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                child: TxtField(
                                    type: TxtFieldType.services,
                                    hint: "MM",
                                    controller: contractExpiryMonth),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TxtField(
                                    type: TxtFieldType.services,
                                    hint: "DD",
                                    controller: contractExpiryDay),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TxtField(
                                    type: TxtFieldType.services,
                                    hint: "YYYY",
                                    controller: contractExpiryYear),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                  RadioListTile(
                    title: const Text("Free Lease"),
                    value: "Free Lease",
                    groupValue: locationStatus,
                    onChanged: (val) => setState(() => locationStatus = val!),
                  ),
                  const SizedBox(height: 16),

                  // Other Info
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "e.g. 200 sqm",
                      label: "Establishment Total Area",
                      controller: totalAreaController),
                  const SizedBox(height: 16),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "In Philippine Peso",
                      label: "Capitalization (₱)",
                      controller: capitalizationController),
                  const SizedBox(height: 16),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "In Philippine Peso",
                      label: "Gross Sales and Receipts (Precedent Year)",
                      controller: grossSalesController),
                  const SizedBox(height: 16),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Owner / Manager Full Name",
                      label: "Business Owner / Manager",
                      controller: ownerNameController),
                  const SizedBox(height: 16),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "09XXXXXXXXX",
                      label: "Contact Number",
                      controller: contactController),
                  const SizedBox(height: 16),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "example@gmail.com",
                      label: "Email Address",
                      controller: emailController),
                  const SizedBox(height: 20),

                  // Documentary Requirements
                  Text("DOCUMENTARY REQUIREMENTS", style: labelStyle),
                  const SizedBox(height: 12),

                  for (var doc in [
                    "Valid DTI Certificate (for Single Proprietorship)",
                    "Valid SEC Certificate (for Partnership/Corporation)",
                    "Valid Cooperative Development Authority Certificate",
                    "Previous Barangay Clearance (if Renewal)",
                    "Land Title and/or Tax Declaration",
                    "Duly Notarized Contracts and/or Agreements",
                    "4R Format Full-view Establishment Picture",
                    "2x2 Format Owner Picture",
                    "Association Endorsement",
                    "Authorized Signatory Full Name and Signature"
                  ])
                    Container(
                      height: isSmallScreen ? 100 : 120,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                          child: Text("Upload $doc", style: labelStyle)),
                    ),

                  // Submit
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: isSmallScreen ? media.width * 0.8 : media.width * 0.5,
                      child: Buttons(
                        title: "Submit",
                        type: BtnType.secondary,
                        onClick: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text("Business Clearance Form Submitted!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}