import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/wallet_service.dart';
import 'services/order_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WalletService()),
      ],
      child: const AppProvidersBootstrap(),
    ),
  );
}

class AppProvidersBootstrap extends StatelessWidget {
  const AppProvidersBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    // Create OrderService after WalletService and AuthService are available
    return ChangeNotifierProvider<OrderService>(
      create: (_) => OrderService(
        walletService: context.read<WalletService>(),
        authService: context.read<AuthService>(),
      ),
      child: const JawanDeliveryApp(),
    );
  }
}
