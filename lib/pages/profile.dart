import 'dart:io';
import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/hamburger.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/pages/profile_edit.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _profileImage;
  String _name = "Maria Niña Grace Lacson Pascua";
  String _username = "username, email, or phone";
  String _gender = "Female";
  String _dob = "01/02/2005";
  String _pob = "Magalang, Pampanga";
  String _citizenship = "Filipino";
  String _address = "2009 Angeles, City";
  String _civil = "Single";
  String _email = "@gmail.com";
  String _contact = "+63";
  String _voter = "Active";

  Future<void> _editProfile() async {
    final updatedData = await Navigator.push(
      context,
      CustomPageRoute(
        page: ProfileEdit(
          profileImage: _profileImage,
          gender: _gender,
          dob: _dob,
          pob: _pob,
          citizenship: _citizenship,
          address: _address,
          civil: _civil,
          email: _email,
          contact: _contact,
          voter: _voter,
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        _profileImage = updatedData["profileImage"];
        _gender = updatedData["gender"];
        _dob = updatedData["dob"];
        _pob = updatedData["pob"];
        _citizenship = updatedData["citizenship"];
        _address = updatedData["address"];
        _civil = updatedData["civil"];
        _email = updatedData["email"];
        _contact = updatedData["contact"];
        _voter = updatedData["voter"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double responsiveFont(double base) => base * (size.width / 390);

    Widget buildRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8), // increased spacing
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130, // slightly wider for label
              child: Text(
                "$label:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFont(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: responsiveFont(14),
                    height: 1.5, // more line height for readability
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: ElementColors.fontColor2),
      ),
      drawer: const Hamburger(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Header + Avatar
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
                  top: 20,
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
              ],
            ),

            const SizedBox(height: 60),

            Text(
              _name,
              style: TextStyle(
                color: Colors.black87,
                fontSize: responsiveFont(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _username,
              style: TextStyle(
                color: Colors.black54,
                fontSize: responsiveFont(13),
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Profile info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildRow("Gender", _gender),
                  buildRow("Date of birth", _dob),
                  buildRow("Place of birth", _pob),
                  buildRow("Citizenship", _citizenship),
                  buildRow("Address", _address),
                  buildRow("Civil Status", _civil),
                  buildRow("Email", _email),
                  buildRow("Contact number", _contact),
                  buildRow("Voter Status", _voter),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Edit Button
            Center(
              child: SizedBox(
                width: size.width * (size.width < 600 ? 0.5 : 0.3),
                height: 45,
                child: ElevatedButton(
                  onPressed: _editProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElementColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
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
