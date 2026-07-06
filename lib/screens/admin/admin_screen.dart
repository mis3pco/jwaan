import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/order_service.dart';
import '../../services/user_store.dart';
import '../../models/order_status.dart';
import '../../models/order.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  void block(String email) {
    UserStore.blockUser(email).then((_) => setState(() {}));
  }

  void unblock(String email) {
    UserStore.unblockUser(email).then((_) => setState(() {}));
  }

  void acceptOrder(String id, String driverEmail) {
    final ok = context.read<OrderService>().adminAccept(id, driverEmail);
    if (ok) setState(() {});
  }

  void rejectOrder(String id) {
    context.read<OrderService>().adminReject(id);
    setState(() {});
  }

  Future<void> _deleteOrder(BuildContext context, String id) async {
    final ok = context.read<OrderService>().deleteOrder(id);
    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الطلب')));
    }
  }

  Future<void> _editOrder(BuildContext context, Order order) async {
    final fromCtrl = TextEditingController(text: order.from);
    final toCtrl = TextEditingController(text: order.to);
    final typeCtrl = TextEditingController(text: order.type);
    final descCtrl = TextEditingController(text: order.description);
    final priceCtrl = TextEditingController(text: order.price.toString());
    final driverCtrl = TextEditingController(text: order.driverEmail ?? '');
    var status = order.status;

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل الطلب'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: fromCtrl, decoration: const InputDecoration(labelText: 'من')),
              TextField(controller: toCtrl, decoration: const InputDecoration(labelText: 'إلى')),
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'النوع')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'الوصف')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
              TextField(controller: driverCtrl, decoration: const InputDecoration(labelText: 'سائق (ايميل)')),
              DropdownButtonFormField<OrderStatus>(
                value: status,
                items: OrderStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                onChanged: (v) => status = v ?? status,
                decoration: const InputDecoration(labelText: 'الحالة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final newOrder = Order(
                id: order.id,
                customerEmail: order.customerEmail,
                driverEmail: driverCtrl.text.isEmpty ? null : driverCtrl.text,
                from: fromCtrl.text,
                to: toCtrl.text,
                type: typeCtrl.text,
                description: descCtrl.text,
                price: double.tryParse(priceCtrl.text) ?? order.price,
                status: status,
              );

              context.read<OrderService>().updateOrder(newOrder);
              Navigator.of(ctx).pop(true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (res == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pending = context.read<OrderService>().pendingOrders();
    final allOrders = context.read<OrderService>().orders;

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
                  Text("الحالة: ${o.status.label}"),
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
          "جميع الطلبات",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...allOrders.map((o) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${o.from} → ${o.to}"),
                  Text("السعر: ${o.price}"),
                  Text("الحالة: ${o.status.label}"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _editOrder(context, o),
                        child: const Text("تعديل"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _deleteOrder(context, o.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("حذف"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }),

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
