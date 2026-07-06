// FCM implementation stub. To enable, add firebase_core and firebase_messaging
// configuration and call [init()].
import 'notification_service.dart';

// Uncomment these imports when Firebase SDK is configured:
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class FcmNotificationService implements NotificationService {
  FcmNotificationService();

  @override
  Future<void> init() async {
    // Initialize Firebase and messaging here when ready.
  }

  @override
  Future<void> sendToAdmin({required String title, required String body}) async {
    // Implement server-side or topic-based notifications.
  }

  @override
  Future<void> sendToDriver({required String driverId, required String title, required String body}) async {
    // Map driverId to FCM token and send message.
  }
}
