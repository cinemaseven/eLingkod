import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/registration.dart';
import 'package:flutter/material.dart';
import 'package:elingkod/pages/barangay_clearance.dart';
import 'package:elingkod/pages/barangay_id.dart';
import 'package:elingkod/pages/business_clearance.dart';
import 'package:elingkod/pages/profile.dart';
import 'package:elingkod/pages/request_status.dart';

class Hamburger extends StatelessWidget {
  const Hamburger({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final bool isWideScreen = media.width > 600;

    // Responsive sizes
    final double avatarRadius = isWideScreen
        ? 50.0
        : (media.width * 0.1).clamp(40.0, 50.0);
    final double headerFontSize = isWideScreen ? 20.0 : media.width * 0.045;
    final double menuFontSize = isWideScreen ? 18.0 : media.width * 0.04;
    final double menuIconSize = isWideScreen ? 28.0 : (media.width * 0.06).clamp(24.0, 28.0);

    return Drawer(
      backgroundColor: ElementColors.primary,
      child: SafeArea(
        child: Column(
          children: [
            // Header with X button
            Stack(
              children: [
                // Header container
                Container(
                  height: 220,
                  color: ElementColors.primary,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: avatarRadius * 1.2,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Hi, [Name]!",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: headerFontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Close button
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context), // closes drawer
                  ),
                ),
              ],
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.home,
                    text: "Home",
                    iconSize: menuIconSize,
                    fontSize: menuFontSize,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      CustomPageRoute(page: const Home()),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    text: "Profile",
                    iconSize: menuIconSize,
                    fontSize: menuFontSize,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      CustomPageRoute(page: const ProfilePage()), // Replace with Profile()
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment,
                    text: "Request Status",
                    iconSize: menuIconSize,
                    fontSize: menuFontSize,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      CustomPageRoute(page: const RequestStatusPage()), // Replace with RequestStatus()
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.article,
                    text: "Barangay Clearance",
                    iconSize: menuIconSize,
                    fontSize: menuFontSize,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      CustomPageRoute(page: const BarangayClearance()), // Replace with BarangayClearance()
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.folder,
                    text: "Business Clearance",
                    iconSize: menuIconSize,
                    fontSize: menuFontSize,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      CustomPageRoute(page: const BusinessClearance()), // Replace with BusinessClearance()
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.credit_card,
                    text: "Barangay ID",
                    iconSize: menuIconSize,
                    fontSize: menuFontSize,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      CustomPageRoute(page: const BarangayID()), // Replace with BarangayID()
                    ),
                  ),
                ],
              ),
            ),

            // Logout pinned at bottom
            Padding(
              padding: EdgeInsets.only(bottom: media.height * 0.02),
              child: _buildMenuItem(
                context,
                icon: Icons.logout,
                text: "Log Out",
                iconSize: menuIconSize,
                fontSize: menuFontSize,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    CustomPageRoute(page: const Registration()),
                        (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for menu items with vertical spacing
  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
        required String text,
        required double iconSize,
        required double fontSize,
        required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // spacing between items
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: iconSize),
        title: Text(text,
            style: TextStyle(color: Colors.white, fontSize: fontSize)),
        onTap: onTap,
      ),
    );
  }
}
