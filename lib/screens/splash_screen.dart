import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset('assets/animations/splash_camera.json'),
      ),
      nextScreen: nextScreen,
      splashIconSize: 250,
      duration: 3000,
      backgroundColor: Colors.white,
    );
  }
}
