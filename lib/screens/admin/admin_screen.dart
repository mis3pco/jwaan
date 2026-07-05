import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/user_store.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  void block(String email) {
    UserStore.blockUser(email);
    setState(() {});
  }

  void unblock(String email) {
    UserStore.unblockUser(email);
    setState(() {});
  }

  void acceptOrder(String id, String driverEmail) {
    OrderService.adminAccept(id, driverEmail);
    setState(() {});
  }

  void rejectOrder(String id) {
    OrderService.adminReject(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pending = OrderService.pendingOrders();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "لوحة التحكم",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        const Text(
          "الطلبات المعلقة",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...pending.map((o) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${o.from} → ${o.to}"),
                  Text("السعر: ${o.price}"),
                  Text("الحالة: ${o.status}"),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              acceptOrder(o.id, "driver@auto.com"),
                          child: const Text("قبول"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => rejectOrder(o.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("رفض"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 30),

        const Text(
          "المستخدمون",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        FutureBuilder(
          future: UserStore.loadUsers(),
          builder: (context, snapshot) {
            final users = snapshot.data ?? [];

            return Column(
              children: users.map((u) {
                return Card(
                  child: ListTile(
                    title: Text(u.email),
                    subtitle: Text("${u.role} - ${u.isBlocked ? "موقوف" : "نشط"}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!u.isBlocked)
                          IconButton(
                            icon: const Icon(Icons.block),
                            onPressed: () => block(u.email),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => unblock(u.email),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
