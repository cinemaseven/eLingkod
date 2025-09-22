import 'package:flutter/material.dart';
import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/hamburger.dart';
import 'package:elingkod/pages/barangay_clearance.dart';
import 'package:elingkod/pages/barangay_id.dart';
import 'package:elingkod/pages/business_clearance.dart';
import 'package:elingkod/pages/request_status.dart';
import 'package:elingkod/pages/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();

  // List of available services
  final List<Map<String, dynamic>> _services = [
    {"label": "Barangay Clearance", "page": const BarangayClearance()},
    {"label": "Barangay ID", "page": const BarangayID()},
    {"label": "Business Clearance", "page": const BusinessClearance()},
    {"label": "Submitted Requests", "page": const RequestStatusPage()},
  ];

  List<Map<String, dynamic>> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _filteredServices = _services; // show all by default
  }

  void _search(String query) {
    final results = _services.where((service) {
      return service["label"]
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredServices = results;
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
              // ✅ Search box
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _search,
                        decoration: const InputDecoration(
                          hintText: "Can't find what you're looking for?",
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                        ),
                        maxLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsiveHeight(20)),

              // 🔎 Search results
              if (_searchController.text.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = _filteredServices[index];
                    return ListTile(
                      title: Text(service["label"]),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          CustomPageRoute(page: service["page"]),
                        );
                      },
                    );
                  },
                ),

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

      // ✅ Bottom Navigation
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
                CustomPageRoute(page: const ProfilePage()),
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

  // 🔹 Reusable service button
  Widget _buildServiceButton(
      BuildContext context, {
        required String label,
        required Color color,
        Color? textColor,  
        Color? borderColor,
        // Color borderColor = Colors.transparent,
        required double fontSize,
        required double height,
        required VoidCallback onTap,
      }) {

    // make text and border for submitted requests black 
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

  // 🎨 Helper to set button colors by service name
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



// import 'package:flutter/material.dart';
// import 'package:elingkod/common_style/colors_extension.dart';
// import 'package:elingkod/common_widget/custom_pageRoute.dart';
// import 'package:elingkod/common_widget/hamburger.dart';

// import 'package:elingkod/pages/barangay_clearance.dart';
// import 'package:elingkod/pages/barangay_id.dart';
// import 'package:elingkod/pages/business_clearance.dart';
// import 'package:elingkod/pages/request_status.dart';
// import 'package:elingkod/pages/profile.dart';

// class Home extends StatelessWidget {
//   const Home({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final screenWidth = size.width;
//     final screenHeight = size.height;

//     // Responsive helpers
//     double responsiveFont(double base) => base * (screenWidth / 390);
//     double responsiveHeight(double base) => base * (screenHeight / 844);

//     return Scaffold(
//       backgroundColor: ElementColors.fontColor2,
//       appBar: AppBar(
//         backgroundColor: ElementColors.primary,
//         iconTheme: IconThemeData(color: ElementColors.fontColor2),
//         elevation: 0,
//       ),
//       drawer: const Hamburger(),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // ✅ Search box
//               Container(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF1F1F1),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.search),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         decoration: const InputDecoration(
//                           hintText: "Can't find what you're looking for?",
//                           hintStyle: TextStyle(
//                             overflow: TextOverflow.visible,
//                           ),
//                           isDense: true,
//                           contentPadding: EdgeInsets.symmetric(vertical: 12),
//                           border: InputBorder.none,
//                         ),
//                         style: const TextStyle(
//                           overflow: TextOverflow.visible,
//                         ),
//                         maxLines: 1,
//                         textAlignVertical: TextAlignVertical.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: responsiveHeight(20)),

//               // Logo + Title
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     "assets/images/logo.png",
//                     height: responsiveHeight(50),
//                   ),
//                   SizedBox(width: responsiveHeight(8)),
//                   Text(
//                     "Select a Service",
//                     style: TextStyle(
//                       color: ElementColors.secondary,
//                       fontSize: responsiveFont(18),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: responsiveHeight(20)),

//               // Service Buttons
//               _buildServiceButton(
//                 context,
//                 label: "Barangay Clearance",
//                 color: ElementColors.tertiary,
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     CustomPageRoute(page: const BarangayClearance()),
//                   );
//                 },
//                 fontSize: responsiveFont(18),
//                 height: responsiveHeight(120),
//               ),
//               _buildServiceButton(
//                 context,
//                 label: "Barangay ID",
//                 color: ElementColors.secondary,
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     CustomPageRoute(page: const BarangayID()),
//                   );
//                 },
//                 fontSize: responsiveFont(18),
//                 height: responsiveHeight(120),
//               ),
//               _buildServiceButton(
//                 context,
//                 label: "Business Clearance",
//                 color: ElementColors.primary,
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     CustomPageRoute(page: const BusinessClearance()),
//                   );
//                 },
//                 fontSize: responsiveFont(18),
//                 height: responsiveHeight(120),
//               ),
//               _buildServiceButton(
//                 context,
//                 label: "Submitted Requests",
//                 color: Colors.white,
//                 textColor: Colors.black,
//                 borderColor: Colors.black,
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     CustomPageRoute(page: const RequestStatusPage()),
//                   );
//                 },
//                 fontSize: responsiveFont(18),
//                 height: responsiveHeight(120),
//               ),
//             ],
//           ),
//         ),
//       ),

//       // ✅ Bottom Navigation (smaller height)
//       bottomNavigationBar: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//         child: Container(
//           width: double.infinity,
//           color: ElementColors.primary,
//           padding: EdgeInsets.symmetric(vertical: responsiveHeight(20)),
//           child: TextButton(
//             style: TextButton.styleFrom(
//               minimumSize: Size.fromHeight(responsiveHeight(40)),
//               padding: EdgeInsets.zero,
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 CustomPageRoute(page: const ProfilePage()),
//               );
//             },
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.person, color: Colors.white, size: responsiveFont(22)),
//                 SizedBox(width: responsiveHeight(6)),
//                 Text(
//                   "Profile",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: responsiveFont(18),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // 🔹 Reusable service button
//   Widget _buildServiceButton(
//       BuildContext context, {
//         required String label,
//         required Color color,
//         Color textColor = Colors.white,
//         Color borderColor = Colors.transparent,
//         required double fontSize,
//         required double height,
//         required VoidCallback onTap, // Added onTap parameter
//       }) {
//     return Container(
//       height: height,
//       margin: const EdgeInsets.only(bottom: 16),
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: textColor,
//           minimumSize: Size.fromHeight(height * 0.7),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: BorderSide(color: borderColor, width: 1),
//           ),
//         ),
//         onPressed: onTap, // Used the new onTap parameter
//         child: Text(
//           label,
//           style: TextStyle(fontSize: fontSize),
//         ),
//       ),
//     );
//   }
// }