import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/textfields.dart';
import 'package:elingkod/pages/login.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool useEmail = true;

  TextEditingController email = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();

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
      body: Column(
        children: [
          SizedBox(height: media.height * 0.02),
          Center(
            child: Image.asset(
              "assets/images/logo.png",
              width: media.width * 0.5,
            ),
          ),
          SizedBox(height: media.height * 0.03),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ElementColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: media.width * 0.1, vertical: media.height * 0.03),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: media.width * 0.08,
                        color: ElementColors.fontColor2,
                      ),
                    ),
                    SizedBox(height: media.height * 0.04),
                    if (useEmail)
                      TxtField(
                        type: TxtFieldType.regis,
                        controller: email,
                        hint: "Email",
                      )
                    else
                      TxtField(
                        type: TxtFieldType.regis,
                        controller: contactNumber,
                        hint: "Contact Number",
                      ),
                    SizedBox(height: media.height * 0.02),
                    TxtField(
                      type: TxtFieldType.regis,
                      controller: password,
                      hint: "Password",
                      obscure: true,
                    ),
                    SizedBox(height: media.height * 0.02),
                    TxtField(
                      type: TxtFieldType.regis,
                      controller: rePassword,
                      hint: "Re-enter password",
                      obscure: true,
                    ),
                    SizedBox(height: media.height * 0.05),
                    SizedBox(
                      width: double.infinity,
                      child: Buttons(
                        title: "Sign Up",
                        type: BtnType.secondary,
                        fontSize: media.width * 0.04,
                        height: media.height * 0.065,
                        onClick: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(page: ProfileInfo()),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: media.height * 0.02),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: ElementColors.fontColor2,
                            thickness: 1,
                            endIndent: 10,
                          ),
                        ),
                        Text(
                          "or",
                          style: TextStyle(color: ElementColors.fontColor2),
                        ),
                        Expanded(
                          child: Divider(
                            color: ElementColors.fontColor2,
                            thickness: 1,
                            indent: 10,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: media.height * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: Buttons(
                        title: useEmail
                            ? "Sign up using contact number"
                            : "Sign up using email",
                        type: BtnType.tertiary,
                        fontSize: media.width * 0.04,
                        height: media.height * 0.065,
                        onClick: () {
                          setState(() {
                            useEmail = !useEmail;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: media.height * 0.03),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: Login()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: ElementColors.fontColor2,
                            fontWeight: FontWeight.normal,
                            fontSize: media.width * 0.035,
                          ),
                          children: [
                            TextSpan(
                              text: "Log In",
                              style: TextStyle(
                                color: ElementColors.fontColor2,
                                fontWeight: FontWeight.bold,
                                fontSize: media.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}