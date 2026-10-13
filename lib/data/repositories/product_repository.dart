import '../models/product.dart';

/// Abstract repository for product operations
/// Allows swapping implementations (e.g., local SQLite -> cloud sync)
abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<Product?> getById(int id);
  Future<int> add(Product product);
  Future<int> update(Product product);
  Future<int> delete(int id);
  Future<List<Product>> search(String query);
  Future<void> updateStock(int productId, int delta);
}
