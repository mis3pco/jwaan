import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/session.dart';
import '../../services/wallet_service.dart';

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  void accept(String id) {
    final ok = OrderService.acceptOrder(id, Session.email ?? "");
    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم قبول الطلب")),
      );
    }
  }

  void picked(String id) {
    final ok = OrderService.updateStatusForDriver(
      id,
      Session.email ?? "",
      "picked",
    );
    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم استلام الطلب")),
      );
    }
  }

  void delivered(String id) {
    final ok = OrderService.updateStatusForDriver(
      id,
      Session.email ?? "",
      "delivered",
    );
    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تسليم الطلب")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myOrders = OrderService.driverOrders(Session.email ?? "");
    final availableOrders = OrderService.pendingOrders();
    final balance = WalletService.balanceOf(Session.email ?? "");

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text("رصيد المحفظة"),
              subtitle: Text(balance.toStringAsFixed(2)),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            "الطلبات المتاحة",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (availableOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text("لا توجد طلبات متاحة الآن")),
            )
          else
            ...availableOrders.map((order) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${order.from} → ${order.to}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("النوع: ${order.type}"),
                      Text("السعر: ${order.price}"),
                      Text("الحالة: ${order.status}"),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => accept(order.id),
                          child: const Text("قبول الطلب"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 20),
          const Text(
            "طلباتي",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (myOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text("لا توجد طلبات مخصصة لك بعد")),
            )
          else
            ...myOrders.map((order) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${order.from} → ${order.to}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("النوع: ${order.type}"),
                      Text("السعر: ${order.price}"),
                      Text("الحالة: ${order.status}"),
                      const SizedBox(height: 12),

                      if (order.status == "accepted")
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => picked(order.id),
                            child: const Text("تم استلام الطلب"),
                          ),
                        ),

                      if (order.status == "picked")
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => delivered(order.id),
                            child: const Text("تم التسليم"),
                          ),
                        ),

                      if (order.status == "delivered")
                        const Text(
                          "تم التسليم ✔",
                          style: TextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
