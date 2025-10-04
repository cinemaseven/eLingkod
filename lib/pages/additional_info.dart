import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/services/userData_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdditionalInfo extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const AdditionalInfo({super.key, required this.profileData});

  @override
  State<AdditionalInfo> createState() => _AdditionalInfoState();
}

class _AdditionalInfoState extends State<AdditionalInfo> {
  final _formKey = GlobalKey<FormState>();
  String? seniorYesOrNo;
  File? _seniorCardImage;
  String? pwdYesOrNo;
  File? _frontPWDImage;
  File? _backPWDImage;

  final TextEditingController idNum = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final UserDataService _userDataService = UserDataService();

   // Pick an image (for Senior Card / PWD Card)
  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        onSelected(File(pickedFile.path));
      });
    }
  }
  
  void _createProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 1. Validate the form.
    if (_formKey.currentState!.validate()) {
      try {
        // Get ID number, but only if "Yes" is selected. Otherwise, set it to null.
        final String? idNumber = (pwdYesOrNo == 'Yes') ? idNum.text.trim() : null;

        // Set images to null if the user selected "No"
        final File? seniorCardImage = (seniorYesOrNo == 'Yes') ? _seniorCardImage: null;
        final File? frontPWDImage = (pwdYesOrNo == 'Yes') ? _frontPWDImage : null;
        final File? backPWDImage = (pwdYesOrNo == 'Yes') ? _backPWDImage : null;

        // 3. Call the service to handle data upload, DB upsert, and metadata update
        await _userDataService.saveCompleteOnboardingProfile(
          initialProfileData: widget.profileData,
          seniorYesOrNo: seniorYesOrNo,
          seniorCardImage: seniorCardImage,
          pwdYesOrNo: pwdYesOrNo,
          idNum: idNumber,
          frontPWDImage: frontPWDImage,
          backPWDImage: backPWDImage,
        );

        // 4. Show success message and navigate to the Home page.
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Profile created successfully!',
              style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
          ),
        );
        Navigator.of(context).pushReplacement(
          CustomPageRoute(page: const Home()),
        );
      } on AuthException catch (e) {
        // Handle Supabase Auth errors raised by the service
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Authentication Error: ${e.message}",
              style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
          ),
        );
      } on Exception catch (e) {
        // Catch upload errors, database errors, and custom exceptions raised by the service
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "Error completing profile: ${e.toString()}",
              style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
          ),
        );
      } catch (e) {
        // Catch other general errors
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}",
              style: TextStyle(fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ElementColors.secondary
          ),
        );
      }
    } else {
      // If validation fails, show a general error message.
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Please fill out all required fields.",
            style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary
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
        autovalidateMode: AutovalidateMode.disabled,
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
                      onPressed: () => Navigator.pop(context),
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
                      "Additional Information",
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
                    "Please answer the following question to help us determine your eligibility for senior and PWD-specific benefits and services.",
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
                // Yes/No senior question
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Are you a senior citizen (60 years old and above)?',
                  options: ['Yes', 'No'],
                  onChanged: (value) {
                    setState(() {
                      seniorYesOrNo = value;
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
                
                // Show Senior Card Upload ONLY if Yes
                if (seniorYesOrNo == 'Yes') ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Please upload a clear, high-resolution photo of your Senior Citizen Card:",
                        style: TextStyle(fontSize: media.height * 0.017),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child:
                    UploadImageBox(
                      label: "Senior Citizen Card",
                      imageFile: _seniorCardImage, 
                      onPickFile: () async {
                        await  _pickImage((file) => _seniorCardImage = file);
                        return _seniorCardImage;
                      },
                      // validator: (imageFile) {
                      //   if (seniorYesOrNo == 'Yes' && imageFile == null) {
                      //     return 'Please upload your card..';
                      //   }
                      //   return null;
                      // },
                    ),
                  ),
                ],

                // Yes/No PWD question
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Are you a registered Person with Disability (PWD) in the Philippines?',
                  options: ['Yes', 'No'],
                  onChanged: (value) {
                    setState(() {
                      pwdYesOrNo = value;
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
                if (pwdYesOrNo == 'Yes') ...[
                  const SizedBox(height: 20),
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Please provide your PWD ID number:*',
                    hint: "RR-PPMM-BBB-NNNNNNN",
                    controller: idNum,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (pwdYesOrNo == 'Yes' && (value == null || value.isEmpty)) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                  ),
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
                        UploadImageBox(
                          label: "Front PWD ID ",
                          imageFile: _backPWDImage, 
                          onPickFile: () async {
                            await _pickImage((file) => _frontPWDImage = file);
                            return _frontPWDImage;
                          },
                          // validator: (imageFile) {
                          //   if (pwdYesOrNo == 'Yes' && imageFile == null) {
                          //     return 'Please upload the front image.';
                          //   }
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 20),
                        UploadImageBox(
                          label: "Back PWD ID ",
                          imageFile: _backPWDImage, 
                          onPickFile: () async {
                            await _pickImage((file) => _backPWDImage = file);
                            return _backPWDImage;
                          },
                          // validator: (imageFile) {
                          //   if (pwdYesOrNo == 'Yes' && imageFile == null) {
                          //     return 'Please upload the back image.';
                          //   }
                          //   return null;
                          // },
                        )
                      ],
                    ),
                  ),
                ],
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