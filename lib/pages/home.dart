import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/hamburger.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElementColors.fontColor2, // body background

      appBar: AppBar(
        backgroundColor: ElementColors.primary, // top blue bar
        iconTheme: IconThemeData(color: ElementColors.fontColor2),
        elevation: 0,
      ),

      // 👇 attach your Hamburger widget here
      drawer: const Hamburger(),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search box
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1), // search box color
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Can't find what you're looking for?",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Logo + "Select a Service"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 50,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Select a Service",
                    style: TextStyle(
                      color: ElementColors.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Barangay Clearance
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElementColors.tertiary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: ElementColors.tertiary, width: 1),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(page: const Home()), // example nav
                    );
                  },
                  child: const Text(
                    "Barangay Clearance",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              // Barangay ID
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElementColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: ElementColors.secondary, width: 1),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(page: const Home()), // change to BarangayID()
                    );
                  },
                  child: const Text(
                    "Barangay ID",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              // Business Clearance
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElementColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: ElementColors.primary, width: 1),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(page: const Home()), // change to BusinessClearance()
                    );
                  },
                  child: const Text(
                    "Business Clearance",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              // Submitted Requests
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(page: const Home()), // change to SubmittedRequests()
                    );
                  },
                  child: const Text(
                    "Submitted Requests",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Profile Button
      bottomNavigationBar: Container(
        color: ElementColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              CustomPageRoute(page: const Home()), // change to Profile()
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.person, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Profile",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
