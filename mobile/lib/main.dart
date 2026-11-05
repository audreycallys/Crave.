import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'pages/splash_page.dart';

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
      home: const SplashPage(),
    );
  }
}
