import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/wallet_service.dart';
import 'services/order_service.dart';
import 'services/topup_service.dart';
import 'services/local_persistence_service.dart';
import 'services/fcm_notification_service.dart';
import 'services/persistence_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistence = LocalPersistenceService();
  await persistence.init();

  final notifier = FcmNotificationService();
  await notifier.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<PersistenceService>.value(value: persistence),
        Provider<NotificationService>.value(value: notifier),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WalletService()),
        ChangeNotifierProvider(
          create: (context) => OrderService(
            walletService: context.read<WalletService>(),
            authService: context.read<AuthService>(),
            persistence: context.read<PersistenceService>(),
            notifier: context.read<NotificationService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TopupService(
            walletService: context.read<WalletService>(),
          ),
        ),
      ],
      child: const JawanDeliveryApp(),
    ),
  );
}
