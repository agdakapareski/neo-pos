import 'payment_method.dart';
import 'cart_item.dart';

class TransactionItem {
  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  TransactionItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  /// Create from database map
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  /// Create from CartItem for checkout
  factory TransactionItem.fromCartItem(CartItem cartItem) {
    return TransactionItem(
      productId: cartItem.product.id!,
      productName: cartItem.product.name,
      quantity: cartItem.quantity,
      unitPrice: cartItem.product.sellPrice,
      subtotal: cartItem.subtotal,
    );
  }

  @override
  String toString() => 'TransactionItem($productName x$quantity @ $unitPrice = $subtotal)';
}

class Transaction {
  final int? id;
  final DateTime date;
  final double total;
  final double discountPercent;
  final PaymentMethod paymentMethod;
  final String? receiptPath;
  final List<TransactionItem> items;

  Transaction({
    this.id,
    DateTime? date,
    required this.total,
    this.discountPercent = 0.0,
    required this.paymentMethod,
    this.receiptPath,
    this.items = const [],
  }) : date = date ?? DateTime.now();

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total': total,
      'discount_percent': discountPercent,
      'payment_method': paymentMethod.toDatabaseString(),
      'receipt_path': receiptPath,
    };
  }

  /// Create from database map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      total: (map['total'] as num).toDouble(),
      discountPercent: (map['discount_percent'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.fromString(map['payment_method'] as String),
      receiptPath: map['receipt_path'] as String?,
    );
  }

  /// Copy with overrides
  Transaction copyWith({
    int? id,
    DateTime? date,
    double? total,
    double? discountPercent,
    PaymentMethod? paymentMethod,
    String? receiptPath,
    List<TransactionItem>? items,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      total: total ?? this.total,
      discountPercent: discountPercent ?? this.discountPercent,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptPath: receiptPath ?? this.receiptPath,
      items: items ?? this.items,
    );
  }

  @override
  String toString() => 'Transaction(id: $id, date: ${date.toLocal()}, total: $total, method: ${paymentMethod.displayName})';
}
