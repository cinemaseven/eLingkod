import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BarangayID extends StatefulWidget {
  const BarangayID({super.key});

  @override
  State<BarangayID> createState() => _BarangayIDState();
}

class _BarangayIDState extends State<BarangayID> {
  // Controllers
  final TextEditingController appMonth = TextEditingController();
  final TextEditingController appDay = TextEditingController();
  final TextEditingController appYear = TextEditingController();

  final TextEditingController fullName = TextEditingController();
  final TextEditingController birthMonth = TextEditingController();
  final TextEditingController birthDay = TextEditingController();
  final TextEditingController birthYear = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController contactNum = TextEditingController();
  final TextEditingController email = TextEditingController();

  final TextEditingController houseNum = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController zipCode = TextEditingController();

  // Gender
  String? gender;

  // ID Purpose
  List<String> chosenPurposes = [];

  final double menuIconSize = 28;
  final TextStyle labelStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  File? validIdImage;
  File? residencyImage;
  File? signatureImage;

  final ImagePicker _picker = ImagePicker();

  // Pick an image (for Valid ID / Proof of Residency / Signature)
  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        onSelected(File(pickedFile.path));
      });
    }
  }

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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50),
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
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Application Date
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text("Application Date:", style: labelStyle),
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (isSmallScreen) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TxtField(
                                type: TxtFieldType.services,
                                hint: "MM",
                                width: media.width * 0.27,
                                controller: appMonth,
                                customPadding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                              ),
                              const SizedBox(height: 10),
                              TxtField(
                                type: TxtFieldType.services,
                                hint: "DD",
                                width: media.width * 0.27,
                                controller: appDay,
                                customPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              ),
                              const SizedBox(height: 10),
                              TxtField(
                                type: TxtFieldType.services,
                                hint: "YYYY",
                                width: media.width * 0.27,
                                controller: appYear,
                                customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
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

                     // Personal Info Text
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'PERSONAL INFORMATION',
                          style: TextStyle(fontSize: media.height * 0.022, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
          
                   // Full Name
                    const SizedBox(height: 10),
                    TxtField(
                      label: "Full Name",
                      type: TxtFieldType.services,
                      hint: "Last, First, Middle",
                      controller: fullName
                    ),

                  const SizedBox(height: 20),
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date of Birth
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text("Date of Birth:", style: labelStyle),
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (isSmallScreen) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TxtField(
                                type: TxtFieldType.services,
                                hint: "MM",
                                width: media.width * 0.27,
                                controller: birthMonth,
                                customPadding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                              ),
                              const SizedBox(height: 10),
                              TxtField(
                                type: TxtFieldType.services,
                                hint: "DD",
                                width: media.width * 0.27,
                                controller: birthDay,
                                customPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              ),
                              const SizedBox(height: 10),
                              TxtField(
                                type: TxtFieldType.services,
                                hint: "YYYY",
                                width: media.width * 0.27,
                                controller: birthYear,
                                customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
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
          
                    // Gender
                    const SizedBox(height: 20),
                    RadioButtons(
                      label: 'Gender', 
                      options: ['Male', 'Female'], 
                      onChanged: (value) { setState(() { gender = value; });},
                      inline: true,
                    ),
          
                   // Age
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TxtField(
                        type: TxtFieldType.services,
                        label: 'Age:',
                        hint: "Ex: 17",
                        controller: age,
                        width: media.width * 0.3,
                        customPadding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                      ),
              
                      // Contact Number
                      TxtField(
                        type: TxtFieldType.services,
                        label: 'Contact Number:',
                        hint: "Ex: 09xx xxx xxxx",
                        controller: contactNum,
                        keyboardType: TextInputType.number,
                        width: media.width * 0.5,
                        customPadding: EdgeInsets.fromLTRB(10, 5, 30, 0),
                      ),
                    ],
                  ),
          
                    // Email
                    const SizedBox(height: 20),
                    TxtField(
                      label: "Email Address (optional)",
                        type: TxtFieldType.services,
                        hint: "example@gmail.com",
                        controller: email,
                        keyboardType: TextInputType.emailAddress
                      ),
          
                  // Address
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Complete Residential Address', 
                          style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: ElementColors.fontColor1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TxtField(
                        type: TxtFieldType.services,
                        label: 'House Number:',
                        hint: "Ex: 387",
                        controller: houseNum,
                        width: media.width * 0.3,
                        labelFontSize: 15,
                        customPadding: EdgeInsets.fromLTRB(40, 5, 0, 0),
                      ),
              
                      TxtField(
                        type: TxtFieldType.services,
                        label: 'Street:',
                        hint: "Ex: San Juan",
                        controller: street,
                        width: media.width * 0.5,
                        labelFontSize: 15,
                        customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                      ),
                    ],
                  ),
              
                  const SizedBox(height: 10),
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'City:',
                    hint: "Ex: ",
                    controller: city,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(40, 5, 30, 0),
                  ),
                  
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TxtField(
                        type: TxtFieldType.services,
                        label: 'Province:',
                        hint: "Ex: Pampanga",
                        controller: province,
                        width: media.width * 0.5,
                        labelFontSize: 15,
                        customPadding: EdgeInsets.fromLTRB(40, 5, 0, 0),
                      ),
              
                      TxtField(
                        type: TxtFieldType.services,
                        label: 'Zip Code:',
                        hint: "Ex: 2007",
                        controller: zipCode,
                        width: media.width * 0.29,
                        labelFontSize: 15,
                        customPadding: EdgeInsets.fromLTRB(10, 5, 30, 0),
                      ),
                    ],
                  ),

                    // ID Purpose
                    const SizedBox(height: 20),
                    CheckBoxes(
                      label: "ID Purpose (Check all that apply)",
                      options: ["Employment", "School", "General Use"],
                      showOther: true,
                      onChanged: (selectedValues) {
                        print("Selected purposes: $selectedValues");

                        // if you want to store them in state:
                        setState(() {
                          // example: save to a variable
                          chosenPurposes = selectedValues;
                        });
                      },
                    ),

                  const SizedBox(height: 20),
                  Divider(
                    color: ElementColors.fontColor1,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),

                    // Documentary Requirements Text
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'DOCUMENTARY REQUIREMENTS',
                          style: TextStyle(fontSize: media.height * 0.022, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
          
                    // Valid ID (Image)
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: UploadImageBox(
                        label: "Upload Valid ID",
                        imageFile: validIdImage,
                        onTap: () => _pickImage((file) => validIdImage = file),
                      ),
                    ),

                    // Proof of Residency (Image)
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: UploadImageBox(
                        label: "Upload Proof of Residency",
                        imageFile: residencyImage,
                        onTap: () => _pickImage((file) => residencyImage = file),
                      ),
                    ),

                    // Signature (Image)
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: UploadImageBox(
                        label: "Applicant Signature over Printed Name",
                        imageFile: signatureImage,
                        onTap: () => _pickImage((file) => signatureImage = file),
                      ),
                    ),

                     // Submit button
                    const SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: isSmallScreen ? media.width * 0.5 : media.width * 0.3,
                        child: Buttons(
                          title: "Submit",
                          type: BtnType.secondary,
                          fontSize: isSmallScreen ? 16 : 14 ,
                          height: 45,
                          onClick: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Form Submitted!"),
                                duration: const Duration(seconds: 2),
                                backgroundColor: ElementColors.primary,
                              ),
                            );
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ),
                    // const SizedBox(height: 30),
                  ],
                ),
            ],
          ),]
        ),),
      ),
    );
  }
}