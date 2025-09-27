import 'dart:io';

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/date_picker.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/common_widget/img_file_upload.dart';
import 'package:elingkod/common_widget/terms_agreement.dart';
import 'package:elingkod/pages/home.dart';
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
  String? ownOrRent;
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
  final TextEditingController contactNum = TextEditingController();
  final TextEditingController birthplace = TextEditingController();
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
                // Header with back and button
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
                              content: Text("Barangay Clearance button tapped!"),
                              duration: Duration(seconds: 2),
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
                onTap: () async {
                  final picked = await showCustomDatePicker(context);
                  if (picked != null) {
                    setState(() {
                      _selectedApplicationDate = picked;
                      birthDate.text = DateFormat('MM/dd/yyyy').format(_selectedApplicationDate!);
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                  ),
                ),
                ),
                            
                // Own or Rent
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Own or Rent', 
                  options: ['Own', 'Rent'], 
                  onChanged: (value) { setState(() { ownOrRent = value; });},
                  inline: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select.';
                    }
                    return null;
                  },
                ),
                            
                // Length of Stay
                const SizedBox(height: 10),
                TxtField(
                  label: "Length of Stay",
                  type: TxtFieldType.services,
                  hint: "Days",
                  controller: lengthStay,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required.';
                    }
                    return null;
                  },
                ),
                
                // Clearance Number
                const SizedBox(height: 20),
                TxtField(
                  label: "Clearance Number",
                  type: TxtFieldType.services,
                  hint: "Enter Clearance Number",
                  controller: clearanceNum,
                  validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
                ),
                            
                // Full Name
                const SizedBox(height: 20),
                TxtField(
                  label: "Full Name",
                  type: TxtFieldType.services,
                  hint: "Last, First, Middle",
                  controller: fullName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required.';
                    }
                    return null;
                  },
                ),
                            
                // Gender
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Gender', 
                  options: ['Male', 'Female'], 
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
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
                  ),
                                
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Street:',
                    hint: "Ex: San Juan",
                    controller: street,
                    width: media.width * 0.5,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
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
                validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
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
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
                  ),
                                
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Zip Code:',
                    hint: "Ex: 2007",
                    controller: zipCode,
                    width: media.width * 0.29,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(10, 5, 30, 0),
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
                  ),
                ],
                ),
        
                const SizedBox(height: 20),
                InkWell(
                // Use the reusable function here
                onTap: () async {
                  final picked = await showCustomDatePicker(context);
                  if (picked != null) {
                    setState(() {
                      _selectedBirthDate = picked;
                      birthDate.text = DateFormat('MM/dd/yyyy').format(_selectedBirthDate!);
                    });
                  }
                },
                child: IgnorePointer(
                  child: TxtField(
                    type: TxtFieldType.services,
                    label: 'Date of Birth',
                    hint: "MM/DD/YYYY",
                    controller: birthDate,
                    suffixIcon: Icon(Icons.calendar_today, color: ElementColors.primary),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
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
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
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
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
                  ),
                ],
                ),
                            
                // Place of Birth
                const SizedBox(height: 20),
                TxtField(
                  label: "Place of Birth",
                    type: TxtFieldType.services,
                    hint: "Place of Birth",
                    controller: birthplace,
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required.';
                        }
                        return null;
                      },
                  ),
                
                // Nationality
                const SizedBox(height: 20),
                TxtField(
                  label: "Nationality",
                    type: TxtFieldType.services,
                    hint: "Nationality",
                    controller: nationality,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                  ),
                            
                // Clearance Purpose
                const SizedBox(height: 20),
                TxtField(
                  label: "Clearance Purpose",
                    type: TxtFieldType.services,
                    hint: "Enter Purpose",
                    controller: purpose,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                      return null;
                    },
                ),
                            
                // Signature (Image)
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: UploadImageBox(
                    label: "Applicant Signature over Printed Name",
                    imageFile: signatureImage,
                    onTap: () => _pickImage((file) => signatureImage = file),
                  ),
                ),
                            
                // const SizedBox(height: 20),
                // Container(
                //   height: media.width < 400 ? 100 : 120, // Responsive height
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.grey.shade400),
                //     borderRadius: BorderRadius.circular(15),
                //   ),
                //   child: Center(
                //       child: Text("Upload Files", style: labelStyle)),
                // ),
                            
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
                  onClick: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => TermsPopup(
                        onConfirmed: () {
                          Navigator.pop(dialogContext); // close TermsPopup
                          // Delay pushReplacement until after pop is finished
                          Future.microtask(() {
                            Navigator.pushReplacement(
                              context,
                              CustomPageRoute(page: const Home(showConfirmation: true)),
                            );
                          });
                        }
                      ),
                    );
                  }
                  ),
                  ),
                ),],),
          )
        ),
      ),
    );
  }
}