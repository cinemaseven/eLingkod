import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/hamburger.dart';

class RequestStatusPage extends StatelessWidget {
  const RequestStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double responsiveFont(double base) => base * (size.width / 390);
    double responsiveHeight(double base) => base * (size.height / 844);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: ElementColors.fontColor2),
      ),
      drawer: const Hamburger(),
      body: Column(
        children: [
          // 🔹 Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Can't find what you're looking for?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
