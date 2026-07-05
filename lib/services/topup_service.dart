import '../models/topup_request.dart';
import 'wallet_service.dart';

class TopupService {
  static final List<TopupRequest> _requests = [];

  static List<TopupRequest> get pending =>
      _requests.where((r) => r.status == "pending").toList();

  static List<TopupRequest> byDriver(String email) =>
      _requests.where((r) => r.driverEmail == email).toList();

  static void createRequest(TopupRequest request) {
    _requests.insert(0, request);
  }

  static void approve(String id) {
    final req = _requests.firstWhere((r) => r.id == id);
    if (req.status != "pending") return;

    req.status = "approved";

    WalletService.topUp(
      driverEmail: req.driverEmail,
      amount: req.amount,
      source: req.method,
    );
  }

  static void reject(String id) {
    final req = _requests.firstWhere((r) => r.id == id);
    if (req.status != "pending") return;

    req.status = "rejected";
  }
}
