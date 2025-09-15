import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/textfields.dart';
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

  TextEditingController email = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController midName = TextEditingController();
  TextEditingController birthPlace = TextEditingController();
  TextEditingController citizenship = TextEditingController();
  TextEditingController houseNum = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController province = TextEditingController();
  TextEditingController zipCode = TextEditingController();
  TextEditingController contactNumber = TextEditingController();

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
            
            const SizedBox(height: 40),
            SizedBox(
              width: media.width * 0.4,
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
      )
    );
  }
}