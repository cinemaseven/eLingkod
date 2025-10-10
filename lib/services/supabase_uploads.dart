import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUploadService {
  static final _supabase = Supabase.instance.client;

  /// Uploads an image file to Supabase Storage and returns the public URL.
  ///
  /// [imageFile] - The image file to upload.
  /// [folderName] - The folder inside the `senior-pwd-images` bucket
  /// (e.g., 'seniorCardImage', 'frontPWDImage', or 'backPWDImage').
  /// [userId] - The UUID of the user, used to create a unique file name.
  static Future<String?> uploadImage({
    required File imageFile,
    required String folderName,
    required String userId,
  }) async {
    try {
      // Generate unique file path
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$folderName/$userId-$fileName';

      // Upload to Supabase bucket
      final storageResponse = await _supabase.storage
          .from('senior-pwd-images')
          .upload(filePath, imageFile);

      // If upload failed
      if (storageResponse.isEmpty) {
        throw Exception('Failed to upload image');
      }

      // Get the public URL
      final publicUrl = _supabase.storage
          .from('senior-pwd-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('❌ Upload failed: $e');
      return null;
    }
  }
}
