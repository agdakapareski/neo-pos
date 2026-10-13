import 'package:flutter/foundation.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository_impl.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepositoryImpl _repository;
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductProvider(this._repository);

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new product
  Future<bool> addProduct(Product product) async {
    try {
      await _repository.add(product);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update existing product
  Future<bool> updateProduct(Product product) async {
    try {
      await _repository.update(product);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete product
  Future<bool> deleteProduct(int id) async {
    try {
      await _repository.delete(id);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _products = await _repository.getAll();
      } else {
        _products = await _repository.search(query);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
