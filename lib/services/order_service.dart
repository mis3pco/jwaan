import '../models/order.dart';
import 'wallet_service.dart';

class OrderService {
  static final List<Order> _orders = [];

  static List<Order> get orders => List.unmodifiable(_orders);

  static void addOrder(Order order) {
    _orders.insert(0, order);
  }

  static Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Order> pendingOrders() =>
      _orders.where((o) => o.status == "pending").toList();

  static List<Order> driverOrders(String email) =>
      _orders.where((o) => o.driverEmail == email).toList();

  static List<Order> customerOrders(String email) =>
      _orders.where((o) => o.customerEmail == email).toList();

  // 🚀 ADMIN CONTROL
  static bool adminAccept(String id, String driverEmail) {
    final order = getById(id);
    if (order == null || order.status != "pending") return false;

    order.driverEmail = driverEmail;
    order.status = "accepted";
    return true;
  }

  static void adminReject(String id) {
    final order = getById(id);
    if (order == null) return;

    order.status = "rejected";
  }

  // DRIVER FLOW
  static bool updateStatus(
    String id,
    String driverEmail,
    String status,
  ) {
    final order = getById(id);
    if (order == null) return false;
    if (order.driverEmail != driverEmail) return false;

    if (status == "picked" && order.status == "accepted") {
      order.status = "picked";
      return true;
    }

    if (status == "delivered" && order.status == "picked") {
      order.status = "delivered";

      final driverShare = order.price * 0.95;
      final commission = order.price * 0.05;

      WalletService.addEarning(
        driverEmail: driverEmail,
        amount: driverShare,
        orderId: id,
      );

      WalletService.addCommission(
        driverEmail: driverEmail,
        amount: commission,
        orderId: id,
      );

      return true;
    }

    return false;
  }
}
