import 'package:flutter/material.dart';
import '../core/services/transaction_service.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  List<TransactionRecord> transactions = [];
  bool isLoading = false;
  String? error;
  double todayTotal = 0;
  double monthTotal = 0;
  List<MapEntry<DateTime, double>> last7Days = [];
  List<MapEntry<DateTime, double>> monthDays = [];

  Future<void> loadTransactions() async {
    _setLoading(true);
    error = null;
    try {
      transactions = await _service.fetchTransactions();
      _computeSummaries();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTransaction({
    required String cashierId,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    error = null;
    final transactionId = await _service.createTransaction(
      cashierId: cashierId,
      total: total,
    );
    await _service.createTransactionItems(
      transactionId: transactionId,
      items: items,
    );
    await loadTransactions();
  }

  void _computeSummaries() {
    final now = DateTime.now();
    todayTotal = transactions.where((t) {
      final d = t.createdAt;
      if (d == null) return false;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).fold<double>(0, (sum, t) => sum + t.total);

    monthTotal = transactions.where((t) {
      final d = t.createdAt;
      if (d == null) return false;
      return d.year == now.year && d.month == now.month;
    }).fold<double>(0, (sum, t) => sum + t.total);

    last7Days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final total = transactions.where((t) {
        final d = t.createdAt;
        if (d == null) return false;
        return d.year == date.year && d.month == date.month && d.day == date.day;
      }).fold<double>(0, (sum, t) => sum + t.total);
      return MapEntry(date, total);
    });

    monthDays = List.generate(now.day, (i) {
      final date = DateTime(now.year, now.month, i + 1);
      final total = transactions.where((t) {
        final d = t.createdAt;
        if (d == null) return false;
        return d.year == date.year && d.month == date.month && d.day == date.day;
      }).fold<double>(0, (sum, t) => sum + t.total);
      return MapEntry(date, total);
    });
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
