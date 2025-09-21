import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/form_fields.dart';
import 'package:elingkod/pages/pwd_info.dart';
import 'package:elingkod/pages/signup.dart';
import 'package:flutter/material.dart';


class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  // bool useEmail = true;
  String? gender;
  TextEditingController email = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController midName = TextEditingController();
  TextEditingController birthPlace = TextEditingController();
  TextEditingController houseNum = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController province = TextEditingController();
  TextEditingController zipCode = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController civilStatus = TextEditingController();
  TextEditingController voterStatus = TextEditingController();

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
            children:  [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  IconButton(
                    onPressed: () => Navigator.push(context, CustomPageRoute(page: Signup()),),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ElementColors.tertiary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
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
                options: ['Male', 'Female'], 
                onChanged: (value) { setState(() { gender = value; });},
                inline: true,
              ),
          
              // Date of birth
              const SizedBox(height: 10),
              TxtField(
                type: TxtFieldType.services,
                label: 'Date of Birth:',
                hint: "ayoko muna ayusin",
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
                    Text('Address', 
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
                  ),
          
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Street:',
                    hint: "Ex: San Juan",
                    controller: street,
                    width: media.width * 0.5,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(0, 5, 30, 0),
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
                  ),
          
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Zip Code:',
                    hint: "Ex: 2007",
                    controller: zipCode,
                    width: media.width * 0.29,
                    labelFontSize: 15,
                    customPadding: EdgeInsets.fromLTRB(10, 5, 30, 0),
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
                    customPadding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                  ),
          
                  TxtField(
                    type: TxtFieldType.services,
                    label: 'Voter Status:',
                    hint: "Voter Status",
                    controller: voterStatus,
                    width: media.width * 0.41,
                    customPadding: EdgeInsets.fromLTRB(10, 5, 30, 0),
                  ),
                ],
              ),

              
              const SizedBox(height: 40),
              SizedBox(
                width: media.width * 0.5,
                child:  Buttons(
                  title: "Next",
                  type: BtnType.secondary,
                  fontSize: 16,
                  height: 45,
                  onClick: () {
                    Navigator.push(context, CustomPageRoute(page: PwdInfo()),);
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}