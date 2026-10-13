import '../models/transaction.dart';
import '../models/payment_method.dart';

/// Abstract repository for transaction operations
abstract class TransactionRepository {
  Future<int> add(Transaction transaction);
  Future<Transaction?> getById(int id);
  Future<List<Transaction>> getAll();
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end);
  Future<Map<PaymentMethod, double>> getPaymentMethodBreakdown(DateTime start, DateTime end);
  Future<double> getTotalSales(DateTime start, DateTime end);
  Future<int> getTransactionCount(DateTime start, DateTime end);
  Future<void> delete(int id);
}
