import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/date_picker.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/pages/additional_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});



  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  final _formKey = GlobalKey<FormState>();
  String? gender;
  DateTime? _selectedDate;
  String? _selectedCivilStatus;
  String? _selectedVoterStatus;

  // Initialize the TextEditingControllers
  final TextEditingController email = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController midName = TextEditingController();
  final TextEditingController birthDate = TextEditingController();
  final TextEditingController birthPlace = TextEditingController();
  final TextEditingController citizenship = TextEditingController();
  final TextEditingController houseNum = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController zipCode = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController voterStatus = TextEditingController();

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

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _navigateToPwdInfo() {
    if (_formKey.currentState!.validate()) {
      final profileData = {
        'email': email.text,
        'lastName': lastName.text,
        'firstName': firstName.text,
        'middleName': midName.text,
        'gender': gender,
        'birthDate': _selectedDate?.toIso8601String().split('T').first,
        'birthPlace': birthPlace.text,
        'citizenship': citizenship.text,
        'houseNum': houseNum.text,
        'street': street.text,
        'city': city.text,
        'province': province.text,
        'zipCode': zipCode.text,
        'contactNumber': contactNumber.text,
        'civilStatus': _selectedCivilStatus,
        'voterStatus': _selectedVoterStatus,
      };
      Navigator.push(
        context,
        CustomPageRoute(page: AdditionalInfo(profileData: profileData)),
      );
    } else {
      // This is where you would show a snackbar or dialog if the form is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All text fields and options must have values.",
            style: TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElementColors.secondary
        ),
      );
    }
  }

  @override
  void dispose() {
    email.dispose();
    lastName.dispose();
    firstName.dispose();
    midName.dispose();
    birthDate.dispose();
    birthPlace.dispose();
    citizenship.dispose();
    houseNum.dispose();
    street.dispose();
    city.dispose();
    province.dispose();
    zipCode.dispose();
    contactNumber.dispose();
    voterStatus.dispose();
    super.dispose();
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
                      "Profile Information",
                      style: TextStyle(
                        fontSize: media.height * 0.033,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Email
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Email:',
                  hint: "ninya@gmail.com",
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _requiredValidator,
                ),
                // Last Name
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Last Name:',
                  hint: "Ex: Pascua",
                  controller: lastName,
                  validator: _requiredValidator,
                ),
                // First Name
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: 'First Name:',
                  hint: "Ex: Maria Niña Grace",
                  controller: firstName,
                  validator: _requiredValidator,
                ),
                // Middle Name
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Middle Name:',
                  hint: "Ex: Lacson",
                  controller: midName,
                  validator: _requiredValidator,
                ),
                // Gender
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Gender',
                  options: const ['Male', 'Female'],
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                  inline: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a gender.";
                    }
                    return null;
                  },
                ),
                // Date of birth
                const SizedBox(height: 10),
                InkWell(
                  // Use the reusable function here
                  onTap: () async {
                    final picked = await showCustomDatePicker(context);
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        birthDate.text = DateFormat('MM/dd/yyyy').format(_selectedDate!);
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
                      validator: _requiredValidator,
                    ),
                  ),
                ),
                // Place of birth
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Place of Birth:',
                  hint: "Ex: Angeles City, Pampanga",
                  controller: birthPlace,
                  validator: _requiredValidator,
                ),
                // Citizenship
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Citizenship:',
                  hint: "Ex: Filipino",
                  controller: citizenship,
                  validator: _requiredValidator,
                ),
                // Address
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 5, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Address',
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
                      customPadding: const EdgeInsets.fromLTRB(40, 5, 0, 0),
                      validator: _requiredValidator,
                    ),
                    TxtField(
                      type: TxtFieldType.services,
                      label: 'Street:',
                      hint: "Ex: San Juan",
                      controller: street,
                      width: media.width * 0.5,
                      labelFontSize: 15,
                      customPadding: const EdgeInsets.fromLTRB(0, 5, 30, 0),
                      validator: _requiredValidator,
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
                  customPadding: const EdgeInsets.fromLTRB(40, 5, 30, 0),
                  validator: _requiredValidator,
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
                      customPadding: const EdgeInsets.fromLTRB(40, 5, 0, 0),
                      validator: _requiredValidator,
                    ),
                    TxtField(
                      type: TxtFieldType.services,
                      label: 'Zip Code:',
                      hint: "Ex: 2007",
                      controller: zipCode,
                      width: media.width * 0.29,
                      labelFontSize: 15,
                      customPadding: const EdgeInsets.fromLTRB(10, 5, 30, 0),
                      validator: _requiredValidator,
                    ),
                  ],
                ),
                // Contact Number
                const SizedBox(height: 20),
                TxtField(
                  type: TxtFieldType.services,
                  label: 'Contact Number:',
                  hint: "Ex: 09xx xxx xxxx",
                  controller: contactNumber,
                  keyboardType: TextInputType.number,
                  validator: _requiredValidator,
                ),
                // Civil Status
                const SizedBox(height: 20),
                _buildCivilStatusDropdown(),
                
                // Voter Status
                const SizedBox(height: 20),
                RadioButtons(
                  label: 'Voter Status',
                  options: const ['Active', 'Inactive', 'Cancelled'],
                  onChanged: (value) {
                    setState(() {
                      _selectedVoterStatus = value;
                    });
                  },
                  inline: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a voter status.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: media.width * 0.5,
                  child: Buttons(
                    title: "Next",
                    type: BtnType.secondary,
                    fontSize: 16,
                    height: 45,
                    onClick: _navigateToPwdInfo,
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
