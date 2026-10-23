import 'package:flutter/material.dart';

class WhiteFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  WhiteFadePageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                Container(color: Colors.white),
                FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ],
            );
          },
        );
}