import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/textfields.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:flutter/material.dart';


class PwdInfo extends StatefulWidget {
  const PwdInfo({super.key});

  @override
  State<PwdInfo> createState() => _PwdInfoState();
}

class _PwdInfoState extends State<PwdInfo> {
  // bool useEmail = true;

  TextEditingController idNum = TextEditingController();

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
                  onPressed: () => Navigator.push(context, CustomPageRoute(page: ProfileInfo()),),
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
                  "PWD Information", 
                  style: TextStyle(
                    fontSize: media.height * 0.033,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
              Text(
                "Please answer the following question to help us determine your eligibility for PWD-specific benefits and services.", 
                style: TextStyle(
                  fontSize: media.height * 0.017,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 7),
              Divider(
                color: ElementColors.fontColor1,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),

            // PWD ID num
            const SizedBox(height: 20),
            TxtField(
              type: TxtFieldType.services,
              label: 'If Yes, Can you provide your PWD ID number:*',
              hint: "RR-PPMM-BBB-NNNNNNN",
              controller: idNum,
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: media.width * 0.4,
              child:  Buttons(
                title: "Create Profile",
                type: BtnType.secondary,
                fontSize: 16,
                height: 45,
                onClick: () {
                  Navigator.push(context, CustomPageRoute(page: Home()),);
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}