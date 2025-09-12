import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  CustomPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,    
          reverseTransitionDuration: Duration.zero, 
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}
