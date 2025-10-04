import 'package:elingkod/common_style/colors_extension.dart';
import 'package:elingkod/common_widget/custom_pageRoute.dart';
import 'package:elingkod/common_widget/search_bar.dart';
import 'package:elingkod/pages/barangay_clearance.dart';
import 'package:elingkod/pages/barangay_id.dart';
import 'package:elingkod/pages/business_clearance.dart';
import 'package:elingkod/pages/displayRequest_details.dart';
import 'package:elingkod/pages/home.dart';
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

  // Subscriptions
  RealtimeChannel? _idSub;
  RealtimeChannel? _clearanceSub;
  RealtimeChannel? _businessSub;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _setupRealtime();
  }

  @override
  void dispose() {
    _idSub?.unsubscribe();
    _clearanceSub?.unsubscribe();
    _businessSub?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    List<Map<String, dynamic>> requests = [];

    // 🔹 Barangay ID
    final barangayIdRes = await supabase
        .from('barangay_id_request')
        .select('barangay_id_id, status, created_at')
        .eq('user_id', user.id) as List;
    for (final r in barangayIdRes) {
      requests.add({
        "requestId": r['barangay_id_id'],
        "requestType": "barangay_id_request",
        "icon": Icons.credit_card,
        "title": "Barangay ID",
        "status": r['status'] ?? 'Unknown',
        "date": r['created_at'],
        "page": const BarangayID(),
      });
    }

    // 🔹 Barangay Clearance
    final clearanceRes = await supabase
        .from('barangay_clearance_request')
        .select('barangay_clearance_id, status, created_at')
        .eq('user_id', user.id) as List;
    for (final r in clearanceRes) {
      requests.add({
        "requestId": r['barangay_clearance_id'],
        "requestType": "barangay_clearance_request",
        "icon": Icons.article,
        "title": "Barangay Clearance",
        "status": r['status'] ?? 'Unknown',
        "date": r['created_at'],
        "page": const BarangayClearance(),
      });
    }

    // 🔹 Business Clearance
    final businessRes = await supabase
        .from('business_clearance_request')
        .select('business_clearance_id, status, created_at')
        .eq('user_id', user.id) as List;
    for (final r in businessRes) {
      requests.add({
        "requestId": r['business_clearance_id'],
        "requestType": "business_clearance_request",
        "icon": Icons.folder,
        "title": "Business Clearance",
        "status": r['status'] ?? 'Unknown',
        "date": r['created_at'],
        "page": const BusinessClearance(),
      });
    }

    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  void _setupRealtime() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Barangay ID Realtime
    _idSub = supabase.channel('barangay_id_changes').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'barangay_id_request',
      callback: (payload) {
        final user = supabase.auth.currentUser;
        if (user == null) return;

        // only update if the event is for THIS user
        final newRow = payload.newRecord;
        if (newRow['user_id'] == user.id) {
          _fetchRequests();
        }
      },
    ).subscribe();

    // Barangay Clearance Realtime
    _clearanceSub = supabase.channel('barangay_clearance_changes').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'barangay_clearance_request',
      callback: (payload) {
        final user = supabase.auth.currentUser;
        if (user == null) return;
        if (payload.newRecord['user_id'] == user.id) {
          _fetchRequests();
        }
      },
    ).subscribe();

    // Business Clearance Realtime
    _businessSub = supabase.channel('business_clearance_changes').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'business_clearance_request',
      callback: (payload) {
        final user = supabase.auth.currentUser;
        if (user == null) return;
        if (payload.newRecord['user_id'] == user.id) {
          _fetchRequests();
        }
      },
    ).subscribe();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CustomPageRoute(page: const Home()),
            );
          },
        ),
      ),

      body: Column(
        children: [
          // 🔹 Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
            child: CustomSearchBar<Map<String, dynamic>>(
              items: _requests,
              itemLabel: (item) => item["title"],
              itemBuilder: (context, item) => ListTile(
                title: Text(item["title"]),
              ),
              onItemTap: (item) {
                Navigator.push(
                  context,
                  CustomPageRoute(page: item["page"]),
                );
              },
              hintText: "Can't find what you're looking for?",
            ),
          ),

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

            // 🔹 Requests or loading
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
                          date: request["date"],
                          requestId: request["requestId"],
                          requestType: request["requestType"]
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
  String? date,
  required int requestId,
  required String requestType,
}) {
  String formattedDate = '';
  if (date != null) {
    final dt = DateTime.tryParse(date);
    if (dt != null) {
      formattedDate = "${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}";
    }
  }

  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        CustomPageRoute(page: DisplayrequestDetails(
            requestId: requestId,
            requestType: requestType,
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (formattedDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: ElementColors.placeholder,
                ),
              ),
            ),
          ],
        ),
      ),
  );
  }
}