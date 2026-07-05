import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'services/auth_service.dart';

class JawanDeliveryApp extends StatelessWidget {
  const JawanDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
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
          home: auth.isLoggedIn ? const HomeScreen() : const AuthScreen(),
        );
      },
    );
  }
}
