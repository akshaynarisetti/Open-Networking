import 'package:flutter/material.dart';
import '../animations/onboarding_connect_animations.dart';
import 'circle_check_painter.dart';

class PairingAnimation extends StatelessWidget {
  final OnboardingConnectAnimations animations;

  const PairingAnimation({Key? key, required this.animations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animations.controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: animations.shrinkAnimation.value,
              child: Image.asset(
                'assets/images/pairing.gif',
                width: 290,
                height: 290,
                fit: BoxFit.contain,
              ),
            ),
            CustomPaint(
              painter: CircleCheckPainter(
                circle1Progress: animations.circle1Animation.value,
                circle2Progress: animations.circle2Animation.value,
                shrinkProgress: animations.shrinkAnimation.value,
                dotsAndLinesProgress: animations.dotsAndLinesAnimation.value,
                checkProgress: animations.checkAnimation.value,
                rotationAngle: animations.rotationAnimation.value,
              ),
              child: Container(
                width: 270,
                height: 270,
              ),
            ),
          ],
        );
      },
    );
  }
}