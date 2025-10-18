import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUploadService {
  static final _supabase = Supabase.instance.client;

  static Future<String?> uploadImage({
    required File imageFile,
    required String folderName,
    required String userId,
  }) async {
    final bucketName = (folderName == 'validIdImage' || folderName == 'residencyImage' || folderName == 'signatureImage')
        ? 'barangay-id-images' // bucket for general/barangay IDs
        : 'senior-pwd-images';  // bucket for PWD and Senior IDs

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$folderName/$userId-$fileName';

      // uploads to buckets
      final storageResponse = await _supabase.storage
          .from(bucketName)
          .upload(filePath, imageFile);

      if (storageResponse.isEmpty) {
        throw Exception('Failed to upload image to $bucketName');
      }

      // public url
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      return null;
    }
  }
}