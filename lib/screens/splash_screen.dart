import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/speech_service.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = 'Splash';
  static const routePath = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;
  Timer? _timerA;
  Timer? _timerB;

  @override
  void initState() {
    super.initState();
    _init();

    _timerA = Timer(const Duration(seconds: 5), () {
      if (_loading && mounted) {
        context.go(WelcomeScreen.routePath);
      }
    });

    _timerB = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) context.go(WelcomeScreen.routePath);
    });
  }

  Future<void> _init() async {
    try {
      await Future.any([
        speechService.initialize(),
        Future<void>.delayed(const Duration(seconds: 3)),
      ]);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    context.go(WelcomeScreen.routePath);
  }

  @override
  void dispose() {
    _timerA?.cancel();
    _timerB?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/Transparent Logo.png'),
          width: 280,
          height: 280,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

