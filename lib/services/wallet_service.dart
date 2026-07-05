class WalletService {
  static final Map<String, double> _balances = {};
  static final List<Map<String, dynamic>> _transactions = [];
  static double companyCommissionTotal = 0.0;

  static double balanceOf(String driverEmail) {
    return _balances[driverEmail] ?? 0.0;
  }

  static List<Map<String, dynamic>> transactionsOf(String driverEmail) {
    return _transactions
        .where((t) => t['driverEmail'] == driverEmail)
        .toList()
        .reversed
        .toList();
  }

  static void topUp({
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
  }

  static void addEarning({
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
  }

  static void addCommission({
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
  }

  static void withdraw({
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
  }
}
