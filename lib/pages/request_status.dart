// import 'package:flutter/material.dart';
// import 'package:elingkod/common_style/colors_extension.dart';
// import 'package:elingkod/common_widget/hamburger.dart';
// import 'package:elingkod/common_widget/search_bar.dart';
// import 'package:elingkod/common_widget/custom_pageRoute.dart';
// import 'package:elingkod/pages/barangay_clearance.dart';
// import 'package:elingkod/pages/barangay_id.dart';
// import 'package:elingkod/pages/business_clearance.dart';

// class RequestStatusPage extends StatefulWidget {
//   const RequestStatusPage({super.key});

//   @override
//   State<RequestStatusPage> createState() => _RequestStatusPageState();
// }

// class _RequestStatusPageState extends State<RequestStatusPage> {
//   final List<Map<String, dynamic>> _requests = [
//     {
//       "icon": Icons.credit_card,
//       "title": "Barangay ID",
//       "status": "In-process",
//       "page": const BarangayID(), // 👈 redirect here
//     },
//     {
//       "icon": Icons.article,
//       "title": "Barangay Clearance",
//       "status": "In-process",
//       "page": const BarangayClearance(),
//     },
//     {
//       "icon": Icons.folder,
//       "title": "Business Clearance",
//       "status": "Ready for Pick-up",
//       "page": const BusinessClearance(),
//     },
//   ];

//   bool _isSearching = false;

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     double responsiveFont(double base) => base * (size.width / 390);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: ElementColors.primary,
//         elevation: 0,
//         iconTheme: IconThemeData(color: ElementColors.fontColor2),
//       ),
//       drawer: const Hamburger(),
//       body: Column(
//         children: [
//           // 🔹 Search bar for requests
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
//             child: CustomSearchBar<Map<String, dynamic>>(
//               items: _requests,
//               itemLabel: (item) => item["title"],
//               itemBuilder: (context, item) => ListTile(
//                 leading: Icon(item["icon"], color: Colors.black87),
//                 title: Text(item["title"]),
//                 subtitle: Text(item["status"],
//                     style: const TextStyle(fontSize: 12, color: Colors.grey)),
//               ),
//               onItemTap: (item) {
//                 Navigator.push(
//                   context,
//                   CustomPageRoute(page: item["page"]),
//                 );
//               },
//               hintText: "Can't find what you're looking for?",
//               onSearchChanged: (isSearching) {
//                 setState(() => _isSearching = isSearching);
//               },
//             ),
//           ),

//           // 🔹 Show table + requests only if NOT searching
//           if (!_isSearching) ...[
//             // Table header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: ElementColors.secondary,
//                 borderRadius: BorderRadius.circular(17),
//                 boxShadow: [
//                   BoxShadow(
//                     color: ElementColors.shadow,
//                     blurRadius: 3,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               margin: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         "Category",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: responsiveFont(14),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         "Status",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: responsiveFont(14),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Full request list
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _requests.length,
//                 itemBuilder: (context, index) {
//                   final request = _requests[index];
//                   return _buildRequestRow(
//                     icon: request["icon"],
//                     title: request["title"],
//                     status: request["status"],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildRequestRow({
//     required IconData icon,
//     required String title,
//     required String status,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//       decoration: const BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.black12),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Category + Icon
//           Expanded(
//             child: Row(
//               children: [
//                 Icon(icon, color: Colors.black87),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Status fixed width
//           Expanded(
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: SizedBox(
//                 width: 120,
//                 child: Container(
//                   alignment: Alignment.center,
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: ElementColors.lightSecondary,
//                   ),
//                   child: Text(
//                     status,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/hamburger.dart';
import 'package:elingkod/common_widget/search_bar.dart';
import 'package:elingkod/pages/barangay_clearance.dart';
import 'package:elingkod/pages/barangay_id.dart';
import 'package:elingkod/pages/business_clearance.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestStatusPage extends StatefulWidget {
  const RequestStatusPage({super.key});

  @override
  State<RequestStatusPage> createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _requests = [];
  bool _isSearching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    List<Map<String, dynamic>> requests = [];

    // 🔹 Barangay ID
    final barangayIdRes = await supabase
        .from('barangay_id_request')
        .select('barangay_id_id, status')
        .eq('user_id', user.id);

    for (final r in barangayIdRes) {
      requests.add({
        "icon": Icons.credit_card,
        "title": "Barangay ID",
        "status": r['status'] ?? 'Unknown',
        "page": const BarangayID(),
      });
    }

    // 🔹 Barangay Clearance
    final clearanceRes = await supabase
        .from('barangay_clearance_request')
        .select('barangay_clearance_, status')
        .eq('user_id', user.id);

    for (final r in clearanceRes) {
      requests.add({
        "icon": Icons.article,
        "title": "Barangay Clearance",
        "status": r['status'] ?? 'Unknown',
        "page": const BarangayClearance(),
      });
    }

    // 🔹 Business Clearance
    final businessRes = await supabase
        .from('business_clearance_request')
        .select('business_clearance_, status')
        .eq('user_id', user.id);

    for (final r in businessRes) {
      requests.add({
        "icon": Icons.folder,
        "title": "Business Clearance",
        "status": r['status'] ?? 'Unknown',
        "page": const BusinessClearance(),
      });
    }

    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double responsiveFont(double base) => base * (size.width / 390);

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
          // 🔹 Search bar for requests
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
            child: CustomSearchBar<Map<String, dynamic>>(
              items: _requests,
              itemLabel: (item) => item["title"],
              itemBuilder: (context, item) => ListTile(
                leading: Icon(item["icon"], color: Colors.black87),
                title: Text(item["title"]),
                subtitle: Text(item["status"],
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              onItemTap: (item) {
                Navigator.push(
                  context,
                  CustomPageRoute(page: item["page"]),
                );
              },
              hintText: "Can't find what you're looking for?",
              onSearchChanged: (isSearching) {
                setState(() => _isSearching = isSearching);
              },
            ),
          ),

          // 🔹 Show table + requests only if NOT searching
          if (!_isSearching) ...[
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ElementColors.secondary,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: ElementColors.shadow,
                    blurRadius: 3,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "Category",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsiveFont(14),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Status",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsiveFont(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Full request list or loading indicator
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return _buildRequestRow(
                          icon: request["icon"],
                          title: request["title"],
                          status: request["status"],
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestRow({
    required IconData icon,
    required String title,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          // Category + Icon
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Colors.black87),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status fixed width
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 120,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: ElementColors.lightSecondary,
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
