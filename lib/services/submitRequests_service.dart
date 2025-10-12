import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

// BARANGAY CLEARANCE
class BarangayClearanceRequest {
  final String? user_id;
  final String? applicationDate;
  final String? residencyType;
  final String? lengthStay;
  final String? clearanceNum;
  final String? fullName;
  final String? gender;
  final String? houseNum;
  final String? street;
  final String? city;
  final String? province;
  final String? zipCode;
  final String? birthDate;
  final String? age;
  final String? contactNumber;
  final String? birthPlace;
  final String? nationality;
  final String? civilStatus;
  final String? email;
  final String? purpose;
  final String? signatureImageURL;
  final String? status;

  BarangayClearanceRequest({
    this.user_id,
    this.applicationDate,
    this.residencyType,
    this.lengthStay,
    this.clearanceNum,
    this.fullName,
    this.gender,
    this.houseNum,
    this.street,
    this.city,
    this.province,
    this.zipCode,
    this.birthDate,
    this.age,
    this.contactNumber,
    this.birthPlace,
    this.nationality,
    this.civilStatus,
    this.email,
    this.purpose,
    this.signatureImageURL,
    this.status = 'Pending', 
  });

  // Method to map data to Supabase column names (restored your original camelCase keys)
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'applicationDate': applicationDate,
      'residencyType': residencyType,
      'lengthStay': lengthStay,
      'clearanceNum': clearanceNum,
      'fullName': fullName,
      'gender': gender,
      'houseNum': houseNum,
      'street': street,
      'city': city,
      'province': province,
      'zipCode': zipCode,
      'birthDate': birthDate,
      'age': age,
      'contactNumber': contactNumber,
      'birthPlace': birthPlace,
      'nationality': nationality,
      'civilStatus': civilStatus,
      'email': email,
      'purpose': purpose,
      'signatureImageURL': signatureImageURL,
      'status': status,
    };
  }
}

// BARANGAY ID
class BarangayIDRequest {
  final String? user_id;
  final String? applicationDate;
  final String? fullName;
  final String? birthDate;
  final String? age;
  final String? contactNumber;
  final String? email;
  final String? gender;
  final String? houseNum;
  final String? street;
  final String? city;
  final String? province;
  final String? zipCode;
  final List<String>? idPurpose;
  final String? validIdImageURL;
  final String? residencyImageURL;
  final String? signatureImageURL;
  final String? status;

  BarangayIDRequest({
    this.user_id,
    this.applicationDate,
    this.fullName,
    this.birthDate,
    this.age,
    this.contactNumber,
    this.email,
    this.gender,
    this.houseNum,
    this.street,
    this.city,
    this.province,
    this.zipCode,
    this.idPurpose,
    this.validIdImageURL,
    this.residencyImageURL,
    this.signatureImageURL,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'applicationDate': applicationDate,
      'fullName': fullName,
      'birthDate': birthDate,
      'age': age,
      'contactNumber': contactNumber,
      'email': email,
      'gender': gender,
      'houseNum': houseNum,
      'street': street,
      'city': city,
      'province': province,
      'zipCode': zipCode,
      'idPurpose': idPurpose,
      'validIdImageURL': validIdImageURL,
      'residencyImageURL': residencyImageURL,
      'signatureImageURL': signatureImageURL,
      'status': status,
    };
  }
}

// BUSINESS CLEARANCE
class BusinessClearanceRequest {
  final String? user_id;
  final String? applicationDate;
  final String? appType;
  final String? businessName;
  final String? houseNum;
  final String? bldgUnit;
  final String? street;
  final String? village;
  final String? natureOfBusiness;
  final String? ownershipType;
  final String? locationStatus;
  final String? totalArea;
  final String? capitalization;
  final String? grossSales;
  final String? ownerName;
  final String? contactNumber;
  final String? email;
  final String? dtiCertFileURL;
  final String? secCertFileURL;
  final String? cdaFileURL;
  final String? barangayClrncImageURL;
  final String? landTitleFileURL;
  final String? contractsFileURL;
  final String? establishmentImageURL;
  final String? ownerImageURL;
  final String? endorsementFileURL;
  final String? signatureImageURL;
  final String? status;

