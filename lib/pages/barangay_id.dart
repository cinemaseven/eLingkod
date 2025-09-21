import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/textfields.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';

class BarangayID extends StatefulWidget {
  const BarangayID({super.key});

  @override
  State<BarangayID> createState() => _BarangayIDState();
}

class _BarangayIDState extends State<BarangayID> {
  // Controllers
  final TextEditingController appMonthController = TextEditingController();
  final TextEditingController appDayController = TextEditingController();
  final TextEditingController appYearController = TextEditingController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobMonthController = TextEditingController();
  final TextEditingController dobDayController = TextEditingController();
  final TextEditingController dobYearController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController houseNoController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController zipController = TextEditingController();

  // Gender
  String gender = "";

  // ID Purpose
  bool purposeEmployment = false;
  bool purposeSchool = false;
  bool purposeGeneral = false;
  final TextEditingController otherPurposeController = TextEditingController();

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
                          content: Text("Barangay ID button tapped!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                      });
                    },
                    icon: Icon(Icons.article,
                        size: menuIconSize, color: Colors.white),
                    label: Text("Barangay ID", style: labelStyle),
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
                    child: Text("Form to be Accomplished", style: labelStyle),
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
                              controller: appMonthController,
                            ),
                            const SizedBox(height: 10),
                            TxtField(
                              type: TxtFieldType.services,
                              hint: "DD",
                              controller: appDayController,
                            ),
                            const SizedBox(height: 10),
                            TxtField(
                              type: TxtFieldType.services,
                              hint: "YYYY",
                              controller: appYearController,
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: TxtField(
                                type: TxtFieldType.services,
                                hint: "MM",
                                controller: appMonthController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TxtField(
                                type: TxtFieldType.services,
                                hint: "DD",
                                controller: appDayController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TxtField(
                                type: TxtFieldType.services,
                                hint: "YYYY",
                                controller: appYearController,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Full Name
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Last, First, Middle",
                      label: "Full Name",
                      controller: fullNameController),
                  const SizedBox(height: 16),

                  // Date of Birth
                  Text("Date of Birth", style: labelStyle),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isSmallScreen) {
                        return Column(
                          children: [
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "MM",
                                controller: dobMonthController),
                            const SizedBox(height: 10),
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "DD",
                                controller: dobDayController),
                            const SizedBox(height: 10),
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "YYYY",
                                controller: dobYearController),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "MM",
                                  controller: dobMonthController),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "DD",
                                  controller: dobDayController),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "YYYY",
                                  controller: dobYearController),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Gender
                  Text("Gender", style: labelStyle),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Radio<String>(
                          value: "Male",
                          groupValue: gender,
                          onChanged: (val) => setState(() => gender = val!),
                        ),
                      ),
                      Text("Male", style: labelStyle),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Radio<String>(
                          value: "Female",
                          groupValue: gender,
                          onChanged: (val) => setState(() => gender = val!),
                        ),
                      ),
                      Text("Female", style: labelStyle),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Age + Contact
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isSmallScreen) {
                        return Column(
                          children: [
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "00",
                                label: "Age",
                                controller: ageController),
                            const SizedBox(height: 12),
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "09XXXXXXXXX",
                                label: "Contact Number",
                                controller: contactController),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "00",
                                  label: "Age",
                                  controller: ageController),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "09XXXXXXXXX",
                                  label: "Contact Number",
                                  controller: contactController),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Address
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "example@gmail.com",
                      label: "Email Address (optional)",
                      controller: emailController),
                  const SizedBox(height: 16),

                  // Address
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "House Number",
                      label: "House Number",
                      controller: houseNoController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Street",
                      label: "Street",
                      controller: streetController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "City",
                      label: "City",
                      controller: cityController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Province",
                      label: "Province",
                      controller: provinceController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Zip Code",
                      label: "Zip Code",
                      controller: zipController),
                  const SizedBox(height: 20),

                  // ID Purpose
                  Text("ID Purpose (Check all that apply)", style: labelStyle),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    title: const Text("Employment"),
                    value: purposeEmployment,
                    onChanged: (val) =>
                        setState(() => purposeEmployment = val!),
                  ),
                  CheckboxListTile(
                    title: const Text("School"),
                    value: purposeSchool,
                    onChanged: (val) => setState(() => purposeSchool = val!),
                  ),
                  CheckboxListTile(
                    title: const Text("General Use"),
                    value: purposeGeneral,
                    onChanged: (val) => setState(() => purposeGeneral = val!),
                  ),
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Other purpose",
                      controller: otherPurposeController),
                  const SizedBox(height: 20),

                  // Documentary Requirements
                  Text("DOCUMENTARY REQUIREMENTS", style: labelStyle),
                  const SizedBox(height: 12),

                  Container(
                    height: isSmallScreen ? 100 : 120,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                        child: Text("Upload Valid ID", style: labelStyle)),
                  ),
                  Container(
                    height: isSmallScreen ? 100 : 120,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                        child: Text("Upload Proof of Residency",
                            style: labelStyle)),
                  ),
                  Container(
                    height: isSmallScreen ? 100 : 120,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                        child: Text("Upload Signature", style: labelStyle)),
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
                              content: Text("Barangay ID Form Submitted!"),
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