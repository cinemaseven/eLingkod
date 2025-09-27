// import 'package:supabase_flutter/supabase_flutter.dart';

// class AuthService {
//   final _supabase = Supabase.instance.client;

//   // Function to format the phone number to E.164 format
//   String _formatPhoneNumber(String input) {
//     // Remove all non-digit characters
//     String digitsOnly = input.replaceAll(RegExp(r'\D'), '');

//     // Check for common Philippine phone number formats
//     if (digitsOnly.startsWith('09')) {
//       return '+63' + digitsOnly.substring(1);
//     } else if (digitsOnly.startsWith('639')) {
//       return '+' + digitsOnly;
//     } else if (digitsOnly.startsWith('+639')) {
//       return digitsOnly;
//     }
//     // Return original input if format is not recognized, Supabase will handle the error
//     return input;
//   }

//   Future<void> signUp({
//     String? email,
//     String? phoneNumber,
//     required String password,
//   }) async {
//     if (email != null && email.isNotEmpty) {
//       final AuthResponse res = await _supabase.auth.signUp(
//         email: email,
//         password: password,
//       );
//       if (res.user == null) {
//         throw const AuthException('Sign up with email failed. User not created.');
//       }
//     } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
//       // Format the phone number before sending it to Supabase
//       String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

//       final AuthResponse res = await _supabase.auth.signUp(
//         phone: formattedPhoneNumber,
//         password: password,
//         data: {'onboarding_complete': false},
//       );
//       if (res.user == null) {
//         throw const AuthException('Sign up with phone number failed. User not created.');
//       }
//     } else {
//       throw const AuthException('Either email or phone number must be provided.');
//     }
//   }

//   Future<void> verifyOtp({
//     required String phoneNumber,
//     required String token,
//   }) async {
//     // Format the phone number before verifying
//     String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);
    
//     final AuthResponse res = await _supabase.auth.verifyOTP(
//       phone: formattedPhoneNumber,
//       token: token,
//       type: OtpType.sms,
//     );
//     if (res.user == null) {
//       throw const AuthException('OTP verification failed.');
//     }
//   }
// }


import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Function to format the phone number to E.164 format
  String _formatPhoneNumber(String input) {
    // Remove all non-digit characters
    String digitsOnly = input.replaceAll(RegExp(r'\D'), '');

    // Check for common Philippine phone number formats
    if (digitsOnly.startsWith('09')) {
      return '+63' + digitsOnly.substring(1);
    } else if (digitsOnly.startsWith('639')) {
      return '+' + digitsOnly;
    } else if (digitsOnly.startsWith('+639')) {
      return digitsOnly;
    }
    // Return original input if format is not recognized, Supabase will handle the error
    return input;
  }

  Future<void> signUp({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    if (email != null && email.isNotEmpty) {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        // Custom metadata is often added here post-signup in a 'profiles' table 
        // for email, but keeping it simple for now.
      );
      if (res.user == null) {
        throw const AuthException('Sign up with email failed. User not created.');
      }
    } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Format the phone number before sending it to Supabase
      String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

      final AuthResponse res = await _supabase.auth.signUp(
        phone: formattedPhoneNumber,
        password: password,
        data: {'onboarding_complete': false},
      );
      if (res.user == null) {
        throw const AuthException('Sign up with phone number failed. User not created.');
      }
    } else {
      throw const AuthException('Either email or phone number must be provided.');
    }
  }
  
  // --- NEW LOGIC FOR USER LOGIN ---
  Future<void> signInWithCredentials({
    required String emailOrPhone,
    required String password,
  }) async {
    if (emailOrPhone.isEmpty || password.isEmpty) {
      throw const AuthException('Email/Phone and password cannot be empty.');
    }
    
    // Check if the input is an email (contains '@') or a phone number
    if (emailOrPhone.contains('@')) {
      // Log in with email
      await _supabase.auth.signInWithPassword(
        email: emailOrPhone,
        password: password,
      );
    } else {
      // Log in with phone number
      String formattedPhoneNumber = _formatPhoneNumber(emailOrPhone);
      
      await _supabase.auth.signInWithPassword(
        phone: formattedPhoneNumber,
        password: password,
      );
    }
    // Note: If sign-in fails (user not found, bad password), Supabase throws 
    // an AuthException, which the caller (Registration page) will catch.
  }
  // -------------------------------

  Future<void> verifyOtp({
    required String phoneNumber,
    required String token,
  }) async {
    // Format the phone number before verifying
    String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);
    
    final AuthResponse res = await _supabase.auth.verifyOTP(
      phone: formattedPhoneNumber,
      token: token,
      type: OtpType.sms,
    );
    if (res.user == null) {
      throw const AuthException('OTP verification failed.');
    }
  }
}
