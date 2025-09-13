import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/buttons.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/pages/login.dart';
import 'package:elingkod/pages/signup.dart';
import 'package:flutter/material.dart';

class Registration extends StatelessWidget {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(backgroundColor: ElementColors.primary),

      body: Stack(
        alignment: Alignment.center,
        children: [
          // logo
          Positioned(
            top: media.height * -0.1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 130, minHeight: 300),
              child: Image.asset(
                "assets/images/logo.png",
                width: media.width * 0.8,
                height: media.height * 0.8,
              ),
            ),
          ),

          // log in button
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 200, maxWidth: 290),
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // distance from bottom
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // log in button
                    Buttons(
                      title: "Sign Up",
                      onClick: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: Signup()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // divider "or"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            endIndent: 10,
                            color: ElementColors.primary,
                          ),
                        ),
                        Text(
                          "or",
                          style: TextStyle(
                            fontSize: 16,
                            color: ElementColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            indent: 10,
                            color: ElementColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // sign up button
                    Buttons(
                      title: "Log In",
                      type: BtnType.txtPrimary,
                      onClick: () {
                        Navigator.push(context, CustomPageRoute(page: Login()));
                      },
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
