import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:elingkod/services/userData_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PwdInfo extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const PwdInfo({super.key, required this.profileData});

  @override
  State<PwdInfo> createState() => _PwdInfoState();
}

class _PwdInfoState extends State<PwdInfo> {
  final _formKey = GlobalKey<FormState>();
  String? yesOrNo;
  File? _frontImage;
  File? _backImage;

  final TextEditingController idNum = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final UserDataService _userDataService = UserDataService();

  // pick Front ID
  Future<void> _pickFrontImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _frontImage = File(pickedFile.path);
      });
    }
  }

  // pick Back ID
  Future<void> _pickBackImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _backImage = File(pickedFile.path);
      });
    }
  }

 // REFACTORED: Function now calls the service method for all persistence logic
  void _createProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 1. Validate the form.
    if (_formKey.currentState!.validate()) {
      try {
        final String idNumber = idNum.text.trim();

        // 2. Call the service to handle data upload, DB upsert, and metadata update
        await _userDataService.saveCompleteOnboardingProfile(
          initialProfileData: widget.profileData,
          yesOrNo: yesOrNo,
          idNum: idNumber,
          frontImage: _frontImage,
          backImage: _backImage,
        );

        // 3. Show success message and navigate to the Home page.
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Profile created successfully!')),
        );
        // Use pushReplacement to prevent returning to the profile creation flow
        Navigator.of(context).pushReplacement(
          CustomPageRoute(page: const Home()),
        );
      } on AuthException catch (e) {
        // Handle Supabase Auth errors raised by the service
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Authentication Error: ${e.message}"),
            backgroundColor: ElementColors.tertiary,
          ),
        );
      } on Exception catch (e) {
        // Catch upload errors, database errors, and custom exceptions raised by the service
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Error completing profile: ${e.toString().split(':').last.trim()}"),
            backgroundColor: ElementColors.tertiary,
          ),
        );
      } catch (e) {
        // Catch other general errors
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}"),
            backgroundColor: ElementColors.tertiary,
          ),
        );
      }
    } else {
      // If validation fails, show a general error message.
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text("Please fill out all required fields."),
          backgroundColor: ElementColors.tertiary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ElementColors.fontColor2,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ElementColors.primary,
        iconTheme: IconThemeData(color: ElementColors.fontColor2),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Back button + title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        CustomPageRoute(
                          page: ProfileInfo(
                            emailOrContact: widget.profileData['emailOrContact'],
                          ),
                        ),
                      ),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ElementColors.tertiary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Text(
                      "PWD Information",
                      style: TextStyle(
                        fontSize: media.height * 0.033,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                  child: Text(
                    "Please answer the following question to help us determine your eligibility for PWD-specific benefits and services.",
                    style: TextStyle(fontSize: media.height * 0.017),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 7),
                Divider(
                  color: ElementColors.fontColor1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                // Yes/No PWD question
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Are you a registered Person with Disability (PWD) in the Philippines?',
                  options: ['Yes', 'No'],
                  onChanged: (value) {
                    setState(() {
                      yesOrNo = value;
                    });
                  },
                  inline: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please choose either yes or no.";
                    }
                    return null;
                  },
                ),
                // PWD ID number
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: 'If Yes, Can you provide your PWD ID number:*',
                  hint: "RR-PPMM-BBB-NNNNNNN",
                  controller: idNum,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (yesOrNo == 'Yes' && (value == null || value.isEmpty)) {
                      return 'This field is required.';
                    }
                    return null;
                  },
                ),
                // Upload section
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 40, 30, 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Please upload a clear, high-resolution photo of your PWD ID:",
                      style: TextStyle(fontSize: media.height * 0.017),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      FormField<File>(
                        builder: (FormFieldState<File> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UploadImageBox(
                                label: "Front PWD ID *",
                                imageFile: _frontImage,
                                onTap: () async {
                                  await _pickFrontImage();
                                  state.didChange(_frontImage);
                                },
                              ),
                              if (state.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                                  child: Text(
                                    state.errorText ?? '',
                                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                                  ),
                                ),
                            ],
                          );
                        },
                        validator: (imageFile) {
                          if (yesOrNo == 'Yes' && imageFile == null) {
                            return 'Please upload the front image.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      FormField<File>(
                        builder: (FormFieldState<File> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UploadImageBox(
                                label: "Back PWD ID *",
                                imageFile: _backImage,
                                onTap: () async {
                                  await _pickBackImage();
                                  state.didChange(_backImage);
                                },
                              ),
                              if (state.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                                  child: Text(
                                    state.errorText ?? '',
                                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                                  ),
                                ),
                            ],
                          );
                        },
                        validator: (imageFile) {
                          if (yesOrNo == 'Yes' && imageFile == null) {
                            return 'Please upload the back image.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: media.width * 0.5,
                  child: Buttons(
                    title: "Create Profile",
                    type: BtnType.secondary,
                    fontSize: 16,
                    height: 45,
                    onClick: _createProfile,
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