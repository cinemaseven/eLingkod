import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/pages/pwd_info.dart';
import 'package:elingkod/pages/signup.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatefulWidget {
  final String emailOrContact;
  const ProfileInfo({super.key, required this.emailOrContact});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  String? gender;

  // Initialize the TextEditingControllers
  final TextEditingController email = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController midName = TextEditingController();
  final TextEditingController birthDate = TextEditingController();
  final TextEditingController birthPlace = TextEditingController();
  final TextEditingController houseNum = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController zipCode = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController civilStatus = TextEditingController();
  final TextEditingController voterStatus = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the email controller's initial text from the value passed to the widget.
    email.text = widget.emailOrContact;
  }

  void _navigateToPwdInfo() {
    final profileData = {
      'emailOrContact': email.text,
      'lastName': lastName.text,
      'firstName': firstName.text,
      'midName': midName.text,
      'gender': gender,
      'birthDate': birthDate.text,
      'birthPlace': birthPlace.text,
      'houseNum': houseNum.text,
      'street': street.text,
      'city': city.text,
      'province': province.text,
      'zipCode': zipCode.text,
      'contactNumber': contactNumber.text,
      'civilStatus': civilStatus.text,
      'voterStatus': voterStatus.text,
    };
    Navigator.push(
      context,
      CustomPageRoute(page: PwdInfo(profileData: profileData)),
    );
  }

  @override
  void dispose() {
    email.dispose();
    lastName.dispose();
    firstName.dispose();
    midName.dispose();
    birthDate.dispose();
    birthPlace.dispose();
    houseNum.dispose();
    street.dispose();
    city.dispose();
    province.dispose();
    zipCode.dispose();
    contactNumber.dispose();
    civilStatus.dispose();
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
      body: SingleChildScrollView(
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
                    onPressed: () => Navigator.push(
                      context,
                      CustomPageRoute(page: Signup()),
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
              ),
              // Last Name
              const SizedBox(height: 20),
              TxtField(
                type: TxtFieldType.services,
                label: 'Last Name:',
                hint: "Ex: Pascua",
                controller: lastName,
              ),
              // First Name
              const SizedBox(height: 20),
              TxtField(
                type: TxtFieldType.services,
                label: 'First Name:',
                hint: "Ex: Maria Niña Grace",
                controller: firstName,
              ),
              // Middle Name
              const SizedBox(height: 20),
              TxtField(
                type: TxtFieldType.services,
                label: 'Middle Name:',
                hint: "Ex: Lacson",
                controller: midName,
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
              ),
              // Date of birth
              const SizedBox(height: 10),
              TxtField(
                type: TxtFieldType.services,
                label: 'Date of Birth:',
                hint: "ayoko muna ayusin",
                controller: birthDate,
              ),
              // Place of birth
              const SizedBox(height: 20),
              TxtField(
                type: TxtFieldType.services,
                label: 'Place of Birth:',
                hint: "Ex: Angeles City, Pampanga",
                controller: birthPlace,
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
                  ),
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Street:',
                    hint: "Ex: San Juan",
                    controller: street,
                    width: media.width * 0.5,
                    labelFontSize: 15,
                    customPadding: const EdgeInsets.fromLTRB(0, 5, 30, 0),
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
                  ),
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Zip Code:',
                    hint: "Ex: 2007",
                    controller: zipCode,
                    width: media.width * 0.29,
                    labelFontSize: 15,
                    customPadding: const EdgeInsets.fromLTRB(10, 5, 30, 0),
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
              ),
              // Civil and Voter Status
              const SizedBox(height: 20),
              Row(
                children: [
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Civil Status:',
                    hint: "Civil Status",
                    controller: civilStatus,
                    width: media.width * 0.41,
                    customPadding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
                  ),
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Voter Status:',
                    hint: "Voter Status",
                    controller: voterStatus,
                    width: media.width * 0.41,
                    customPadding: const EdgeInsets.fromLTRB(10, 5, 30, 0),
                  ),
                ],
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
    );
  }
}
