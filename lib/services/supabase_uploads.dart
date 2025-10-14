import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUploadService {
  static final _supabase = Supabase.instance.client;

  static Future<String?> uploadImage({
    required File imageFile,
    required String folderName,
    required String userId,
  }) async {
    // 1. Determine the bucket based on the folder name
    // If the folder is one of the designated ID folders, use 'barangay-id-images' or 'senior-pwd-images'.
    final bucketName = (folderName == 'validIdImage' || folderName == 'residencyImage' || folderName == 'signatureImage')
        ? 'barangay-id-images' // Bucket for general/barangay IDs
        : 'senior-pwd-images';  // Bucket for PWD and Senior IDs

    try {
      // 2. Generate unique file path, which includes the specified folderName
      // The format will be: <folderName>/<userId>-<timestamp>.jpg
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$folderName/$userId-$fileName';

      // 3. Upload to Supabase bucket
      final storageResponse = await _supabase.storage
          .from(bucketName)
          .upload(filePath, imageFile);

      // If upload failed
      if (storageResponse.isEmpty) {
        throw Exception('Failed to upload image to $bucketName');
      }

      // 4. Get the public URL
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('❌ Upload failed for $folderName in $bucketName: $e');
      return null;
    }
  }
}