  BusinessClearanceRequest({
    this.user_id,
    this.applicationDate,
    this.appType,
    this.businessName,
    this.houseNum,
    this.bldgUnit,
    this.street,
    this.village,
    this.natureOfBusiness,
    this.ownershipType,
    this.locationStatus,
    this.totalArea,
    this.capitalization,
    this.grossSales,
    this.ownerName,
    this.contactNumber,
    this.email,
    this.dtiCertFileURL,
    this.secCertFileURL,
    this.cdaFileURL,
    this.barangayClrncImageURL,
    this.landTitleFileURL,
    this.contractsFileURL,
    this.establishmentImageURL,
    this.ownerImageURL,
    this.endorsementFileURL,
    this.signatureImageURL,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'applicationDate': applicationDate,
      'appType': appType,
      'businessName': businessName,
      'houseNum': houseNum,
      'bldgUnit': bldgUnit,
      'street': street,
      'village': village,
      'natureOfBusiness': natureOfBusiness,
      'ownershipType': ownershipType,
      'locationStatus': locationStatus,
      'totalArea': totalArea,
      'capitalization': capitalization,
      'grossSales': grossSales,
      'ownerName': ownerName,
      'contactNumber': contactNumber,
      'email': email,
      'dtiCertFileURL': dtiCertFileURL,
      'secCertFileURL': secCertFileURL,
      'cdaFileURL': cdaFileURL,
      'barangayClrncImageURL': barangayClrncImageURL,
      'landTitleFileURL': landTitleFileURL,
      'contractsFileURL': contractsFileURL,
      'establishmentImageURL': establishmentImageURL,
      'ownerImageURL': ownerImageURL,
      'endorsementFileURL': endorsementFileURL,
      'signatureImageURL': signatureImageURL,
      'status': status,
    };
  }
}

// FOR ALL - SUBMIT REQUEST
class SubmitRequestService {
  final supabase = Supabase.instance.client;

