import 'package:flutter/foundation.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  /// Calculate cart total
  double get total {
    double sum = 0;
    for (final item in _items) {
      sum += item.subtotal;
    }
    return sum;
  }

  /// Get item count
  int get itemCount {
    int count = 0;
    for (final item in _items) {
      count += item.quantity;
    }
    return count;
  }

  /// Check if item exists in cart
  bool containsProduct(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Add product to cart (capped at stock)
  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // Update quantity, cap at stock
      final newQuantity = _items[index].quantity + 1;
      final capped = newQuantity > product.stock ? product.stock : newQuantity;
      _items[index] = _items[index].copyWith(quantity: capped);
    } else {
      // Add new item (quantity 1, or 0 if stock is 0)
      _items.add(CartItem(product: product, quantity: product.stock > 0 ? 1 : 0));
    }

    notifyListeners();
  }

  /// Update item quantity (capped at stock)
  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final product = _items[index].product;
      final capped = quantity > product.stock ? product.stock : quantity;
      _items[index] = _items[index].copyWith(quantity: capped);
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Get cart item for product
  CartItem? getItem(int productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Get or create cart item for product
  CartItem getOrCreate(Product product) {
    final existing = getItem(product.id!);
    if (existing != null) return existing;

    final newItem = CartItem(product: product, quantity: 0);
    _items.add(newItem);
    notifyListeners();
    return newItem;
  }
}
