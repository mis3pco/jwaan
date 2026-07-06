import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/session.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  String selectedType = "طرد";

  final List<String> types = [
    "طرد",
    "مستندات",
    "أغراض",
    "طعام",
    "أدوية",
    "أخرى",
  ];

  void submitOrder() {
    final from = fromController.text.trim();
    final to = toController.text.trim();
    final description = descriptionController.text.trim();
    final priceText = priceController.text.trim();

    if (from.isEmpty || to.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أكمل الحقول الأساسية")),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أدخل سعرًا صحيحًا")),
      );
      return;
    }

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerEmail: Session.email ?? "",
      from: from,
      to: to,
      type: selectedType,
      description: description,
      price: price,
    );

    context.read<OrderService>().addOrder(order);

    fromController.clear();
    toController.clear();
    descriptionController.clear();
    priceController.clear();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إرسال الطلب")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myOrders = context.read<OrderService>().ordersForCustomer(Session.email ?? "");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "إنشاء طلب جديد",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: fromController,
            decoration: const InputDecoration(
              labelText: "من",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: toController,
            decoration: const InputDecoration(
              labelText: "إلى",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedType,
            decoration: const InputDecoration(
              labelText: "نوع الطلب",
              border: OutlineInputBorder(),
            ),
            items: types
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedType = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: "الوصف",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "السعر",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: submitOrder,
            child: const Text("إرسال الطلب"),
          ),
          const SizedBox(height: 24),
          const Text(
            "طلباتي",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (myOrders.isEmpty)
            const Text("لا توجد طلبات بعد")
          else
            ...myOrders.map(
              (order) => Card(
                child: ListTile(
                  title: Text("${order.from} → ${order.to}"),
                  subtitle: Text(
                    "${order.type} • ${order.price} • ${order.status.label}",
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
