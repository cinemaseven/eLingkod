import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/hamburger.dart';
import 'package:elingkod/services/userData_service.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _profileImage;
  UserDetails? _userDetails; // data fetched from DB
  bool _loading = true;
  bool _hasChanged = false; // track if user made changes

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final details = await UserDataService().fetchUserDetails();
      setState(() {
        _userDetails = details;
        _loading = false;
        _hasChanged = false;
      });
    } catch (e) {
      print("Error loading user details: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_userDetails == null) return;

    try {
      await UserDataService().updateUserDetails({
        'gender': _userDetails?.gender,
        'dob': _userDetails?.birthDate,
        'age': _userDetails?.age,
        'pob': _userDetails?.birthPlace,
        'civil': _userDetails?.civilStatus,
        'contact': _userDetails?.contactNumber,
        'voter': _userDetails?.voterStatus,
        'citizenship': _userDetails?.province,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile updated successfully",
            style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary
        ),
      );

      setState(() => _hasChanged = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e",
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
    final size = MediaQuery.of(context).size;
    double responsiveFont(double base) => base * (size.width / 390);

  Widget buildRow(
    String label,
    String? value, {
    bool editable = false,
    List<String>? options,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160, // 🔹 fixed width, enough space for all labels
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
              child: editable
                  ? DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: (options!.contains(value) ? value : null),
                        isExpanded: true,
                        isDense: true,
                        alignment: Alignment.centerLeft,
                        items: options.map((opt) {
                          return DropdownMenuItem(
                            value: opt,
                            child: Text(
                              opt,
                              style: TextStyle(fontSize: responsiveFont(12.5)),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              if (label == "Civil Status") {
                                _userDetails =
                                    _userDetails?.copyWith(civilStatus: newValue);
                              } else if (label == "Voter Status") {
                                _userDetails =
                                    _userDetails?.copyWith(voterStatus: newValue);
                              }
                              _hasChanged = true;
                            });
                          }
                        },
                      ),
                    )
                  : Text(
                      value ?? "-",
                      style: TextStyle(
                        fontSize: responsiveFont(12.5),
                        height: 1.5,
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userDetails == null
              ? const Center(child: Text("No profile data found"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // 🔹 Header + Avatar
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 70,
                            color: ElementColors.primary,
                          ),
                          Positioned(
                            bottom: -50,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: ElementColors.fontColor2,
                              child: _profileImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _profileImage!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.person,
                                      size: 70, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // 🔹 Name & contact
                      Text(
                        "${_userDetails?.firstName ?? ""} ${_userDetails?.middleName ?? ""} ${_userDetails?.lastName ?? ""}",
                        style: TextStyle(
                          color: ElementColors.fontColor1,
                          fontSize: responsiveFont(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   _userDetails?.contactNumber ??
                      //       "username, email, or phone",
                      //   style: TextStyle(
                      //     color: Colors.black54,
                      //     fontSize: responsiveFont(13),
                      //   ),
                      // ),

                      const SizedBox(height: 25),

                      // 🔹 Profile info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildRow("Email", _userDetails?.email),
                            buildRow("Contact Number", _userDetails?.contactNumber),
                            buildRow("Gender", _userDetails?.gender),
                            buildRow("Date of Birth", _userDetails?.birthDate),
                            buildRow("Age", _userDetails?.age),
                            buildRow("Place of Birth", _userDetails?.birthPlace),
                            buildRow("Citizenship", _userDetails?.citizenship),
                            buildRow(
                              "Address",
                              "${_userDetails?.houseNum ?? ""} ${_userDetails?.street ?? ""}, "
                              "${_userDetails?.city ?? ""} ${_userDetails?.province ?? ""}, "
                              "${_userDetails?.zipCode ?? ""}",
                            ),
                            buildRow(
                              "Civil Status",
                              _userDetails?.civilStatus,
                              editable: true,
                              options: [
                                "Single",
                                "Married",
                                "Divorced",
                                "Widowed",
                                "Separated"
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  _userDetails =
                                      _userDetails?.copyWith(civilStatus: newValue);
                                  _hasChanged = true;
                                });
                              },
                            ),
                            buildRow(
                              "Voter Status",
                              _userDetails?.voterStatus,
                              editable: true,
                              options: ["Active", "Inactive", "Cancelled"],
                              onChanged: (newValue) {
                                setState(() {
                                  _userDetails =
                                      _userDetails?.copyWith(voterStatus: newValue);
                                  _hasChanged = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔹 Save button
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width *
                              (MediaQuery.of(context).size.width < 600 ? 0.5 : 0.3),
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
                            child: const Text(
                              "Save",
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





// import 'dart:io';

// import 'package:elingkod/common_style/colors_extension.dart';
// import 'package:elingkod/common_widget/custom_pageRoute.dart';
// import 'package:elingkod/common_widget/hamburger.dart';
// import 'package:elingkod/pages/profile_edit.dart';
// import 'package:flutter/material.dart';

// class Profile extends StatefulWidget {
//   const Profile({super.key});

//   @override
//   State<Profile> createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   File? _profileImage;
//   String _name = "Maria Niña Grace Lacson Pascua";
//   String _username = "username, email, or phone";
//   String _gender = "Female";
//   String _dob = "01/02/2005";
//   String _pob = "Magalang, Pampanga";
//   String _citizenship = "Filipino";
//   String _address = "2009 Angeles, City";
//   String _civil = "Single";
//   String _email = "@gmail.com";
//   String _contact = "+63";
//   String _voter = "Active";


//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     double responsiveFont(double base) => base * (size.width / 390);

//     Widget buildRow(String label, String value) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8), // increased spacing
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 130, // slightly wider for label
//               child: Text(
//                 "$label:",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: responsiveFont(14),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: responsiveFont(14),
//                     height: 1.5, // more line height for readability
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: ElementColors.primary,
//         elevation: 0,
//         iconTheme: IconThemeData(color: ElementColors.fontColor2),
//       ),
//       drawer: const Hamburger(),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // 🔹 Header + Avatar
//             Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: ElementColors.primary,
//                   ),
//                 ),
//                 Positioned(
//                   top: 20,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Text(
//                       "Profile",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: responsiveFont(20),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: -50,
//                   child: CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Colors.white,
//                     child: _profileImage != null
//                         ? ClipOval(
//                             child: Image.file(
//                               _profileImage!,
//                               width: 100,
//                               height: 100,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : const Icon(Icons.person, size: 70, color: Colors.grey),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 60),

//             Text(
//               _name,
//               style: TextStyle(
//                 color: Colors.black87,
//                 fontSize: responsiveFont(18),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _username,
//               style: TextStyle(
//                 color: Colors.black54,
//                 fontSize: responsiveFont(13),
//               ),
//             ),

//             const SizedBox(height: 25),

//             // 🔹 Profile info
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 25),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   buildRow("Gender", _gender),
//                   buildRow("Date of birth", _dob),
//                   buildRow("Place of birth", _pob),
//                   buildRow("Citizenship", _citizenship),
//                   buildRow("Address", _address),
//                   buildRow("Civil Status", _civil),
//                   buildRow("Email", _email),
//                   buildRow("Contact number", _contact),
//                   buildRow("Voter Status", _voter),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             // 🔹 Edit Button
//             Center(
//               child: SizedBox(
//                 width: size.width * (size.width < 600 ? 0.5 : 0.3),
//                 height: 45,
//                 child: ElevatedButton(
//                   onPressed: _editProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: ElementColors.secondary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: const Text(
//                     "Edit",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }
