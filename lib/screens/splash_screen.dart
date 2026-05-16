import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stradia_ace/screens/home_page.dart';
import 'package:stradia_ace/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;
  @override
  void initState() {
    super.initState();
    // Safety timeout: navigate after 10 seconds if Lottie doesn't trigger navigation
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) _navigateToNext();
    });
  }

  void _navigateToNext() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.isLoggedIn ? const HomePage() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SizedBox.expand(
        child: Lottie.asset(
          'assets/splash screen/Scene_cleaned.json',
          fit: BoxFit.cover,
          repeat: false,
          onLoaded: (composition) {
            Future.delayed(composition.duration, () {
              _navigateToNext();
            });
          },
        ),
      ),
    );
  }
}
