import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/lucy_theme.dart';

class LucyApp extends StatelessWidget {
  const LucyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucy',
      debugShowCheckedModeBanner: false,
      theme: LucyTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
