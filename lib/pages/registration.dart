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
    final media = MediaQuery.of(context).size;
    final scaleFactor = MediaQuery.textScaleFactorOf(context);

    // Helper for consistent scaling
    double scaled(double base) => base * media.width * scaleFactor;

    return Scaffold(
      backgroundColor: ElementColors.fontColor2,
      appBar: AppBar(backgroundColor: ElementColors.primary),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Logo
          Positioned(
            top: media.height * -0.1,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: media.width * 0.3,
                minHeight: media.height * 0.3,
              ),
              child: Image.asset(
                "assets/images/logo.png",
                width: media.width * 0.8,
                height: media.height * 0.8,
              ),
            ),
          ),

          // Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: media.width * 0.5,
                maxWidth: media.width * 0.8,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: media.height * 0.18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Buttons(
                      title: "Sign Up",
                      fontSize: scaled(0.045), // scaled font
                      onClick: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: Signup()),
                        );
                      },
                    ),
                    SizedBox(height: media.height * 0.025),

                    // Divider "or"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            endIndent: media.width * 0.025,
                            color: ElementColors.primary,
                          ),
                        ),
                        Text(
                          "or",
                          style: TextStyle(
                            fontSize: scaled(0.04), // scaled font
                            color: ElementColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            indent: media.width * 0.025,
                            color: ElementColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: media.height * 0.025),

                    Buttons(
                      title: "Log In",
                      customFontColor: ElementColors.secondary,
                      type: BtnType.lightSecondary,
                      fontSize: scaled(0.045), // scaled font
                      onClick: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: Login()),
                        );
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
