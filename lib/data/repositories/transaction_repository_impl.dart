import '../models/transaction.dart';
import '../models/payment_method.dart';
import '../data_sources/local/database_service.dart';
import 'transaction_repository.dart';

/// SQLite implementation of TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<int> add(Transaction transaction) async {
    final db = await DatabaseService.database;
    
    // Start transaction
    await db.transaction((txn) async {
      // Insert main transaction
      final transactionId = await txn.insert(
        'transactions',
        transaction.toMap(),
      );

      // Insert transaction items
      for (final item in transaction.items) {
        final itemMap = item.toMap();
        itemMap['transaction_id'] = transactionId;
        await txn.insert('transaction_items', itemMap);
      }

      // Update product stock (inventory tracking)
      for (final item in transaction.items) {
        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
    });

    // Return the transaction ID (not needed for UI, but available)
    return 0;
  }

  @override
  Future<Transaction?> getById(int id) async {
    final db = await DatabaseService.database;
    
    // Get transaction
    final transactionMaps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (transactionMaps.isEmpty) return null;
    
    final transaction = Transaction.fromMap(transactionMaps.first);
    
    // Get transaction items
    final itemMaps = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [id],
    );
    
    final items = itemMaps
        .map((map) => TransactionItem.fromMap(map))
        .toList();
    
    return transaction.copyWith(items: items);
  }

  @override
  Future<List<Transaction>> getAll() async {
    final db = await DatabaseService.database;
    final transactionMaps = await db.query('transactions', orderBy: 'date DESC');

    if (transactionMaps.isEmpty) return [];

    // Fetch all transaction items
    final transactionIds = transactionMaps.map((m) => m['id'] as int).toList();
    final placeholders = transactionIds.map((_) => '?').join(',');
    final itemMaps = await db.query(
      'transaction_items',
      where: 'transaction_id IN ($placeholders)',
      whereArgs: transactionIds,
      orderBy: 'id',
    );

    // Group items by transaction_id
    final itemsByTransaction = <int, List<Map<String, dynamic>>>{};
    for (final map in itemMaps) {
      final txnId = map['transaction_id'] as int;
      if (itemsByTransaction[txnId] == null) {
        itemsByTransaction[txnId] = [];
      }
      itemsByTransaction[txnId]!.add(map);
    }

    // Build transactions with items
    return transactionMaps.map((map) {
      final txn = Transaction.fromMap(map);
      final items = (itemsByTransaction[map['id'] as int] ?? [])
          .map((itemMap) => TransactionItem.fromMap(itemMap))
          .toList();
      return txn.copyWith(items: items);
    }).toList();
  }

  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    final db = await DatabaseService.database;
    final transactionMaps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    if (transactionMaps.isEmpty) return [];

    // Fetch all transaction items for these transactions
    final transactionIds = transactionMaps.map((m) => m['id'] as int).toList();
    final placeholders = transactionIds.map((_) => '?').join(',');
    final itemMaps = await db.query(
      'transaction_items',
      where: 'transaction_id IN ($placeholders)',
      whereArgs: transactionIds,
      orderBy: 'id',
    );

    // Group items by transaction_id
    final itemsByTransaction = <int, List<Map<String, dynamic>>>{};
    for (final map in itemMaps) {
      final txnId = map['transaction_id'] as int;
      if (itemsByTransaction[txnId] == null) {
        itemsByTransaction[txnId] = [];
      }
      itemsByTransaction[txnId]!.add(map);
    }

    // Build transactions with items
    return transactionMaps.map((map) {
      final txn = Transaction.fromMap(map);
      final items = (itemsByTransaction[map['id'] as int] ?? [])
          .map((itemMap) => TransactionItem.fromMap(itemMap))
          .toList();
      return txn.copyWith(items: items);
    }).toList();
  }

  @override
  Future<Map<PaymentMethod, double>> getPaymentMethodBreakdown(DateTime start, DateTime end) async {
    final db = await DatabaseService.database;
    final maps = await db.rawQuery('''
      SELECT payment_method, SUM(total) as total_amount
      FROM transactions
      WHERE date BETWEEN ? AND ?
      GROUP BY payment_method
    ''', [start.toIso8601String(), end.toIso8601String()]);

    final breakdown = <PaymentMethod, double>{};
    for (final map in maps) {
      final method = PaymentMethod.fromString(map['payment_method'] as String);
      final total = (map['total_amount'] as num?)?.toDouble() ?? 0;
      breakdown[method] = total;
    }

    return breakdown;
  }

  @override
  Future<double> getTotalSales(DateTime start, DateTime end) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(total), 0) as total_sales
      FROM transactions
      WHERE date BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return (result.first['total_sales'] as num?)?.toDouble() ?? 0;
  }

  @override
  Future<int> getTransactionCount(DateTime start, DateTime end) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM transactions
      WHERE date BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return (result.first['count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
