import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class JawanDeliveryApp extends StatelessWidget {
  const JawanDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'جوان للتوصيل',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
      ),
      home: const AuthScreen(),
    );
  }
}
