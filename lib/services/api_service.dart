import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.173:8000/"; // Android emulator
  // If physical device, use your computer’s LAN IP

  static Future<bool> checkIdQuality(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/check_id_quality'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return body.contains('"good":true');
    }
    return false;
  }
}