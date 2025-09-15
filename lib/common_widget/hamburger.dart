import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/registration.dart';
// import 'package:elingkod/pages/profile.dart';      
// import 'package:elingkod/pages/request_status.dart';
// import 'package:elingkod/pages/barangay_clearance.dart';
// import 'package:elingkod/pages/business_clearance.dart';
// import 'package:elingkod/pages/barangay_id.dart';

class Hamburger extends StatelessWidget {
  const Hamburger({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ElementColors.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: ElementColors.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  "Hi, [Name] !",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Home
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text("Home", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const Home()),
              );
            },
          ),

          // Profile
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text("Profile", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const Home()), // replace with Profile()
              );
            },
          ),

          // Request Status
          ListTile(
            leading: const Icon(Icons.assignment, color: Colors.white),
            title: const Text("Request Status", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const Home()), // replace with RequestStatus()
              );
            },
          ),

          // Barangay Clearance
          ListTile(
            leading: const Icon(Icons.article, color: Colors.white),
            title: const Text("Barangay Clearance", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const Home()), // replace with BarangayClearance()
              );
            },
          ),

          // Business Clearance
          ListTile(
            leading: const Icon(Icons.folder, color: Colors.white),
            title: const Text("Business Clearance", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const Home()), // replace with BusinessClearance()
              );
            },
          ),

          // Barangay ID
          ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.white),
            title: const Text("Barangay ID", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                CustomPageRoute(page: const Home()), // replace with BarangayID()
              );
            },
          ),

          const Divider(color: Colors.white70),

         // Log Out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text("Log Out", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context); // close the drawer first
              Navigator.pushAndRemoveUntil(
                context,
                CustomPageRoute(page: const Registration()),
                (route) => false, // clears navigation stack
              );
            },
          ),

        ],
      ),
    );
  }
}
