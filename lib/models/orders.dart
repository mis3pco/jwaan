class Order {
  final String id;
  final String customerEmail;
  final String from;
  final String to;
  final String type;
  final String description;
  final double price;
  String status;

  Order({
    required this.id,
    required this.customerEmail,
    required this.from,
    required this.to,
    required this.type,
    required this.description,
    required this.price,
    this.status = "pending",
  });
}
