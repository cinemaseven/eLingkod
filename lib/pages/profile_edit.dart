import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/textfields.dart';
import 'package:elingkod/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEdit extends StatefulWidget {
  final File? profileImage;
  final String gender;
  final String dob;
  final String pob;
  final String citizenship;
  final String address;
  final String civil;
  final String email;
  final String contact;
  final String voter;

  const ProfileEdit({
    super.key,
    this.profileImage,
    this.gender = "",
    this.dob = "",
    this.pob = "",
    this.citizenship = "",
    this.address = "",
    this.civil = "",
    this.email = "",
    this.contact = "",
    this.voter = "",
  });

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  late final TextEditingController _genderCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _pobCtrl;
  late final TextEditingController _citizenshipCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _civilCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _voterCtrl;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _hasChanged = false;
  late Map<String, String> _originalValues;

  @override
  void initState() {
    super.initState();
    _profileImage = widget.profileImage;

    _genderCtrl = TextEditingController(text: widget.gender);
    _dobCtrl = TextEditingController(text: widget.dob);
    _pobCtrl = TextEditingController(text: widget.pob);
    _citizenshipCtrl = TextEditingController(text: widget.citizenship);
    _addressCtrl = TextEditingController(text: widget.address);
    _civilCtrl = TextEditingController(text: widget.civil);
    _emailCtrl = TextEditingController(text: widget.email);
    _contactCtrl = TextEditingController(text: widget.contact);
    _voterCtrl = TextEditingController(text: widget.voter);

    _originalValues = {
      "gender": _genderCtrl.text,
      "dob": _dobCtrl.text,
      "pob": _pobCtrl.text,
      "citizenship": _citizenshipCtrl.text,
      "address": _addressCtrl.text,
      "civil": _civilCtrl.text,
      "email": _emailCtrl.text,
      "contact": _contactCtrl.text,
      "voter": _voterCtrl.text,
    };

    for (var ctrl in [
      _genderCtrl,
      _dobCtrl,
      _pobCtrl,
      _citizenshipCtrl,
      _addressCtrl,
      _civilCtrl,
      _emailCtrl,
      _contactCtrl,
      _voterCtrl,
    ]) {
      ctrl.addListener(_checkChanges);
    }
  }

  void _checkChanges() {
    setState(() {
      _hasChanged = _genderCtrl.text != _originalValues["gender"] ||
          _dobCtrl.text != _originalValues["dob"] ||
          _pobCtrl.text != _originalValues["pob"] ||
          _citizenshipCtrl.text != _originalValues["citizenship"] ||
          _addressCtrl.text != _originalValues["address"] ||
          _civilCtrl.text != _originalValues["civil"] ||
          _emailCtrl.text != _originalValues["email"] ||
          _contactCtrl.text != _originalValues["contact"] ||
          _voterCtrl.text != _originalValues["voter"];
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _hasChanged = true;
      });
    }
  }

  void _saveProfile() {
    final updatedData = {
      "profileImage": _profileImage,
      "gender": _genderCtrl.text,
      "dob": _dobCtrl.text,
      "pob": _pobCtrl.text,
      "citizenship": _citizenshipCtrl.text,
      "address": _addressCtrl.text,
      "civil": _civilCtrl.text,
      "email": _emailCtrl.text,
      "contact": _contactCtrl.text,
      "voter": _voterCtrl.text,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile information updated",
          style: TextStyle(color: ElementColors.tertiary, fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ElementColors.fontColor2,
      ),
    );

    Navigator.pop(context, updatedData);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double responsiveFont(double base) => base * (size.width / 390);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        elevation: 0,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            CustomPageRoute(page: const Profile()),
          );
        },
  ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Header + Avatar with rounded top corners
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ElementColors.primary,
                  ),
                ),
                Positioned(
                  top: 20, // adjust spacing from top
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveFont(20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.person, size: 70, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            Text(
              "Maria Niña Grace Lacson Pascua",
              style: TextStyle(
                color: Colors.black87,
                fontSize: responsiveFont(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "username, email, or phone",
              style: TextStyle(
                color: Colors.black54,
                fontSize: responsiveFont(13),
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Profile Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Gender:"),
                  TxtField(type: TxtFieldType.profile, hint: "Female", controller: _genderCtrl),
                  const SizedBox(height: 10),
                  const Text("Date of birth:"),
                  TxtField(type: TxtFieldType.profile, hint: "01/02/2005", controller: _dobCtrl, readOnly: true),
                  const SizedBox(height: 10),
                  const Text("Place of birth:"),
                  TxtField(type: TxtFieldType.profile, hint: "Magalang, Pampanga", controller: _pobCtrl),
                  const SizedBox(height: 10),
                  const Text("Citizenship:"),
                  TxtField(type: TxtFieldType.profile, hint: "Filipino", controller: _citizenshipCtrl),
                  const SizedBox(height: 10),
                  const Text("Address:"),
                  TxtField(type: TxtFieldType.profile, hint: "2009 Angeles, City", controller: _addressCtrl),
                  const SizedBox(height: 10),
                  const Text("Civil Status:"),
                  TxtField(type: TxtFieldType.profile, hint: "Single", controller: _civilCtrl),
                  const SizedBox(height: 10),
                  const Text("Email:"),
                  TxtField(type: TxtFieldType.profile, hint: "@gmail.com", controller: _emailCtrl),
                  const SizedBox(height: 10),
                  const Text("Contact number:"),
                  TxtField(type: TxtFieldType.profile, hint: "+63", controller: _contactCtrl),
                  const SizedBox(height: 10),
                  const Text("Voter Status:"),
                  TxtField(type: TxtFieldType.profile, hint: "Active", controller: _voterCtrl),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Save Button
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * (MediaQuery.of(context).size.width < 600 ? 0.5 : 0.3),
                height: 45,
                child: ElevatedButton(
                  onPressed: _hasChanged ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElementColors.secondary,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
