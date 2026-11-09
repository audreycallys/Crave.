import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'pages/splash/splash_page.dart';
import 'pages/splash/loading_page.dart';
import 'services/api_service.dart';
import 'pages/main_page.dart';

void main() {
  runApp(const CraveApp());
}

class CraveApp extends StatelessWidget {
  const CraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crave',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isChecking = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  Future<void> checkToken() async {
    final startTime = DateTime.now();

    try {
      final token = await ApiService.getToken();

      final elapsed = DateTime.now().difference(startTime);
      final remaining = const Duration(seconds: 1) - elapsed;

      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (!mounted) return;

      setState(() {
        isLoggedIn = token != null && token.isNotEmpty;
        isChecking = false;
      });
    } catch (e) {
      final elapsed = DateTime.now().difference(startTime);
      final remaining = const Duration(seconds: 1) - elapsed;

      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (!mounted) return;

      setState(() {
        isLoggedIn = false;
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return const LoadingPage();
    }

    return isLoggedIn ? const MainPage() : const SplashPage();
  }
}
