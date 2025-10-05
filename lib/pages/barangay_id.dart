import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/date_picker.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/common_widget/terms_agreement.dart';
import 'package:elingkod/common_widget/pdf_generator.dart'; // pdf widget
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/services/submitRequests_service.dart';
import 'package:elingkod/services/userData_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class BarangayID extends StatefulWidget {
  const BarangayID({super.key});

  @override
  State<BarangayID> createState() => _BarangayIDState();
}

class _BarangayIDState extends State<BarangayID> {
  final _formKey = GlobalKey<FormState>();
  UserDetails? _initialUserDetails;
  bool _loading = true;
  DateTime? _selectedApplicationDate;
  DateTime? _selectedBirthDate;
  String? gender;
  List<String> chosenPurposes = [];

  final double menuIconSize = 28;
  final TextStyle labelStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  File? validIdImage;
  File? residencyImage;
  File? signatureImage;

  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController applicationDate = TextEditingController();

  final TextEditingController fullName = TextEditingController();
  final TextEditingController birthDate = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController email = TextEditingController();

  final TextEditingController houseNum = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController zipCode = TextEditingController();

  // Autofill info
  @override
  void initState() {
    super.initState();
    // Sets application date to today
    _selectedApplicationDate = DateTime.now();
    applicationDate.text = DateFormat('MM/dd/yyyy').format(_selectedApplicationDate!);

    // Fetch data
    _loadAndAutofillUserDetails();
  }

