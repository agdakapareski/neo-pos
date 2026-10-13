import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  /// Total price for this line item
  double get subtotal => product.sellPrice * quantity;

  /// Copy with overrides
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() => 'CartItem(product: ${product.name}, qty: $quantity, subtotal: $subtotal)';
}
