import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

// Defines the data structure for the user's profile for type safety.
// This should match the columns in your 'user_details' Supabase table.
class UserDetails {
  final String? user_id;
  final String? lastName;
  final String? firstName;
  final String? middleName;
  final String? gender;
  final String? birthDate;
  final String? birthPlace;
  final String? houseNum;
  final String? street;
  final String? city;
  final String? province;
  final String? zipCode;
  final String? contactNumber;
  final String? civilStatus;
  final String? voterStatus;
  final bool? isPwd;
  final String? pwdIDNum;
  final String? frontImageURL;
  final String? backImageURL;

  UserDetails({
    this.user_id,
    this.lastName,
    this.firstName,
    this.middleName,
    this.gender,
    this.birthDate,
    this.birthPlace,
    this.houseNum,
    this.street,
    this.city,
    this.province,
    this.zipCode,
    this.contactNumber,
    this.civilStatus,
    this.voterStatus,
    this.isPwd,
    this.pwdIDNum,
    this.frontImageURL,
    this.backImageURL,
  });

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      user_id: map['user_id'] as String?,
      lastName: map['lastName'] as String?,
      firstName: map['firstName'] as String?,
      middleName: map['middleName'] as String?,
      gender: map['gender'] as String?,
      birthDate: map['birthDate'] as String?,
      birthPlace: map['birthPlace'] as String?,
      houseNum: map['houseNum'] as String?,
      street: map['street'] as String?,
      city: map['city'] as String?,
      province: map['province'] as String?,
      zipCode: map['zipCode'] as String?,
      contactNumber: map['contactNumber'] as String?,
      civilStatus: map['civilStatus'] as String?,
      voterStatus: map['voterStatus'] as String?,
      isPwd: map['isPwd'] as bool?,
      pwdIDNum: map['pwdIDNum'] as String?,
      frontImageURL: map['frontImageURL'] as String?,
      backImageURL: map['backImageURL'] as String?,
    );
  }
}

class UserDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Utility function to upload file to Supabase Storage
  Future<String?> _uploadFile(File file, String folderName) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final fileExtension = file.path.split('.').last;
      final fileName = '${folderName}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storagePath = '${user.id}/$fileName';

      await _supabase.storage.from('id_images').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final fileUrl = _supabase.storage.from('id_images').getPublicUrl(storagePath);
      return fileUrl;

    } on StorageException catch (e) {
      throw Exception('Storage Upload Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Saves the final profile data (including PWD info) and marks onboarding as complete.
  Future<void> saveCompleteOnboardingProfile({
    required Map<String, dynamic> initialProfileData,
    required String? yesOrNo,
    required String? idNum,
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

    // CONSTRUCT FINAL DATA PAYLOAD with CORRECT keys matching the database
    final Map<String, dynamic> finalProfileData = {
      'user_id': user.id,
      'lastName': initialProfileData['lastName'],
      'firstName': initialProfileData['firstName'],
      'middleName': initialProfileData['middleName'],
      'gender': initialProfileData['gender'],
      'birthDate': initialProfileData['birthDate'],
      'birthPlace': initialProfileData['birthPlace'],
      'houseNum': initialProfileData['houseNum'],
      'street': initialProfileData['street'],
      'city': initialProfileData['city'],
      'province': initialProfileData['province'],
      'zipCode': initialProfileData['zipCode'],
      'contactNumber': initialProfileData['contactNumber'],
      'civilStatus': initialProfileData['civilStatus'],
      'voterStatus': initialProfileData['voterStatus'],
      'isPwd': isPwd,
      'pwdIDNum': isPwd ? idNum : null,
      'frontImageURL': isPwd ? frontImageUrl : null,
      'backImageURL': isPwd ? backImageUrl : null,
    };

    // REMOVE THIS AFTER
    print('Final Data Payload: $finalProfileData');
    
    // // UPDATE/INSERT DATA into the user_details table
    // await _supabase.from('user_details').upsert(finalProfileData);
    // UPDATE/INSERT DATA into the user_details table
    final response = await _supabase
        .from('user_details')
        .upsert(finalProfileData)
        .select();

      print('Upsert response: $response');

        
    // UPDATE USER METADATA (marks onboarding as complete)
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
          .eq('user_id', user.id) // Corrected to use 'user_id'
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