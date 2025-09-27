import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

// Defines the data structure for the user's profile for type safety.
// This should match the columns in your 'user_details' Supabase table.
class UserDetails {
  final String id;
  final String fullName;
  final String emailOrContact;
  final bool isPwd;
  final String? pwdIdNumber;
  final String? pwdIdFrontUrl;
  final String? pwdIdBackUrl;
  
  // Add other profile fields here (e.g., address, birthdate, etc.)

  UserDetails({
    required this.id,
    required this.fullName,
    required this.emailOrContact,
    required this.isPwd,
    this.pwdIdNumber,
    this.pwdIdFrontUrl,
    this.pwdIdBackUrl,
  });

  // Factory method to convert a Supabase map (row) into a UserDetails object
  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      emailOrContact: map['email_or_contact'] as String, // Assuming you store this
      isPwd: map['is_pwd'] as bool,
      pwdIdNumber: map['pwd_id_number'] as String?,
      pwdIdFrontUrl: map['pwd_id_front_url'] as String?,
      pwdIdBackUrl: map['pwd_id_back_url'] as String?,
      // Map other fields here
    );
  }
}

class UserDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Utility function to upload file to Supabase Storage
  /// The 'path' argument is used as a sub-folder/identifier (e.g., 'front_id', 'back_id').
  Future<String?> _uploadFile(File file, String folderName) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      // Create a unique file path: id_images/{user_id}/{folderName}_{timestamp}.ext
      final fileExtension = file.path.split('.').last;
      final fileName = '${folderName}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storagePath = '${user.id}/$fileName';

      // NOTE: This uses the bucket 'id_images' as defined in your code block.
      await _supabase.storage.from('id_images').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      
      // Get the public URL for the file
      final fileUrl = _supabase.storage.from('id_images').getPublicUrl(storagePath);
      return fileUrl;

    } on StorageException catch (e) {
      // Re-throw as a generic exception to be handled by the caller
      throw Exception('Storage Upload Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Saves the final profile data (including PWD info) and marks onboarding as complete.
  /// Throws exceptions on failure (database or storage error).
  Future<void> saveCompleteOnboardingProfile({
    required Map<String, dynamic> initialProfileData,
    required String? yesOrNo,
    required String idNum,
    required File? frontImage,
    required File? backImage,
  }) async {
    final User? user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated.');
    }

    String? frontImageUrl;
    String? backImageUrl;
    final bool isPwd = yesOrNo == 'Yes';

    if (isPwd) {
      // 1. UPLOAD IMAGES
      if (frontImage != null && backImage != null) {
        frontImageUrl = await _uploadFile(frontImage, 'front_id');
        backImageUrl = await _uploadFile(backImage, 'back_id');

        if (frontImageUrl == null || backImageUrl == null) {
          throw Exception("Failed to upload one or both PWD ID images.");
        }
      } else {
        throw Exception("PWD ID images are required but missing.");
      }
    }

    // 2. CONSTRUCT FINAL DATA PAYLOAD
    final Map<String, dynamic> finalProfileData = {
      'id': user.id, // Supabase user ID is the primary key for the 'user_details' table
      'is_pwd': isPwd,
      'pwd_id_number': isPwd ? idNum : null,
      'pwd_id_front_url': isPwd ? frontImageUrl : null,
      'pwd_id_back_url': isPwd ? backImageUrl : null,
      // Ensure all previous profile data is merged
      ...initialProfileData, 
    };
    
    // 3. INSERT/UPDATE DATA INTO user_details TABLE
    await _supabase.from('user_details').upsert(finalProfileData);
    
    // 4. UPDATE USER METADATA (marks onboarding as complete)
    await _supabase.auth.updateUser(
      UserAttributes(
        data: {'onboarding_complete': true},
      ),
    );
  }

  /// Fetches the current user's complete profile data from the 'user_details' table.
  Future<UserDetails> fetchUserDetails() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user session found.');
    }

    try {
      final response = await _supabase
          .from('user_details')
          .select()
          .eq('id', user.id)
          .single();

      return UserDetails.fromMap(response);

    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch user profile: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Handles user sign-out and clears the session.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Sign-out failed: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
