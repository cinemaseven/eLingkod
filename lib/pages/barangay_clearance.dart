import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/date_picker.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/common_widget/terms_agreement.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/services/submitRequests_service.dart';
import 'package:elingkod/services/userData_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class BarangayClearance extends StatefulWidget {
  const BarangayClearance({super.key});

  @override
  State<BarangayClearance> createState() => _BarangayClearanceState();
}

class _BarangayClearanceState extends State<BarangayClearance> {
  final _formKey = GlobalKey<FormState>();
  UserDetails? _initialUserDetails;
  bool _loading = true;
  String? residencyType;
  String? gender;
  DateTime? _selectedApplicationDate;
  DateTime? _selectedBirthDate;
  String? _selectedCivilStatus;
  File? signatureImage;

  final double menuIconSize = 28;
  final TextStyle labelStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  final ImagePicker _picker = ImagePicker();

  final TextEditingController applicationDate = TextEditingController();

  final TextEditingController lengthStay = TextEditingController();
  final TextEditingController clearanceNum = TextEditingController();
  final TextEditingController fullName = TextEditingController();

  final TextEditingController houseNum = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController zipCode = TextEditingController();

  final TextEditingController birthDate = TextEditingController();

  final TextEditingController age = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController birthPlace = TextEditingController();
  final TextEditingController nationality = TextEditingController();
  final TextEditingController civilStatus = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController purpose = TextEditingController();

  Widget _buildCivilStatusDropdown() {
  final List<String> civilStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated'
  ];

  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 5, 30, 0), // Use the same padding as .services
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The label for the dropdown
        Text(
          'Civil Status:',
          style: TextStyle(
            fontSize: 15, // Match labelFontSize from TxtField
            fontWeight: FontWeight.w400,
            color: ElementColors.fontColor1,
          ),
        ),
        const SizedBox(height: 6), // Match the spacing from TxtField
        // The Container with the shadow effect
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ElementColors.shadow,
                blurRadius: 3,
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(10), // Match the border radius from TxtField's decoration
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Select Civil Status',
              hintStyle: TextStyle(color: ElementColors.placeholder),
              filled: true,
              fillColor: ElementColors.serviceField,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 15,
              ),
              // REMOVED: errorStyle: const TextStyle(height: 0),
            ),
            isExpanded: true,
            value: _selectedCivilStatus,
            icon: Icon(Icons.arrow_drop_down, color: ElementColors.primary),
            items: civilStatusOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                style: TextStyle(fontSize: 15, color: ElementColors.fontColor1)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCivilStatus = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a civil status.';
              }
              return null;
            },
          ),
        ),
      ],
    ),
  );
}

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

  Future<void> _loadAndAutofillUserDetails() async {
    try {
      final details = await UserDataService().fetchUserDetails();
      if (!mounted) return;

      _initialUserDetails = details;

      final joinNames = [details.firstName, details.middleName, details.lastName].where((n) => n != null && n.isNotEmpty);

      this.fullName.text = joinNames.join(' ');

      gender = details.gender;
      houseNum.text = details.houseNum ?? '';
      street.text = details.street ?? '';
      city.text = details.city ?? '';
      province.text = details.province ?? '';
      zipCode.text = details.zipCode ?? '';

      if (details.birthDate != null) {
        birthDate.text = details.birthDate!;
      }

      age.text = details.age ?? '';
      contactNumber.text = details.contactNumber ?? '';
      birthPlace.text = details.birthPlace ?? '';
      email.text = details.email ?? '';

      _selectedCivilStatus = details.civilStatus;
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
    lengthStay.dispose();
    clearanceNum.dispose();
    fullName.dispose();
    houseNum.dispose();
    street.dispose();
    city.dispose();
    province.dispose();
    zipCode.dispose();
    birthDate.dispose();
    age.dispose();
    contactNumber.dispose();
    birthPlace.dispose();
    nationality.dispose();
    civilStatus.dispose();
    email.dispose();
    purpose.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Pick an image (for Signature)
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
void _submitBarangayClearance() async {
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
            'residencyType': residencyType,
            'lengthStay': residencyType == 'Rent' ? lengthStay.text : null,
            'clearanceNum': clearanceNum.text,
            'fullName': fullName.text,
            'gender': gender,
            'houseNum': houseNum.text,
            'street': street.text,
            'city': city.text,
            'province': province.text,
            'zipCode': zipCode.text,
            'birthDate': birthDate.text,
            'age': age.text,
            'contactNumber': contactNumber.text,
            'birthPlace': birthPlace.text,
            'nationality': nationality.text,
            'civilStatus': _selectedCivilStatus,
            'email': email.text,
            'purpose': purpose.text,
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
          await submitService.submitBarangayClearance(formData: formData);

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
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
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
                        onPressed: () => Navigator.of(context).pushReplacement(CustomPageRoute(page: const Home())),
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
                              content: Text("Barangay Clearance button tapped!",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: ElementColors.secondary
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
                            
                // Residency Type
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Residency Type', 
                  options: ['Own', 'Rent'], 
                  onChanged: (value) { setState(() { residencyType = value; });},
                  inline: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select.';
                    }
                    return null;
                  },
                ),
                            
                // Length of Stay
                if (residencyType == 'Rent') ...[
                  const SizedBox(height: 10),
                  TxtField(
                    label: "Length of Stay",
                    type: TxtFieldType.services,
                    hint: "Days",
                    controller: lengthStay,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (residencyType == 'Rent') {
                        if (value == null || value.isEmpty) {
                          return 'Please enter length of stay.';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                
                // Clearance Number
                const SizedBox(height: 20),
                TxtField(
                  label: "Clearance Number",
                  type: TxtFieldType.services,
                  hint: "Enter Clearance Number",
                  controller: clearanceNum,
                  validator: _requiredValidator
                ),
                            
                // Full Name
                const SizedBox(height: 20),
                TxtField(
                  label: "Full Name",
                  type: TxtFieldType.services,
                  hint: "Last, First, Middle",
                  controller: fullName,
                  validator: _requiredValidator
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
                            
                // Address
                const SizedBox(height: 10),
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
        
                // Age
                const SizedBox(height: 20),
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
                            
                // Place of Birth
                const SizedBox(height: 20),
                TxtField(
                  label: "Place of Birth",
                    type: TxtFieldType.services,
                    hint: "Place of Birth",
                    controller: birthPlace,
                    validator: _requiredValidator
                  ),
                
                // Nationality
                const SizedBox(height: 20),
                TxtField(
                  label: "Nationality",
                    type: TxtFieldType.services,
                    hint: "Nationality",
                    controller: nationality,
                    validator: _requiredValidator
                  ),
                
                // Civil Status
                const SizedBox(height: 16),
                _buildCivilStatusDropdown(),
                
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
                            
                // Clearance Purpose
                const SizedBox(height: 20),
                TxtField(
                  label: "Clearance Purpose",
                    type: TxtFieldType.services,
                    hint: "Enter Purpose",
                    controller: purpose,
                    validator: _requiredValidator
                ),
                            
                // Signature (Image)
                const SizedBox(height: 30),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "Applicant Signature over Printed Name",
                    imageFile: signatureImage, 
                    onPickFile: () async {
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
                  onClick:  _submitBarangayClearance
                  ),
                  ),
                ),],),
          )))
        );
  }
}