  // Load and initialize controllers
  Future<void> _loadAndAutofillUserDetails() async {
    try {
      final details = await UserDataService().fetchUserDetails();
      if (!mounted) return;

      _initialUserDetails = details;

      final joinNames = [details.firstName, details.middleName, details.lastName].where((n) => n != null && n.isNotEmpty);

      this.fullName.text = joinNames.join(' ');

      contactNumber.text = details.contactNumber ?? '';
      email.text = details.email ?? '';
      gender = details.gender;
      age.text = details.age ?? '';

      if (details.birthDate != null) {
        birthDate.text = details.birthDate!;
      }

      houseNum.text = details.houseNum ?? '';
      street.text = details.street ?? '';
      city.text = details.city ?? '';
      province.text = details.province ?? '';
      zipCode.text = details.zipCode ?? '';
    } catch (e) {
      print("Error loading user details for autofill: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    applicationDate.dispose();
    fullName.dispose();
    birthDate.dispose();
    age.dispose();
    contactNumber.dispose();
    email.dispose();
    houseNum.dispose();
    street.dispose();
    city.dispose();
    province.dispose();
    zipCode.dispose();
    super.dispose();
  }

  // Fields validator
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(DateTime?) onDateSelected) async {
  final pickedDate = await showCustomDatePicker(context);
  if (pickedDate != null) {
    onDateSelected(pickedDate);
    controller.text = DateFormat('MM/dd/yyyy').format(pickedDate);
  }
}

// Form submission
void _submitBarangayID() async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  if (!_formKey.currentState!.validate()) {
    // Validate form
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text("Please fill out all required fields.",
          style: TextStyle(fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ElementColors.secondary,
      ),
    );
      return;
  }

  // Show terms and agreement
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => TermsPopup(
      onConfirmed: () async {
        try {
          // 1. Collect all the data
          final Map<String, dynamic> formData = {
            'applicationDate': applicationDate.text,
            'fullName': fullName.text,
            'gender': gender, 
            'birthDate': birthDate.text,
            'age': age.text,
            'contactNumber': contactNumber.text,
            'email': email.text,
            'houseNum': houseNum.text,
            'street': street.text,
            'city': city.text,
            'province': province.text,
            'zipCode': zipCode.text,
            'idPurpose': chosenPurposes, 
            'validIdImage': validIdImage, 
            'residencyImage': residencyImage, 
            'signatureImage': signatureImage, 
          };

          // 2. Show loading indicator while submitting
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          // 3. Submit to Supabase
          final submitService = SubmitRequestService();
          await submitService.submitBarangayID(formData: formData);

          // 4. Close all dialogs first (loading and terms)
          Navigator.of(context, rootNavigator: true).pop();

            // 5. Navigate AFTER dialogs are closed
          if (mounted) {
            Navigator.of(context).pushReplacement(
              CustomPageRoute(page: const Home(showConfirmation: true)),
            );
          }
        } on Exception catch (e) {
          Navigator.pop(context);
          Navigator.pop(dialogContext);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Failed to submit request: ${e.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ElementColors.secondary,
            ),
          );
        }
      },
    ),
  );
}
  
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final isSmallScreen = media.width < 600;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator())
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            CustomPageRoute(page: const Home()),
          );
        },
      ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                       ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ElementColors.tertiary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          PdfFormGenerator.generateBarangayId();
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Barangay ID"), 
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
                InkWell(
                  // Use the reusable function here
                  onTap: () => _selectDate(context, applicationDate, (date) => _selectedApplicationDate = date),
                  child: IgnorePointer(
                    child: TxtField(
                      type: TxtFieldType.services,
                      label: 'Application Date',
                      hint: "MM/DD/YYYY",
                      controller: applicationDate,
                      suffixIcon: Icon(Icons.calendar_today, color: ElementColors.primary),
                      validator: _requiredValidator
                    ),
                  ),
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
                  hint: "First Name Middle Name Last Name",
                  controller: fullName,
                  validator: _requiredValidator
                ),
                
                const SizedBox(height: 20),
                InkWell(
                  // Use the reusable function here
                  onTap: () => _selectDate(context, birthDate, (date) => _selectedBirthDate = date),
                  child: IgnorePointer(
                    child: TxtField(
                      type: TxtFieldType.services,
                      label: 'Date of Birth',
                      hint: "MM/DD/YYYY",
                      controller: birthDate,
                      suffixIcon: Icon(Icons.calendar_today, color: ElementColors.primary),
                      validator: _requiredValidator
                    ),
                  ),
                  ),
                        
              // Gender
              const SizedBox(height: 20),
              RadioButtons(
                label: 'Gender', 
                options: ['Male', 'Female'], 
                initialValue: gender,
                onChanged: (value) { setState(() { gender = value; });},
                inline: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender.';
                  }
                  return null;
                },
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
                  validator: _requiredValidator
                ),
                            
                // Contact Number
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Contact Number:',
                  hint: "Ex: 09xx xxx xxxx",
                  controller: contactNumber,
                  keyboardType: TextInputType.number,
                  width: media.width * 0.5,
                  customPadding: EdgeInsets.fromLTRB(10, 5, 30, 0),
                  validator: _requiredValidator
                ),
              ],
              ),
                        
              // Email
              const SizedBox(height: 20),
              TxtField(
                label: "Email Address",
                  type: TxtFieldType.services,
                  hint: "example@gmail.com",
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _requiredValidator
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
                  validator: _requiredValidator
                ),
                            
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Street:',
                  hint: "Ex: San Juan",
                  controller: street,
                  width: media.width * 0.5,
                  labelFontSize: 15,
                  customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                  validator: _requiredValidator
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
              validator: _requiredValidator
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
                  validator: _requiredValidator
                ),
                            
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Zip Code:',
                  hint: "Ex: 2007",
                  controller: zipCode,
                  width: media.width * 0.29,
                  labelFontSize: 15,
                  customPadding: EdgeInsets.fromLTRB(10, 5, 30, 0),
                  validator: _requiredValidator
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select at least one.';
                  }
                  return null;
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
              // Valid ID
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    UploadImageBox(
                      label: "Capture Valid ID",
                      imageFile: validIdImage, 
                      onPickFile: () async {
                        await _pickImage((file) => validIdImage = file);
                        return validIdImage;
                      },
                      // validator: (imageFile) {
                      //   if (imageFile == null) {
                      //     return 'Please upload a valid ID.';
                      //   }
                      //   return null;
                      // },
                    ),
                    // Proof of Residency
                    const SizedBox(height: 10),
                    UploadImageBox(
                      label: "Upload Proof of Residency",
                      imageFile: residencyImage, onPickFile: () async {
                        await _pickImage((file) => residencyImage = file);
                        return residencyImage;
                      },
                      // validator: (imageFile) {
                      //   if (imageFile == null) {
                      //     return 'Please upload your proof of residency.';
                      //   }
                      //   return null;
                      // },
                    ),
                    // Signature
                    const SizedBox(height: 10),
                    UploadImageBox(
                      label: "Applicant Signature over Printed Name",
                      imageFile: signatureImage, onPickFile: () async {
                        await _pickImage((file) => signatureImage = file);
                        return signatureImage;
                      },
                      // validator: (imageFile) {
                      //   if (imageFile == null) {
                      //     return 'Please upload your signature over printed name.';
                      //   }
                      //   return null;
                      // },
                    ),
                  ],
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
                  fontSize: isSmallScreen ? 16 : 14,
                  height: 45,
                onClick: _submitBarangayID
                ),
                ),
              ),]
          ),),
        ),
      ),
    );
  }
}