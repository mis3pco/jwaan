class TopupRequest {
  final String id;
  final String driverEmail;
  final double amount;
  final String method; // بنكك / فوري / أوكاش / ماي كاشي
  final DateTime time;

  String status; // pending | approved | rejected

  TopupRequest({
    required this.id,
    required this.driverEmail,
    required this.amount,
    required this.method,
    required this.time,
    this.status = "pending",
  });
}
