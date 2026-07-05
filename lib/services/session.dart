class Session {
  static String? email;
  static String? role;
  static String? name;
  static String? phone;

  static bool get isLoggedIn => email != null;

  static void login({
    required String userEmail,
    required String userRole,
    required String userName,
    required String userPhone,
  }) {
    email = userEmail;
    role = userRole;
    name = userName;
    phone = userPhone;
  }

  static void logout() {
    email = null;
    role = null;
    name = null;
    phone = null;
  }
}
