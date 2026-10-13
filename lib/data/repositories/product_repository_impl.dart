import '../models/product.dart';
import '../data_sources/local/database_service.dart';
import 'product_repository.dart';

/// SQLite implementation of ProductRepository
class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<Product>> getAll() async {
    final db = await DatabaseService.database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Future<Product?> getById(int id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  @override
  Future<int> add(Product product) async {
    final db = await DatabaseService.database;
    return await db.insert('products', product.toMap());
  }

  @override
  Future<int> update(Product product) async {
    final db = await DatabaseService.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Product>> search(String query) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Future<void> updateStock(int productId, int delta) async {
    final db = await DatabaseService.database;
    await db.rawUpdate(
      'UPDATE products SET stock = stock + ? WHERE id = ?',
      [delta, productId],
    );
  }
}
