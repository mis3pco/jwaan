import 'package:flutter/material.dart';

class WalletService extends ChangeNotifier {
  final Map<String, double> _balances = {};
  final List<Map<String, dynamic>> _transactions = [];
  double companyCommissionTotal = 0.0;

  double balanceOf(String driverEmail) {
    return _balances[driverEmail] ?? 0.0;
  }

  List<Map<String, dynamic>> transactionsOf(String driverEmail) {
    return _transactions
        .where((t) => t['driverEmail'] == driverEmail)
        .toList()
        .reversed
        .toList();
  }

  void topUp({
    required String driverEmail,
    required double amount,
    required String source,
  }) {
    final current = balanceOf(driverEmail);
    _balances[driverEmail] = current + amount;

    _transactions.add({
      'driverEmail': driverEmail,
      'type': 'topup',
      'amount': amount,
      'source': source,
      'time': DateTime.now(),
    });
    notifyListeners();
  }

  void addEarning({
    required String driverEmail,
    required double amount,
    required String orderId,
  }) {
    final current = balanceOf(driverEmail);
    _balances[driverEmail] = current + amount;

    _transactions.add({
      'driverEmail': driverEmail,
      'type': 'earning',
      'amount': amount,
      'orderId': orderId,
      'time': DateTime.now(),
    });
    notifyListeners();
  }

  void addCommission({
    required String driverEmail,
    required double amount,
    required String orderId,
  }) {
    companyCommissionTotal += amount;

    _transactions.add({
      'driverEmail': driverEmail,
      'type': 'commission',
      'amount': amount,
      'orderId': orderId,
      'time': DateTime.now(),
    });
    notifyListeners();
  }

  void withdraw({
    required String driverEmail,
    required double amount,
    required String reason,
  }) {
    final current = balanceOf(driverEmail);
    _balances[driverEmail] = current - amount;

    _transactions.add({
      'driverEmail': driverEmail,
      'type': 'withdraw',
      'amount': amount,
      'reason': reason,
      'time': DateTime.now(),
    });
    notifyListeners();
  }
}