   /// Gets the current authenticated user's ID, or throws if none.
  String _getCurrentUserId() {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated. Cannot submit request.');
    }
    return user.id;
  }

  // Uploads files to supabase storage and returns public URL
  Future<String> _uploadFile(File file, String folderName, String bucketName) async {
  final userId = _getCurrentUserId();
  final fileExtension = file.path.split('.').last;
  final fileName = '${folderName}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
  final storagePath = '$folderName/$userId/$fileName';

  try {
    await supabase.storage.from(bucketName).upload(
      storagePath,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    return supabase.storage.from(bucketName).getPublicUrl(storagePath);
  } catch (e) {
    throw Exception('Failed to upload $folderName image: $e');
  }
}

  /// Submits a request to the specified Supabase table.
  Future<void> _submitRequest(String tableName, Map<String, dynamic> requestData) async {
    try {
      await supabase.from(tableName).insert(requestData);
    } on PostgrestException catch (e) {
      print('Postgrest Error submitting request to $tableName: ${e.message}');
      throw Exception('Failed to submit request: ${e.message}');
    } catch (e) {
      print('General Error submitting request to $tableName: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // BARANGAY CLEARANCE SUBMISSION
  // ---------------------------------------------------------------------------

  /// Submits a request for a Barangay Clearance with all form details.
  Future<void> submitBarangayClearance({
    required Map<String, dynamic> formData,
  }) async {
    try {
      final userId = _getCurrentUserId();
      
      // --- 1. UPLOAD SIGNATURE IMAGE ---
      final File? signatureImage = formData['signatureImage'] as File?;
      String? signatureImageUrl;

      if (signatureImage != null) {
        signatureImageUrl = await _uploadFile(signatureImage, 'signatureImage', 'barangay-clearance-images'); 
        if (signatureImageUrl == null) {
          throw Exception("Failed to upload signature image.");
        }
      }
      
      // --- 2. CONSTRUCT AND SUBMIT DATA ---
      final request = BarangayClearanceRequest(
        user_id: userId,
        applicationDate: formData['applicationDate'],
        residencyType: formData['residencyType'],
        lengthStay: formData['lengthStay'],
        clearanceNum: formData['clearanceNum'],
        fullName: formData['fullName'],
        gender: formData['gender'],
        houseNum: formData['houseNum'],
        street: formData['street'],
        city: formData['city'],
        province: formData['province'],
        zipCode: formData['zipCode'],
        birthDate: formData['birthDate'],
        age: formData['age'],
        contactNumber: formData['contactNumber'],
        birthPlace: formData['birthPlace'],
        nationality: formData['nationality'],
        civilStatus: formData['civilStatus'],
        email: formData['email'],
        purpose: formData['purpose'],
        signatureImageURL: signatureImageUrl,
      );
      await _submitRequest('barangay_clearance_request', request.toMap());
    } catch (e) { // <-- CATCH BLOCK
    // Log the error and re-throw, or handle it here if necessary
    print("Error during Barangay Clearance submission: $e");
    rethrow; // Re-throwing ensures the UI layer can catch it and show a SnackBar.
    }
  }
    

  // ---------------------------------------------------------------------------
  // BARANGAY ID SUBMISSION
  // ---------------------------------------------------------------------------

  /// Submits a request for a Barangay ID with all form details and required images.
  Future<void> submitBarangayID({
    required Map<String, dynamic> formData,
  }) async {
    try {
      final userId = _getCurrentUserId();
    
      // --- 1. VALIDATE & UPLOAD FILES ---
      // The previous screen ensures these are not null, but we check and cast here.
      final File? validIdImage = formData['validIdImage'] as File?;
      final File? residencyImage = formData['residencyImage'] as File?;
      final File? signatureImage = formData['signatureImage'] as File?;

      // Upload all files concurrently
      final results = await Future.wait([
        validIdImage != null ? _uploadFile(validIdImage, 'validIdImage', 'barangay-id-images') : Future.value(null),
        residencyImage != null ? _uploadFile(residencyImage, 'residencyImage', 'barangay-id-images') : Future.value(null),
        signatureImage != null ? _uploadFile(signatureImage, 'signatureImage', 'barangay-id-images') : Future.value(null),
      ]);

      final validIdUrl = results[0];
      final residencyUrl = results[1];
      final signatureUrl = results[2];

      // Ensure all uploads succeeded
      if (validIdUrl == null) {
        throw Exception("Failed to upload Valid ID image.");
      }
      if (residencyUrl == null) {
        throw Exception("Failed to upload Proof of Residency image.");
      }
      if (signatureUrl == null) {
        throw Exception("Failed to upload Signature image.");
      }

      // --- 2. CONSTRUCT AND SUBMIT DATA ---
      final request = BarangayIDRequest(
        user_id: userId,
        applicationDate: formData['applicationDate'],
        fullName: formData['fullName'],
        birthDate: formData['birthDate'],
        age: formData['age'],
        contactNumber: formData['contactNumber'],
        email: formData['email'],
        gender: formData['gender'],
        houseNum: formData['houseNum'],
        street: formData['street'],
        city: formData['city'],
        province: formData['province'],
        zipCode: formData['zipCode'],
        idPurpose: formData['idPurpose'] as List<String>?,
        validIdImageURL: validIdUrl,
        residencyImageURL: residencyUrl,
        signatureImageURL: signatureUrl,
      );
      await _submitRequest('barangay_id_request', request.toMap());
    } catch (e) { // <-- CATCH BLOCK
    // Log the error and re-throw, or handle it here if necessary
    print("Error during Barangay ID submission: $e");
    rethrow; // Re-throwing ensures the UI layer can catch it and show a SnackBar.
    }
  }

  // ---------------------------------------------------------------------------
  // BUSINESS CLEARANCE SUBMISSION
  // ---------------------------------------------------------------------------
  Future<void> submitBusinessClearance({
    required Map<String, dynamic> formData,
  }) async {
    try {
      final userId = _getCurrentUserId();

      // --- 1. VALIDATE & UPLOAD FILES ---
      final File? dtiCertFile = formData['dtiCertFile'] as File?;
      final File? secCertFile = formData['secCertFile'] as File?;
      final File? cdaFile = formData['cdaFile'] as File?;
      final File? barangayClrncImage = formData['barangayClrncImage'] as File?;
      final File? landTitleFile = formData['landTitleFile'] as File?;
      final File? contractsFile = formData['contractsFile'] as File?;
      final File? establishmentImage = formData['establishmentImage'] as File?;
      final File? ownerImage = formData['ownerImage'] as File?;
      final File? endorsementFile = formData['endorsementFile'] as File?;
      final File? signatureImage = formData['signatureImage'] as File?;

      // Upload all files concurrently
      final results = await Future.wait([
        dtiCertFile != null ? _uploadFile(dtiCertFile, 'dtiCertFile', 'business-clearance-images') : Future.value(null),
        secCertFile != null ? _uploadFile(secCertFile, 'secCertFile', 'business-clearance-images') : Future.value(null),
        cdaFile != null ? _uploadFile(cdaFile, 'cdaFile', 'business-clearance-images') : Future.value(null),
        barangayClrncImage != null ? _uploadFile(barangayClrncImage, 'barangayClrncImage', 'business-clearance-images') : Future.value(null),
        landTitleFile != null ? _uploadFile(landTitleFile, 'landTitleFile', 'business-clearance-images') : Future.value(null),
        contractsFile != null ? _uploadFile(contractsFile, 'contractsFile', 'business-clearance-images') : Future.value(null),
        establishmentImage != null ? _uploadFile(establishmentImage, 'establishmentImage', 'business-clearance-images') : Future.value(null),
        ownerImage != null ? _uploadFile(ownerImage, 'ownerImage', 'business-clearance-images') : Future.value(null),
        endorsementFile != null ? _uploadFile(endorsementFile, 'endorsementFile', 'business-clearance-images') : Future.value(null),
        signatureImage != null ? _uploadFile(signatureImage, 'signatureImage', 'business-clearance-images') : Future.value(null),
      ]);

      final dtiCertUrl = results[0];
      final secCertUrl = results[1];
      final cdaFileUrl = results[2];
      final barangayClrncUrl = results[3];
      final landTitleUrl = results[4];
      final contractsUrl = results[5];
      final establishmentUrl = results[6];
      final ownerImageUrl = results[7];
      final endorsementUrl = results[8];
      final signatureUrl = results[9];

      // --- 2. CONSTRUCT & SUBMIT DATA ---
      final request = BusinessClearanceRequest(
        user_id: userId,
        applicationDate: formData['applicationDate'],
        appType: formData['appType'],
        businessName: formData['businessName'],
        houseNum: formData['houseNum'],
        bldgUnit: formData['bldgUnit'],
        street: formData['street'],
        village: formData['village'],
        natureOfBusiness: formData['natureOfBusiness'],
        ownershipType: formData['ownershipType'],
        locationStatus: formData['locationStatus'],
        totalArea: formData['totalArea'],
        capitalization: formData['capitalization'],
        grossSales: formData['grossSales'],
        ownerName: formData['ownerName'],
        contactNumber: formData['contactNumber'],
        email: formData['email'],
        dtiCertFileURL: dtiCertUrl,
        secCertFileURL: secCertUrl,
        cdaFileURL: cdaFileUrl,
        barangayClrncImageURL: barangayClrncUrl,
        landTitleFileURL: landTitleUrl,
        contractsFileURL: contractsUrl,
        establishmentImageURL: establishmentUrl,
        ownerImageURL: ownerImageUrl,
        endorsementFileURL: endorsementUrl,
        signatureImageURL: signatureUrl,
      );

      await _submitRequest('business_clearance_request', request.toMap());
    } catch (e) { // <-- CATCH BLOCK
    // Log the error and re-throw, or handle it here if necessary
    print("Error during Business Clearance submission: $e");
    rethrow; // Re-throwing ensures the UI layer can catch it and show a SnackBar.
    }
  }
}