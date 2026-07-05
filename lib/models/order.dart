class Order {
  final String id;
  final String customerEmail;
  String? driverEmail;

  final String from;
  final String to;
  final String type;
  final String description;
  final double price;

  String status; // pending | accepted | picked | delivered | cancelled

  Order({
    required this.id,
    required this.customerEmail,
    this.driverEmail,
    required this.from,
    required this.to,
    required this.type,
    required this.description,
    required this.price,
    this.status = "pending",
  });
}
