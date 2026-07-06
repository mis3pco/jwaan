abstract class NotificationService {
  /// Initialize the notification service (register, request permissions, etc.)
  Future<void> init();

  /// Send a notification to a driver (identified by email or id)
  Future<void> sendToDriver({required String driverId, required String title, required String body});

  /// Send a notification to an admin or broadcast
  Future<void> sendToAdmin({required String title, required String body});
}
