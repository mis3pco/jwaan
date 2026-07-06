import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import 'wallet_service.dart';
import 'auth_service.dart';
import 'persistence_service.dart';
import 'notification_service.dart';

class OrderService extends ChangeNotifier {
  final WalletService walletService;
  final AuthService authService;
  final PersistenceService? persistence;
  final NotificationService? notifier;

  final List<Order> _orders = [];

  OrderService({
    required this.walletService,
    required this.authService,
    this.persistence,
    this.notifier,
  }) {
    _loadFromPersistence();
  }

  Future<void> _loadFromPersistence() async {
    if (persistence == null) return;
    final loaded = await persistence!.loadOrders();
    _orders.clear();
    _orders.addAll(loaded);
    notifyListeners();
  }

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
    persistence?.saveOrders(_orders);
    // Notify drivers about a new order (broadcast)
    // In a real setup, you'd find candidate drivers and send to them individually.
    notifier?.sendToAdmin(title: 'طلب جديد', body: 'تم إنشاء طلب جديد ${order.id}');
  }

  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Order> pendingOrders() =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  List<Order> driverOrders(String email) =>
      _orders.where((o) => o.driverEmail == email).toList();

  List<Order> customerOrders(String email) =>
      _orders.where((o) => o.customerEmail == email).toList();

  // Alias for customerOrders
  List<Order> ordersForCustomer(String email) => customerOrders(email);

  // 🚀 ADMIN CONTROL
  bool adminAccept(String id, String driverEmail) {
    final order = getById(id);
    if (order == null || order.status != OrderStatus.pending) return false;

    order.driverEmail = driverEmail;
    order.status = OrderStatus.accepted;
    notifyListeners();
    persistence?.saveOrders(_orders);
    notifier?.sendToDriver(
      driverId: driverEmail,
      title: 'تم قبول طلب',
      body: 'تم تعيين طلب ${order.id} لك',
    );
    return true;
  }

  void adminReject(String id) {
    final order = getById(id);
    if (order == null) return;

    order.status = OrderStatus.cancelled;
    notifyListeners();
    persistence?.saveOrders(_orders);
  }

  // Driver accept order (same as admin accept but different naming)
  bool acceptOrder(String id, String driverEmail) {
    final order = getById(id);
    if (order == null || order.status != OrderStatus.pending) return false;

    order.driverEmail = driverEmail;
    order.status = OrderStatus.accepted;
    notifyListeners();
    persistence?.saveOrders(_orders);
    notifier?.sendToDriver(
      driverId: driverEmail,
      title: 'تم قبول طلب',
      body: 'تم تعيين طلب ${order.id} لك',
    );
    return true;
  }

  // DRIVER FLOW
  bool updateStatus(
    String id,
    String driverEmail,
    OrderStatus status,
  ) {
    final order = getById(id);
    if (order == null) return false;
    if (order.driverEmail != driverEmail) return false;

    if (status == OrderStatus.picked && order.status == OrderStatus.accepted) {
      order.status = OrderStatus.picked;
      notifyListeners();
      persistence?.saveOrders(_orders);
      return true;
    }

    if (status == OrderStatus.delivered && order.status == OrderStatus.picked) {
      order.status = OrderStatus.delivered;

      final driverShare = order.price * 0.95;
      final commission = order.price * 0.05;

      walletService.addEarning(
        driverEmail: driverEmail,
        amount: driverShare,
        orderId: id,
      );

      walletService.addCommission(
        driverEmail: driverEmail,
        amount: commission,
        orderId: id,
      );

      notifyListeners();
      persistence?.saveOrders(_orders);
      return true;
    }

    return false;
  }

  // Alias for updateStatus
  bool updateStatusForDriver(String id, String driverEmail, String status) =>
      updateStatus(id, driverEmail, OrderStatusExtension.fromName(status));

  /// Replace an existing order by id with [updated]. Returns true on success.
  bool updateOrder(Order updated) {
    final idx = _orders.indexWhere((o) => o.id == updated.id);
    if (idx == -1) return false;

    _orders[idx] = updated;
    notifyListeners();
    persistence?.saveOrders(_orders);

    // Notify driver if assigned and status is accepted
    if (updated.driverEmail != null && updated.status == OrderStatus.accepted) {
      notifier?.sendToDriver(
        driverId: updated.driverEmail!,
        title: 'تم تعيين طلب',
        body: 'تم تعيين الطلب ${updated.id} لك',
      );
    }

    return true;
  }

  /// Delete an order by id.
  bool deleteOrder(String id) {
    final removed = _orders.removeWhere((o) => o.id == id) > 0;
    if (!removed) return false;
    notifyListeners();
    persistence?.saveOrders(_orders);
    return true;
  }
}
