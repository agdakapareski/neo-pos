import 'package:flutter/foundation.dart';
import '../../data/models/transaction.dart';
import '../../data/models/payment_method.dart';
import '../../data/models/cart_item.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepositoryImpl _transactionRepository;
  final ProductRepositoryImpl _productRepository;

  TransactionProvider(this._transactionRepository, this._productRepository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Complete a sale transaction
  Future<bool> completeSale({
    required List<CartItem> cartItems,
    required double total,
    required double discountPercent,
    required PaymentMethod paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final transaction = Transaction(
        total: total,
        discountPercent: discountPercent,
        paymentMethod: paymentMethod,
        items: cartItems.map((item) => TransactionItem.fromCartItem(item)).toList(),
      );

      await _transactionRepository.add(transaction);
      
      // Clear cart after successful sale
      // Note: cart provider is separate, we signal here
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      // Rethrow so PaymentScreen's error handler displays the failure
      rethrow;
    }
  }

  /// Get recent transactions
  Future<List<Transaction>> getRecentTransactions() async {
    try {
      return await _transactionRepository.getAll();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  /// Get transactions by date range
  Future<List<Transaction>> getTransactionsByRange(DateTime start, DateTime end) async {
    try {
      return await _transactionRepository.getByDateRange(start, end);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  /// Get payment method breakdown
  Future<Map<PaymentMethod, double>> getPaymentBreakdown(DateTime start, DateTime end) async {
    try {
      return await _transactionRepository.getPaymentMethodBreakdown(start, end);
    } catch (e) {
      return {};
    }
  }

  /// Get total sales amount
  Future<double> getTotalSales(DateTime start, DateTime end) async {
    try {
      return await _transactionRepository.getTotalSales(start, end);
    } catch (e) {
      return 0.0;
    }
  }

  /// Get transaction count
  Future<int> getTransactionCount(DateTime start, DateTime end) async {
    try {
      return await _transactionRepository.getTransactionCount(start, end);
    } catch (e) {
      return 0;
    }
  }

  /// Void/delete a transaction (restores stock, then deletes transaction)
  Future<bool> voidTransaction(int id, List<TransactionItem> items) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Restore stock first, then delete transaction (FK cascade removes items)
      for (final item in items) {
        await _productRepository.updateStock(item.productId, item.quantity);
      }
      await _transactionRepository.delete(id);
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}