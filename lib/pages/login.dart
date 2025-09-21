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

  final TextEditingController email = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

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
                      "Log In",
                      style: TextStyle(
                        fontSize: media.width * 0.08 > 32
                            ? 32
                            : media.width * 0.08,
                        color: ElementColors.fontColor2,
                      ),
                    ),
                    SizedBox(height: media.height * 0.04),
                    TxtField(
                      type: TxtFieldType.regis,
                      controller: useEmail ? email : contactNumber,
                      hint: useEmail ? "Email" : "Contact Number",
                    ),
                    SizedBox(height: media.height * 0.02),
                    TxtField(
                      type: TxtFieldType.regis,
                      controller: password,
                      hint: "Password",
                      obscure: true,
                    ),
                    SizedBox(height: media.height * 0.05),
                    SizedBox(
                      width: double.infinity,
                      child: Buttons(
                        title: "Log In",
                        type: BtnType.secondary,
                        fontSize: media.width * 0.04,
                        height: media.height * 0.065,
                        onClick: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(page: const Home()),
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
                            ? "Log in using contact number"
                            : "Log in using email",
                        type: BtnType.tertiary,
                        fontSize: media.width * 0.04,
                        height: media.height * 0.065,
                        onClick: () {
                          setState(() => useEmail = !useEmail);
                        },
                      ),
                    ),
                    SizedBox(height: media.height * 0.03),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: const Signup()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: ElementColors.fontColor2,
                            fontSize: media.width * 0.035,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign Up",
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



//mas maayos web neto!!!
// import 'package:elingkod/common_style/colors_extension.dart';
// import 'package:elingkod/common_widget/buttons.dart';
// import 'package:elingkod/common_widget/custom_pageRoute.dart';
// import 'package:elingkod/common_widget/textfields.dart';
// import 'package:elingkod/pages/home.dart';
// import 'package:elingkod/pages/signup.dart';
// import 'package:flutter/material.dart';
//
// class Login extends StatefulWidget {
//   const Login({super.key});
//
//   @override
//   State<Login> createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//   bool useEmail = true;
//
//   final TextEditingController email = TextEditingController();
//   final TextEditingController contactNumber = TextEditingController();
//   final TextEditingController password = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context).size;
//
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: ElementColors.fontColor2,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: ElementColors.primary,
//         iconTheme: IconThemeData(color: ElementColors.fontColor2),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final horizontalPadding = constraints.maxWidth > 1000
//               ? (constraints.maxWidth - 500) / 2
//               : constraints.maxWidth > 600
//               ? constraints.maxWidth * 0.15
//               : constraints.maxWidth * 0.08;
//
//           return SingleChildScrollView(
//             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: IntrinsicHeight(
//                 child: Column(
//                   children: [
//                     SizedBox(height: media.height * 0.02),
//                     Center(
//                       child: SizedBox(
//                         width: constraints.maxWidth > 600 ? 250 : constraints.maxWidth * 0.4,
//                         child: Image.asset(
//                           "assets/images/logo.png",
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: media.height * 0.03),
//                     Expanded(
//                       child: Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: ElementColors.primary,
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(30),
//                             topRight: Radius.circular(30),
//                           ),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: horizontalPadding,
//                           vertical: media.height * 0.04,
//                         ),
//                         child: ConstrainedBox(
//                           constraints: const BoxConstraints(maxWidth: 500),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Text(
//                                 "Log In",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: constraints.maxWidth * 0.08 > 32
//                                       ? 32
//                                       : constraints.maxWidth * 0.08,
//                                   color: ElementColors.fontColor2,
//                                 ),
//                               ),
//                               SizedBox(height: media.height * 0.025),
//                               TxtField(
//                                 type: TxtFieldType.regis,
//                                 controller: useEmail ? email : contactNumber,
//                                 hint: useEmail ? "Email" : "Contact Number",
//                               ),
//                               SizedBox(height: media.height * 0.015),
//                               TxtField(
//                                 type: TxtFieldType.regis,
//                                 controller: password,
//                                 hint: "Password",
//                                 obscure: true,
//                               ),
//                               SizedBox(height: media.height * 0.03),
//                               Buttons(
//                                 title: "Log In",
//                                 type: BtnType.secondary,
//                                 height: 50,
//                                 fontSize: 18,
//                                 onClick: () {
//                                   Navigator.push(
//                                     context,
//                                     CustomPageRoute(page: const Home()),
//                                   );
//                                 },
//                               ),
//                               SizedBox(height: media.height * 0.02),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                       child: Divider(color: ElementColors.fontColor2)),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                     child: Text("or",
//                                         style: TextStyle(color: ElementColors.fontColor2)),
//                                   ),
//                                   Expanded(
//                                       child: Divider(color: ElementColors.fontColor2)),
//                                 ],
//                               ),
//                               SizedBox(height: media.height * 0.02),
//                               Buttons(
//                                 title: useEmail
//                                     ? "Log in using contact number"
//                                     : "Log in using email",
//                                 type: BtnType.tertiary,
//                                 height: 50,
//                                 fontSize: 18,
//                                 onClick: () {
//                                   setState(() => useEmail = !useEmail);
//                                 },
//                               ),
//                               SizedBox(height: media.height * 0.03),
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     CustomPageRoute(page: const Signup()),
//                                   );
//                                 },
//                                 child: RichText(
//                                   textAlign: TextAlign.center,
//                                   text: TextSpan(
//                                     text: "Don't have an account? ",
//                                     style: TextStyle(
//                                       color: ElementColors.fontColor2,
//                                       fontSize: constraints.maxWidth * 0.035 > 16
//                                           ? 16
//                                           : constraints.maxWidth * 0.035,
//                                     ),
//                                     children: [
//                                       TextSpan(
//                                         text: "Sign Up",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: ElementColors.fontColor2,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

