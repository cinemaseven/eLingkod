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
  //final String? email; //sicne wlang email na table sa db
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
    //this.email,
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
      //email: map['email'] as String?,
      civilStatus: map['civilStatus'] as String?,
      voterStatus: map['voterStatus'] as String?,
      isPwd: map['isPwd'] as bool?,
      pwdIDNum: map['pwdIDNum'] as String?,
      frontImageURL: map['frontImageURL'] as String?,
      backImageURL: map['backImageURL'] as String?,
    );
  }

  // new edited values
  UserDetails copyWith({
    String? user_id,
    String? lastName,
    String? firstName,
    String? middleName,
    String? gender,
    String? birthDate,
    String? birthPlace,
    String? houseNum,
    String? street,
    String? city,
    String? province,
    String? zipCode,
    String? contactNumber,
    String? civilStatus,
    String? voterStatus,
    bool? isPwd,
    String? pwdIDNum,
    String? frontImageURL,
    String? backImageURL,
  }) 
  
  {
    return UserDetails(
      user_id: user_id ?? this.user_id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      houseNum: houseNum ?? this.houseNum,
      street: street ?? this.street,
      city: city ?? this.city,
      province: province ?? this.province,
      zipCode: zipCode ?? this.zipCode,
      contactNumber: contactNumber ?? this.contactNumber,
      civilStatus: civilStatus ?? this.civilStatus,
      voterStatus: voterStatus ?? this.voterStatus,
      isPwd: isPwd ?? this.isPwd,
      pwdIDNum: pwdIDNum ?? this.pwdIDNum,
      frontImageURL: frontImageURL ?? this.frontImageURL,
      backImageURL: backImageURL ?? this.backImageURL,
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
      'email': initialProfileData['email'],
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

    /// Updates basic profile fields in user_details
  Future<void> updateUserDetails(Map<String, dynamic> updatedData) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException("User not authenticated");

    // pag-iuupdate ung info
    final dataToUpdate = {
      'user_id': user.id, // needed for upsert
      //'gender': updatedData['gender'],
      //'birthDate': updatedData['dob'],
      //'birthPlace': updatedData['pob'],
      //'contactNumber': updatedData['contact'],
      'civilStatus': updatedData['civil'],
      'voterStatus': updatedData['voter'],
      //'province': updatedData['citizenship'], // depends how you want to map
      // 'address': updatedData['address'], // optional if your schema splits this
      //'email': updatedData['email'],     // only if you keep email here
    };

    final response = await _supabase
        .from('user_details')
        .upsert(dataToUpdate)
        .select();

    print("Update response: $response");
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