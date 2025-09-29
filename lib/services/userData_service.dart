import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

// Defines the data structure for the user's profile for type safety.
// This should match the columns in your 'user_details' Supabase table.
class UserDetails {
  final String? user_id;
  final String? email;
  final String? lastName;
  final String? firstName;
  final String? middleName;
  final String? gender;
  final String? birthDate;
  final String? birthPlace;
  final String? citizenship;
  final String? houseNum;
  final String? street;
  final String? city;
  final String? province;
  final String? zipCode;
  final String? contactNumber;
  final String? civilStatus;
  final String? voterStatus;
  final bool? isSenior;
  final String? seniorCardImageURL;
  final bool? isPwd;
  final String? pwdIDNum;
  final String? frontPWDImageURL;
  final String? backPWDImageURL;

  UserDetails({
    this.user_id,
    this.email,
    this.lastName,
    this.firstName,
    this.middleName,
    this.gender,
    this.birthDate,
    this.birthPlace,
    this.citizenship,
    this.houseNum,
    this.street,
    this.city,
    this.province,
    this.zipCode,
    this.contactNumber,
    this.civilStatus,
    this.voterStatus,
    this.isSenior,
    this.seniorCardImageURL,
    this.isPwd,
    this.pwdIDNum,
    this.frontPWDImageURL,
    this.backPWDImageURL,
  });

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      user_id: map['user_id'] as String?,
      email: map['email'] as String?,
      lastName: map['lastName'] as String?,
      firstName: map['firstName'] as String?,
      middleName: map['middleName'] as String?,
      gender: map['gender'] as String?,
      birthDate: map['birthDate'] as String?,
      birthPlace: map['birthPlace'] as String?,
      citizenship: map['citizenship'] as String?,
      houseNum: map['houseNum'] as String?,
      street: map['street'] as String?,
      city: map['city'] as String?,
      province: map['province'] as String?,
      zipCode: map['zipCode'] as String?,
      contactNumber: map['contactNumber'] as String?,
      civilStatus: map['civilStatus'] as String?,
      voterStatus: map['voterStatus'] as String?,
      isSenior: map['isPwd'] as bool?,
      seniorCardImageURL: map['seniorCardImageURL'] as String?,
      isPwd: map['isPwd'] as bool?,
      pwdIDNum: map['pwdIDNum'] as String?,
      frontPWDImageURL: map['frontPWDImageURL'] as String?,
      backPWDImageURL: map['backPWDImageURL'] as String?,
    );
  }

  // new edited values
  UserDetails copyWith({
    String? user_id,
    String? email,
    String? lastName,
    String? firstName,
    String? middleName,
    String? gender,
    String? birthDate,
    String? birthPlace,
    String? citizenship,
    String? houseNum,
    String? street,
    String? city,
    String? province,
    String? zipCode,
    String? contactNumber,
    String? civilStatus,
    String? voterStatus,
    bool? isSenior,
    String? seniorCardImageURL,
    bool? isPwd,
    String? pwdIDNum,
    String? frontPWDImageURL,
    String? backPWDImageURL,
  }) 
  
  {
    return UserDetails(
      user_id: user_id ?? this.user_id,
      email: email ?? this.email,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      citizenship: citizenship ?? this.citizenship,
      houseNum: houseNum ?? this.houseNum,
      street: street ?? this.street,
      city: city ?? this.city,
      province: province ?? this.province,
      zipCode: zipCode ?? this.zipCode,
      contactNumber: contactNumber ?? this.contactNumber,
      civilStatus: civilStatus ?? this.civilStatus,
      voterStatus: voterStatus ?? this.voterStatus,
      isSenior: isSenior ?? this.isSenior,
      seniorCardImageURL: seniorCardImageURL ?? this.seniorCardImageURL,
      isPwd: isPwd ?? this.isPwd,
      pwdIDNum: pwdIDNum ?? this.pwdIDNum,
      frontPWDImageURL: frontPWDImageURL ?? this.frontPWDImageURL,
      backPWDImageURL: backPWDImageURL ?? this.backPWDImageURL,
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
    required String? seniorYesOrNo,
    required File? seniorCardImage,
    required String? pwdYesOrNo,
    required String? idNum,
    required File? frontPWDImage,
    required File? backPWDImage,
  }) async {
    final User? user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated.');
    }

    String? seniorCardImageUrl;
    String? frontPWDImageUrl;
    String? backPWDImageUrl;
    final bool isPwd = pwdYesOrNo == 'Yes';
    final bool isSenior = seniorYesOrNo == 'Yes';

    if (isSenior) {
      if (seniorCardImage != null) {
        seniorCardImageUrl = await _uploadFile(seniorCardImage, 'front_id');
        if (seniorCardImageUrl == null) {
          throw Exception("Failed to upload senior citizen card image.");
        }
      } else {
        throw Exception("Senior Citizen Card images are required but missing.");
      }
    }

    if (isPwd) {
      if (frontPWDImage != null && backPWDImage != null) {
        frontPWDImageUrl = await _uploadFile(frontPWDImage, 'front_id');
        backPWDImageUrl = await _uploadFile(backPWDImage, 'back_id');
        if (frontPWDImageUrl == null || backPWDImageUrl == null) {
          throw Exception("Failed to upload one or both PWD ID images.");
        }
      } else {
        throw Exception("PWD ID images are required but missing.");
      }
    }

    // CONSTRUCT FINAL DATA PAYLOAD with CORRECT keys matching the database
    final Map<String, dynamic> finalProfileData = {
      'user_id': user.id,
      'email': initialProfileData['email'],
      'lastName': initialProfileData['lastName'],
      'firstName': initialProfileData['firstName'],
      'middleName': initialProfileData['middleName'],
      'gender': initialProfileData['gender'],
      'birthDate': initialProfileData['birthDate'],
      'birthPlace': initialProfileData['birthPlace'],
      'citizenship': initialProfileData['citizenship'],
      'houseNum': initialProfileData['houseNum'],
      'street': initialProfileData['street'],
      'city': initialProfileData['city'],
      'province': initialProfileData['province'],
      'zipCode': initialProfileData['zipCode'],
      'contactNumber': initialProfileData['contactNumber'],
      'civilStatus': initialProfileData['civilStatus'],
      'voterStatus': initialProfileData['voterStatus'],
      'isSenior': isSenior,
      'seniorCardImageURL': isSenior ? seniorCardImageUrl : null,
      'isPwd': isPwd,
      'pwdIDNum': isPwd ? idNum : null,
      'frontPWDImageURL': isPwd ? frontPWDImageUrl : null,
      'backPWDImageURL': isPwd ? backPWDImageUrl : null,
    };
    
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