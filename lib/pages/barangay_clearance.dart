import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/textfields.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';

class BarangayClearance extends StatefulWidget {
  const BarangayClearance({super.key});

  @override
  State<BarangayClearance> createState() => _BarangayClearanceState();
}

class _BarangayClearanceState extends State<BarangayClearance> {
  final TextEditingController lengthStayController = TextEditingController();
  final TextEditingController clearanceNumController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController houseNoController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController pobController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController civilStatusController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();

  String ownOrRent = "";
  String gender = "";

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
            // Header with back and button
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
                          content: Text("Barangay Clearance button tapped!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                      });
                    },
                    icon: Icon(Icons.article,
                        size: menuIconSize, color: Colors.white),
                    label: Text("Barangay Clearance", style: labelStyle),
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

            // Full-width fields
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
                            ),
                            const SizedBox(height: 10),
                            TxtField(
                              type: TxtFieldType.services,
                              hint: "DD",
                            ),
                            const SizedBox(height: 10),
                            TxtField(
                              type: TxtFieldType.services,
                              hint: "YYYY",
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: TxtField(
                                type: TxtFieldType.services,
                                hint: "MM",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 8,
                              child: TxtField(
                                type: TxtFieldType.services,
                                hint: "DD",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 10,
                              child: TxtField(
                                type: TxtFieldType.services,
                                hint: "YYYY",
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Own or Rent
                  Text("Own or Rent", style: labelStyle),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Radio<String>(
                          value: "Owner",
                          groupValue: ownOrRent,
                          onChanged: (val) => setState(() => ownOrRent = val!),
                        ),
                      ),
                      Text("Owner", style: labelStyle),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Radio<String>(
                          value: "Renter",
                          groupValue: ownOrRent,
                          onChanged: (val) => setState(() => ownOrRent = val!),
                        ),
                      ),
                      Text("Renter", style: labelStyle),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Length of Stay
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Days",
                      label: "Length of Stay",
                      controller: lengthStayController),
                  const SizedBox(height: 16),

                  // Clearance Number
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Enter Clearance Number",
                      label: "Clearance Number",
                      controller: clearanceNumController),
                  const SizedBox(height: 16),

                  // Full Name
                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Last, First, Middle",
                      label: "Full Name",
                      controller: fullNameController),
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
                  const SizedBox(height: 16),

                  // Date of Birth + Age
                  Text("Date of Birth & Age", style: labelStyle),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isSmallScreen) {
                        return Column(
                          children: [
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "MM/DD/YYYY",
                                controller: dobController),
                            const SizedBox(height: 12),
                            TxtField(
                                type: TxtFieldType.services,
                                hint: "00",
                                controller: ageController),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "MM/DD/YYYY",
                                  controller: dobController),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TxtField(
                                  type: TxtFieldType.services,
                                  hint: "00",
                                  controller: ageController),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "09XXXXXXXXX",
                      label: "Contact Number",
                      controller: contactController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Place of Birth",
                      label: "Place of Birth",
                      controller: pobController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Nationality",
                      label: "Nationality",
                      controller: nationalityController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Civil Status",
                      label: "Civil Status",
                      controller: civilStatusController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "example@gmail.com",
                      label: "Email Address",
                      controller: emailController),
                  const SizedBox(height: 16),

                  TxtField(
                      type: TxtFieldType.services,
                      hint: "Enter Purpose",
                      label: "Clearance Purpose",
                      controller: purposeController),
                  const SizedBox(height: 20),

                  // Upload Section
                  Container(
                    height: media.width < 400 ? 100 : 120, // Responsive height
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                        child: Text("Upload Files", style: labelStyle)),
                  ),

                  // Submit button
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
                              content: Text("Form Submitted!"),
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