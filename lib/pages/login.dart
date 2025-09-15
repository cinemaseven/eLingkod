import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/textfields.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/signup.dart';
import 'package:flutter/material.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool useEmail = true;

  TextEditingController email = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController password = TextEditingController();

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
          const SizedBox(height: 5),
          Center(
            child: Image.asset(
              "assets/images/logo.png",
              width: media.width * 0.5,
            ),
          ),
          const SizedBox(height: 20),
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
              padding: const EdgeInsets.fromLTRB(45, 20, 45, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 30,
                        // fontWeight: FontWeight.bold,
                        color: ElementColors.fontColor2,
                      ),
                    ),
                    const SizedBox(height: 20),
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

                    const SizedBox(height: 15),
                    TxtField(
                        type: TxtFieldType.regis,
                        controller: password,
                        hint: "Password",
                        obscure: true,
                      ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child:  Buttons(
                        title: "Log In",
                        type: BtnType.secondary,
                        fontSize: 16,
                        height: 50,
                        onClick: () {
                          Navigator.push(context, CustomPageRoute(page: Home()),);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 10),
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
                    
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child:  Buttons(
                        title: useEmail
                          ? "Log in using contact number"
                          : "Log in using email",
                        type: BtnType.tertiary,
                        fontSize: 16,
                        height: 50,
                        onClick: () {
                          setState(() { useEmail = !useEmail; });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: Signup()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: ElementColors.fontColor2,
                            fontWeight: FontWeight.normal,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: ElementColors.fontColor2,
                                fontWeight: FontWeight.bold,
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
