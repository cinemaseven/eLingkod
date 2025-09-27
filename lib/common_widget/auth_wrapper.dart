import 'dart:async';

import 'package:elingkod/pages/home.dart';
import 'package:elingkod/pages/profile_info.dart';
import 'package:elingkod/pages/registration.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Implement WidgetsBindingObserver to listen for app resume events
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  late final StreamSubscription<AuthState> _authStateSubscription;
  bool _isLoading = true; 
  final _supabase = Supabase.instance.client; // Supabase client instance

  @override
  void initState() {
    super.initState();
    // Start listening to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // 1. Initial Check: Route immediately based on current session status
    _initSessionCheck();
    
    // 2. Stream Listener: Listen for real-time session changes (e.g., sign out)
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      // Only process stream events if we are done with the initial loading
      if (!_isLoading && mounted) {
        // If the session is null, we route to Registration/Login immediately
        if (data.session == null || data.event == AuthChangeEvent.signedOut) {
          _routeToRegistration();
        } else {
          // If a session exists (e.g., from a deep link), we trigger the database check
          _handleAuthenticatedUserRouting(data.session!);
        }
      }
    });
  }

  // New method to handle the initial, synchronous check for a session
  Future<void> _initSessionCheck() async {
    final Session? session = _supabase.auth.currentSession;
    
    if (mounted) {
      // Stop the loading indicator
      setState(() {
        _isLoading = false;
      });
      
      // If session exists, route based on profile status.
      if (session != null) {
        await _handleAuthenticatedUserRouting(session);
      } else {
        // If no session on startup, go to Registration/Login flow.
        _routeToRegistration();
      }
    }
  }

  // NEW: Logic to check if the user has completed their profile in the database
  Future<void> _handleAuthenticatedUserRouting(Session session) async {
    if (!mounted) return;
    
    // Check if the user's ID exists in the 'user_details' table
    // Use .maybeSingle() to handle the case where the row doesn't exist (new user)
    try {
      final response = await _supabase
          .from('user_details') // <--- USING YOUR TABLE NAME
          .select('user_id')
          .eq('user_id', session.user.id) // Assuming user_id is the column matching Supabase user ID
          .maybeSingle();

      // Determine the next screen
      final bool profileExists = response != null;

      if (profileExists) {
        // Profile exists -> Go to Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        // Profile does NOT exist -> Go to ProfileInfo to create it
        // The user is authenticated but not onboarded.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileInfo(emailOrContact: '')),
        );
      }
    } catch (e) {
      // Handle database error, log it, and send user to a safe screen
      debugPrint('Database check failed: $e');
      _routeToRegistration();
    }
  }

  // Utility method to handle routing to the starting authentication screen
  void _routeToRegistration() {
    Navigator.of(context).pushReplacement(
      // We route to Registration as the main entry point, where they can choose Login
      MaterialPageRoute(builder: (context) => const Registration()), 
    );
  }

  // Listens for the app returning to the foreground (i.e., user came back from Gmail)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force Supabase to check for a deep link or updated session on resume
      _initSessionCheck();
    }
  }

  // Central routing logic run whenever the auth state changes (used primarily for SIGNED_OUT)
  void _onReceiveAuthEvent(AuthChangeEvent event, Session? session) {
    if (!mounted) return;
    
    if (session == null || event == AuthChangeEvent.signedOut) {
      _routeToRegistration();
    } else {
      // For signed-in events, defer to the DB check
      _handleAuthenticatedUserRouting(session);
    }
  }
  
  @override
  void dispose() {
    // Remove the lifecycle listener
    WidgetsBinding.instance.removeObserver(this);
    
    // Cancel the stream subscription
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Fallback screen is Registration
    return const Registration();
  }
}
