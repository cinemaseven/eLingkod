import 'dart:async'; // Add this import for StreamSubscription

import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:elingkod/pages/registration.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // StreamSubscription to manage the listener lifecycle
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Use the listener for ALL routing. This is the most reliable way 
    // to catch deep link redirects on the web platform.
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _onReceiveAuthEvent(data.event, data.session);
    });
  }

  // Central routing logic run whenever the auth state changes
  void _onReceiveAuthEvent(AuthChangeEvent event, Session? session) {
    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Check for explicit sign out, or if the session is null (initial load, no user)
    if (session == null || event == AuthChangeEvent.signedOut) {
      // No session or signed out: go to Registration
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Registration()),
      );
    } else {
      // Session exists (e.g., SIGNED_IN after link click, or INITIAL_SESSION)
      final Map<String, dynamic>? userMetadata = session.user.userMetadata;
      
      // Default to false if the metadata key doesn't exist yet
      bool onboardingComplete = userMetadata?['onboarding_complete'] ?? false; 

      // Note: We need to pass the email/contact forward if we're going to ProfileInfo, 
      // but since the metadata might not have the full original contact yet, 
      // the ProfileInfo screen will need to handle fetching/prompting that info,
      // or you can rely on the data you stored in the 'profiles' table after the first step.
      
      if (onboardingComplete) {
        // Returning user with completed profile goes to Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        // Logged in, but profile is incomplete (like after clicking confirmation link)
        // Redirect to the first step of the profile creation flow (ProfileInfo)
        
        // **IMPORTANT**: If ProfileInfo requires a specific emailOrContact string 
        // to pre-fill or use, you will need to get that from the user or the session data.
        // For simplicity, we pass an empty string here, but ensure your ProfileInfo widget 
        // can handle this if the data isn't available immediately.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileInfo(emailOrContact: '')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    // Clean up the subscription when the widget is removed
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We show the loading screen only while the stream listener is waiting for the first event.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
