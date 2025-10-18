import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/hamburger.dart';
import 'package:elingkod/common_widget/search_bar.dart';
import 'package:elingkod/pages/barangay_clearance.dart';
import 'package:elingkod/pages/barangay_id.dart';
import 'package:elingkod/pages/business_clearance.dart';
import 'package:elingkod/pages/confirmation.dart';
import 'package:elingkod/pages/profile.dart';
import 'package:elingkod/pages/request_status.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final bool showConfirmation; 
  const Home({super.key, this.showConfirmation = false});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Initialize the TextEditingController
  final TextEditingController _searchController = TextEditingController();

  // List of available services
  final List<Map<String, dynamic>> _services = [
    {"label": "Barangay Clearance", "page": const BarangayClearance()},
    {"label": "Barangay ID", "page": const BarangayID()},
    {"label": "Business Clearance", "page": const BusinessClearance()},
    {"label": "Submitted Requests", "page": const RequestStatusPage()},
  ];

  @override
  void initState() {
    super.initState();

    // Trigger confirmation dialog after Home loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showConfirmation) {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const ConfirmationDialog(),
          transitionBuilder: (_, anim, __, child) {
            return Transform.scale(
              scale: Curves.easeOutBack.transform(anim.value),
              child: Opacity(
                opacity: anim.value,
                child: child,
              ),
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Responsive helpers
    double responsiveFont(double base) => base * (screenWidth / 390);
    double responsiveHeight(double base) => base * (screenHeight / 844);

    return Scaffold(
      backgroundColor: ElementColors.fontColor2,
      appBar: AppBar(
        backgroundColor: ElementColors.primary,
        iconTheme: IconThemeData(color: ElementColors.fontColor2),
        elevation: 0,
      ),
      drawer: const Hamburger(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Use your reusable search bar
              CustomSearchBar<Map<String, dynamic>>(
                items: _services,
                itemLabel: (item) => item["label"],
                itemBuilder: (context, item) => ListTile(
                  title: Text(item["label"]),
                ),
                onItemTap: (item) {
                  Navigator.pushReplacement(
                    context,
                    CustomPageRoute(page: item["page"]),
                  );
                },
                hintText: "Can't find what you're looking for?",
              ),

              SizedBox(height: responsiveHeight(20)),

              // Show logo + buttons only if not searching
              if (_searchController.text.isEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      height: responsiveHeight(50),
                    ),
                    SizedBox(width: responsiveHeight(8)),
                    Text(
                      "Select a Service",
                      style: TextStyle(
                        color: ElementColors.secondary,
                        fontSize: responsiveFont(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsiveHeight(20)),

                // Service Buttons
                ..._services.map((service) {
                  return _buildServiceButton(
                    context,
                    label: service["label"],
                    color: _getServiceColor(service["label"]),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        CustomPageRoute(page: service["page"]),
                      );
                    },
                    fontSize: responsiveFont(18),
                    height: responsiveHeight(120),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          color: ElementColors.primary,
          padding: EdgeInsets.symmetric(vertical: responsiveHeight(20)),
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.fromHeight(responsiveHeight(40)),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              Navigator.push(
                context,
                CustomPageRoute(page: const Profile()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: Colors.white, size: responsiveFont(22)),
                SizedBox(width: responsiveHeight(6)),
                Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsiveFont(18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable service button
  Widget _buildServiceButton(
      BuildContext context, {
        required String label,
        required Color color,
        Color? textColor,  
        Color? borderColor,
        required double fontSize,
        required double height,
        required VoidCallback onTap,
      }) {

    final effectiveTextColor = textColor ?? (label == "Submitted Requests" ? Colors.black : Colors.white);
    final effectiveBorderColor = borderColor ?? (label == "Submitted Requests" ? Colors.black : Colors.transparent);

    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: effectiveTextColor,
          minimumSize: Size.fromHeight(height * 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: effectiveBorderColor, width: 1),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: effectiveTextColor
            ),
        ),
      ),
    );
  }

  // Helper to set button colors by service name
  Color _getServiceColor(String label) {
    switch (label) {
      case "Barangay Clearance":
        return ElementColors.tertiary;
      case "Barangay ID":
        return ElementColors.secondary;
      case "Business Clearance":
        return ElementColors.primary;
      case "Submitted Requests":
        return Colors.white;
      default:
        return ElementColors.primary;
    }
  }
}
