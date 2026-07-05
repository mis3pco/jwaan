import 'package:flutter/material.dart';
import '../services/session.dart';
import 'admin/admin_screen.dart';
import 'auth/auth_screen.dart';
import 'customer/create_order_screen.dart';
import 'customer/customer_orders_screen.dart';
import 'driver/driver_orders_screen.dart';
import 'driver/driver_wallet_screen.dart';
import 'driver/topup_screen.dart';
import 'tab_placeholder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  List<Widget> get _pages {
    if (Session.role == "admin") {
      return const [
        AdminScreen(),
        TabPlaceholder(
          title: 'الطلبات',
          icon: Icons.list,
          description: 'هنا ستظهر الطلبات بالتفصيل لاحقًا.',
        ),
        TabPlaceholder(
          title: 'الحساب',
          icon: Icons.person,
          description: 'بيانات الإدارة هنا.',
        ),
      ];
    }

    if (Session.role == "driver") {
      return const [
        DriverOrdersScreen(),
        DriverWalletScreen(),
        TopupScreen(),
      ];
    }

    return const [
      CreateOrderScreen(),
      CustomerOrdersScreen(),
      TabPlaceholder(
        title: 'حسابي',
        icon: Icons.person,
        description: 'بيانات العميل هنا.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!Session.isLoggedIn) {
      return const AuthScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("جوان للتوصيل - ${Session.name ?? ''}"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Session.logout();
              setState(() {
                _index = 0;
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "الطلبات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "الحساب",
          ),
        ],
      ),
    );
  }
}
