import 'package:flutter/material.dart';
import 'dart:math' as math;

class OnboardingConnectAnimations {
  final TickerProvider vsync;
  late AnimationController controller;
  late Animation<double> circle1Animation;
  late Animation<double> circle2Animation;
  late Animation<double> shrinkAnimation;
  late Animation<double> dotsAndLinesAnimation;
  late Animation<double> checkAnimation;
  late Animation<double> rotationAnimation;

  OnboardingConnectAnimations(this.vsync) {
    controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 3),
    );

    circle1Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    circle2Animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.15, 0.45, curve: Curves.easeInOut),
      ),
    );

    shrinkAnimation = Tween<double>(begin: 1, end: 0.5).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.45, 0.6, curve: Curves.easeInOut),
      ),
    );

    dotsAndLinesAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.6, 0.8, curve: Curves.easeInOut),
      ),
    );

    checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.8, 1.0, curve: Curves.easeInOut),
      ),
    );

    rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ),
    );
  }

  void dispose() {
    controller.dispose();
  }
}