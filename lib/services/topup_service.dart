import 'package:flutter/material.dart';
import '../models/topup_request.dart';
import 'wallet_service.dart';

class TopupService extends ChangeNotifier {
  final WalletService walletService;
  final List<TopupRequest> _requests = [];

  TopupService({required this.walletService});

  List<TopupRequest> get pending =>
      _requests.where((r) => r.status == "pending").toList();

  List<TopupRequest> byDriver(String email) =>
      _requests.where((r) => r.driverEmail == email).toList();

  void createRequest(TopupRequest request) {
    _requests.insert(0, request);
    notifyListeners();
  }

  void approve(String id) {
    final req = _requests.firstWhere((r) => r.id == id);
    if (req.status != "pending") return;

    req.status = "approved";

    walletService.topUp(
      driverEmail: req.driverEmail,
      amount: req.amount,
      source: req.method,
    );
    notifyListeners();
  }

  void reject(String id) {
    final req = _requests.firstWhere((r) => r.id == id);
    if (req.status != "pending") return;

    req.status = "rejected";
    notifyListeners();
  }
}
