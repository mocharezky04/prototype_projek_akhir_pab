import 'package:flutter/material.dart';
import '../core/services/stock_service.dart';
import '../models/stock_movement.dart';

class StockProvider extends ChangeNotifier {
  final StockService _service = StockService();
  List<StockMovement> movements = [];
  bool isLoading = false;
  String? error;

  Future<void> loadMovements() async {
    _setLoading(true);
    error = null;
    try {
      movements = await _service.fetchMovements();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addMovement({
    required String productId,
    required int qty,
    required String type,
    String? note,
  }) async {
    error = null;
    await _service.createMovement(
      productId: productId,
      qty: qty,
      type: type,
      note: note,
    );
    await loadMovements();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
