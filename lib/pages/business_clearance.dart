import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/applicant_undertaking.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/date_picker.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/pages/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class BusinessClearance extends StatefulWidget {
  const BusinessClearance({super.key});

  @override
  State<BusinessClearance> createState() => _BusinessClearanceState();
}

class _BusinessClearanceState extends State<BusinessClearance> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedApplicationDate;
  String? appType; // Application Type
  String? ownershipType; // Ownership Type
  String? locationStatus; // Location Status
  final double menuIconSize = 28;
  final TextStyle labelStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  // Files
  File? dtiCertFile;
  File? secCertFile;
  File? cdaFile;
  File? landTitleFile;
  File? contractsFile;
  File? endorsementFile;

  // Images
  File? barangayClrncImage;
  File? establishmentImage;
  File? ownerImage;
  File? signatureImage;
  File? applicantSignatureImage;

  final ImagePicker _picker = ImagePicker();
  

  // Controllers
  final TextEditingController applicationDate = TextEditingController();

  final TextEditingController businessName = TextEditingController();
  final TextEditingController houseNum = TextEditingController();
  final TextEditingController bldgUnit = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController village = TextEditingController();
  final TextEditingController natureOfBusiness =
  TextEditingController();

  final TextEditingController totalArea = TextEditingController();
  final TextEditingController capitalization = TextEditingController();
  final TextEditingController grossSales = TextEditingController();
  final TextEditingController ownerName = TextEditingController();
  final TextEditingController contactNum = TextEditingController();
  final TextEditingController email = TextEditingController();

  // final TextEditingController contractExpiryMonth = TextEditingController();
  // final TextEditingController contractExpiryDay = TextEditingController();
  // final TextEditingController contractExpiryYear = TextEditingController();

    String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Pick an image (JPG, PNG)
  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        onSelected(File(pickedFile.path));
      });
    }
  }

  // Pick a file (PDF, DOCX)
  Future<void> _pickFile(Function(File) onSelected) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        onSelected(File(result.files.single.path!));
      });
    }
  }

    void _submitBusinessClearance() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Validate form fields first
    if (_formKey.currentState!.validate()) {
      // Validate files based on ownership type
      if (ownershipType == 'Partnership' || ownershipType == 'Corporation') {
        if (secCertFile == null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text("Please upload a Valid S.E.C Certificate.",
                  style: TextStyle(
                      color: ElementColors.tertiary,
                      fontWeight: FontWeight.bold)),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ElementColors.fontColor2,
            ),
          );
          return;
        }
      } else if (ownershipType == 'Cooperative') {
        if (cdaFile == null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text("Please upload a Valid Cooperative Development Authority Certificate.",
                  style: TextStyle(
                      color: ElementColors.tertiary,
                      fontWeight: FontWeight.bold)),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ElementColors.fontColor2,
            ),
          );
          return;
        }
      } else {
        if (dtiCertFile == null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text("Please upload a Valid D.T.I Certificate.",
                  style: TextStyle(
                      color: ElementColors.tertiary,
                      fontWeight: FontWeight.bold)),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ElementColors.fontColor2,
            ),
          );
          return;
        }
      }

      // Validate required images
      if (establishmentImage == null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Please upload an Establishment Picture.",
                style: TextStyle(
                    color: ElementColors.tertiary,
                    fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.fontColor2,
          ),
        );
        return;
      }
      if (ownerImage == null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Please upload an Owner Picture.",
                style: TextStyle(
                    color: ElementColors.tertiary,
                    fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.fontColor2,
          ),
        );
        return;
      }
      if (signatureImage == null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Please upload your Signature.",
                style: TextStyle(
                    color: ElementColors.tertiary,
                    fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.fontColor2,
          ),
        );
        return;
      }

      // If all validations pass, proceed to show the popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BusinessClearancePopup(
          onConfirmed: () {
            Navigator.pop(dialogContext); // Close popup
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const Home(showConfirmation: true)),
              );
            });
          },
        ),
      );
    } else {
      // If form validation fails, show a general message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Please fill out all required fields.",
              style: TextStyle(
                  color: ElementColors.tertiary,
                  fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.fontColor2,
        ),
      );
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
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
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
                            SnackBar(
                              content: Text("Business Clearance button tapped!",
                                style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold)),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: ElementColors.fontColor2,
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
                InkWell(
                  // Use the reusable function here
                  onTap: () async {
                    final picked = await showCustomDatePicker(context);
                    if (picked != null) {
                      setState(() {
                        _selectedApplicationDate = picked;
                        applicationDate.text = DateFormat('MM/dd/yyyy').format(_selectedApplicationDate!);
                      });
                    }
                  },
                  child: IgnorePointer(
                    child: TxtField(
                      type: TxtFieldType.services,
                      label: 'Application Date',
                      hint: "MM/DD/YYYY",
                      controller: applicationDate,
                      suffixIcon: Icon(Icons.calendar_today, color: ElementColors.primary),
                      validator:  _requiredValidator
                    ),
                  ),
                  ),
                
                // Application Type
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Application Type', 
                  options: ['New Application', 'Renewal Application', 'Temporary'], 
                  onChanged: (value) { setState(() { appType = value; });},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select an application type.";
                    }
                    return null;
                  },
                ),
                              
                  // Business Name
                  const SizedBox(height: 10),
                  TxtField(
                  label: "Complete Business Name",
                  type: TxtFieldType.services,
                  hint: "Company / Business Name",
                  controller: businessName,
                  validator:  _requiredValidator
                  ),
                            
                // Address
                const SizedBox(height: 20),
                Padding(
                padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Complete Business Address', 
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
                    label: 'House/Unit Number:',
                    hint: "House/Unit Number",
                    controller: houseNum,
                    width: media.width * 0.35,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(40, 5, 0, 0),
                    validator:  _requiredValidator
                  ),
                                  
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Building/Unit Number:',
                    hint: "Building/Unit Number",
                    controller: bldgUnit,
                    width: media.width * 0.38,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                    validator:  _requiredValidator
                  ),
                ],
                ),
      
                // Street Avenue
                const SizedBox(height: 10),
                TxtField(
                label: "Street / Avenue",
                  type: TxtFieldType.services,
                  hint: "Street / Avenue",
                  controller: street,
                  labelFontSize: 15,
                  customPadding: EdgeInsets.fromLTRB(40, 5, 30, 0),
                  validator:  _requiredValidator
                ),
                
                // Village
                const SizedBox(height: 10),
                TxtField(
                label: "Village / Subdivision / Area",
                  type: TxtFieldType.services,
                  hint: "Village / Subdivision / Area",
                  controller: village,
                  labelFontSize: 15,
                  customPadding: EdgeInsets.fromLTRB(40, 5, 30, 0),
                  validator:  _requiredValidator
                ),
                            
                // Nature of Business
                const SizedBox(height: 20),
                TxtField(
                type: TxtFieldType.services,
                hint: "Nature of Business",
                label: "Nature of Business",
                controller: natureOfBusiness,
                validator:  _requiredValidator
                ),
      
                // Ownership
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Business Ownership Type', 
                  options: ['Partnership', 'Corporation', 'Cooperative'], 
                  onChanged: (value) { setState(() { ownershipType = value; });},
                  showOther: true,
                  validator:  _requiredValidator
                ),
                            
                // Business Location Status
                const SizedBox(height: 10),
                RadioButtons(
                  label: 'Business Location Status', 
                  options: ['Owned', 'Rented', 'Free Lease'], 
                  onChanged: (value) { setState(() { locationStatus = value; });},
                  showOther: true,
                  validator:  _requiredValidator
                ),
                            
                // Other Info
                const SizedBox(height: 10),
                TxtField(
                label: "Establishment Total Area",
                type: TxtFieldType.services,
                hint: "e.g. 200 sqm",
                controller: totalArea,
                validator:  _requiredValidator
                ),
      
                const SizedBox(height: 20),
                TxtField(
                label: "Capitalization (₱)",
                type: TxtFieldType.services,
                hint: "In Philippine Peso",
                controller: capitalization,
                validator:  _requiredValidator
                )
                ,
                const SizedBox(height: 20),
                TxtField(
                label: "Gross Sales and Receipts (Precedent Year)",
                type: TxtFieldType.services,
                hint: "In Philippine Peso",
                controller: grossSales,
                validator:  _requiredValidator
                ),
                            
                const SizedBox(height: 20),
                TxtField(
                label: "Business Owner / Manager",
                type: TxtFieldType.services,
                hint: "Owner / Manager Full Name",
                controller: ownerName,
                validator:  _requiredValidator
                ),
                            
                  const SizedBox(height: 20),
                  TxtField(
                  label: "Contact Number",
                  type: TxtFieldType.services,
                  hint: "09XXXXXXXXX",
                  controller: contactNum,
                  keyboardType: TextInputType.number,
                  validator:  _requiredValidator
                ),
                            
                const SizedBox(height: 20),
                TxtField(
                label: "Email Address",
                type: TxtFieldType.services,
                hint: "example@gmail.com",
                controller: email,
                keyboardType: TextInputType.emailAddress,
                validator:  _requiredValidator
                ),

                const SizedBox(height: 40),
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
                            
                                       // D.T.I Certificate (File)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadFileBox(
                    label: "Valid D.T.I Certificate (For Single Proprietors)",
                    file: dtiCertFile,
                    onTap: () => _pickFile((file) => dtiCertFile= file),
                  ),
                ),
                            
                // S.E.C Certificate (File)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadFileBox(
                    label: "Valid S.E.C Certificate (For Partnership or Corporations)",
                    file: secCertFile,
                    onTap: () => _pickFile((file) => secCertFile = file),
                  ),
                ),
                            
                // C.D.A Certificate (File)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadFileBox(
                    label: "Valid Cooperative Development Authority Certificate (For Cooperative)",
                    file: cdaFile,
                    onTap: () => _pickFile((file) => cdaFile = file),
                  ),
                ),
                            
                // Prev. Barangay Clearance (Image)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "Valid Cooperative Development Authority Certificate (If Renewal)",
                    imageFile: barangayClrncImage,
                    onTap: () => _pickImage((file) => barangayClrncImage = file),
                  ),
                ),
                            
                // Land Title (File)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "Land Title or Tax Declaration (Must be under the name of land owner / lessor)",
                    imageFile: landTitleFile,
                    onTap: () => _pickFile((file) => landTitleFile = file),
                  ),
                ),
                            
                // Contracts or Agreements (File)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "Duly Notarized Contracts and/or Agreements",
                    imageFile: contractsFile,
                    onTap: () => _pickFile((file) => contractsFile = file),
                  ),
                ),
                            
                 // Establishment (Image)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "4R Format Full-View Establishment Picture",
                    imageFile: establishmentImage,
                    onTap: () => _pickImage((file) => establishmentImage = file),
                  ),
                ),
                            
                // Owner (Image)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "2x2 Owner Picture",
                    imageFile: ownerImage,
                    onTap: () => _pickImage((file) => ownerImage = file),
                  ),
                ),
                            
                // Contracts or Agreements (File)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "Association Endorsement",
                    imageFile: endorsementFile,
                    onTap: () => _pickFile((file) => endorsementFile = file),
                  ),
                ),
                            
                // Signature (Image)
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "Upload Signature",
                    imageFile: signatureImage,
                    onTap: () => _pickImage((file) => signatureImage = file),
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
                onClick: _submitBusinessClearance,
                  ),
                ),
                                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}