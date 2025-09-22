import 'dart:io';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PwdInfo extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const PwdInfo({super.key, required this.profileData});

  @override
  State<PwdInfo> createState() => _PwdInfoState();
}

class _PwdInfoState extends State<PwdInfo> {
  String? yesOrNo;
  TextEditingController idNum = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _frontImage;
  File? _backImage;

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

  Future<void> _createProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final url = Uri.parse(
      'http://localhost:3000/complete-profile',
    ); // Or your IP address

    // Check if the user is a PWD and if the required fields are filled
    if (yesOrNo == 'Yes') {
      if (idNum.text.isEmpty || _frontImage == null || _backImage == null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Please fill out all PWD information and upload both images.',
            ),
          ),
        );
        return;
      }
    }

    try {
      final request = http.MultipartRequest('POST', url);

      // Add text fields to the request
      request.fields.addAll(
        widget.profileData.map((key, value) => MapEntry(key, value.toString())),
      );
      request.fields['isPwd'] = yesOrNo ?? 'No';
      request.fields['pwdIdNum'] = idNum.text;

      // Add image files to the request
      if (_frontImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('frontImage', _frontImage!.path),
        );
      }
      if (_backImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('backImage', _backImage!.path),
        );
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(resBody);

      if (response.statusCode == 201) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Profile created successfully!')),
        );
        Navigator.push(context, CustomPageRoute(page: Home()));
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              decodedResponse['message'] ?? 'Profile creation failed.',
            ),
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
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
      body: SingleChildScrollView(
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
                label:
                    'Are you a registered Person with Disability (PWD) in the Philippines?',
                options: ['Yes', 'No'],
                onChanged: (value) {
                  setState(() {
                    yesOrNo = value;
                  });
                },
                inline: true,
              ),
              // PWD ID number
              const SizedBox(height: 20),
              TxtField(
                type: TxtFieldType.services,
                label: 'If Yes, Can you provide your PWD ID number:*',
                hint: "RR-PPMM-BBB-NNNNNNN",
                controller: idNum,
                keyboardType: TextInputType.number,
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
                    UploadImageBox(
                      label: "Front PWD ID *",
                      imageFile: _frontImage,
                      onTap: _pickFrontImage,
                    ),
                    const SizedBox(height: 20),
                    UploadImageBox(
                      label: "Back PWD ID *",
                      imageFile: _backImage,
                      onTap: _pickBackImage,
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
    );
  }
}
