class AppUser {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role; // admin | driver | customer

  bool isBlocked;

  AppUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.isBlocked = false,
  });
}
