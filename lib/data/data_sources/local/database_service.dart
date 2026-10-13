import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '/../core/constants/app_constants.dart';

class DatabaseService {
  static Database? _database;

  /// Singleton pattern - get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with migrations
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create initial schema (v1)
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        base_price REAL NOT NULL DEFAULT 0,
        sell_price REAL NOT NULL DEFAULT 0,
        stock INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        discount_percent REAL DEFAULT 0,
        payment_method TEXT NOT NULL,
        receipt_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Indexes for performance
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id)');
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 -> v2: Split price into base_price and sell_price
    if (oldVersion < 2) {
      // Add new columns
      await db.execute('ALTER TABLE products ADD COLUMN base_price REAL NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE products ADD COLUMN sell_price REAL NOT NULL DEFAULT 0');
      
      // Migrate price data: use old price as sell_price, base_price = sell_price * 0.7 (30% margin)
      await db.execute('''
        UPDATE products 
        SET sell_price = price, base_price = ROUND(price * 0.7, 2)
        WHERE sell_price = 0
      ''');
      
      // Note: Don't drop old price column yet for safety. Can remove in v3 if needed.
    }

    // v2 -> v4: Add discount_percent to transactions
    // This repairs both v2 DBs and v3 DBs (v3's _onCreate was missing this column)
    if (oldVersion < 4) {
      // Check if column exists before adding (defensive)
      final tableInfo = await db.rawQuery("PRAGMA table_info(transactions)");
      final hasColumn = tableInfo.any((col) => col['name'] == 'discount_percent');
      
      if (!hasColumn) {
        await db.execute('ALTER TABLE transactions ADD COLUMN discount_percent REAL DEFAULT 0');
      }
    }
  }

  /// Close database connection
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Reset database (for testing/debugging)
  static Future<void> reset() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await deleteDatabase(path);
    _database = null;
  }

  /// Insert sample products for development
  static Future<void> seedSampleProducts() async {
    final db = await database;
    final existing = await db.query(AppConstants.databaseProductsTable);
    if (existing.isNotEmpty) return;

    final products = [
      {'name': 'Coffee', 'base_price': 10500, 'sell_price': 15000, 'stock': 50, 'created_at': DateTime.now().toIso8601String()},
      {'name': 'Tea', 'base_price': 7000, 'sell_price': 10000, 'stock': 30, 'created_at': DateTime.now().toIso8601String()},
      {'name': 'Donut', 'base_price': 5600, 'sell_price': 8000, 'stock': 20, 'created_at': DateTime.now().toIso8601String()},
      {'name': 'Croissant', 'base_price': 8400, 'sell_price': 12000, 'stock': 25, 'created_at': DateTime.now().toIso8601String()},
      {'name': 'Sandwich', 'base_price': 14000, 'sell_price': 20000, 'stock': 15, 'created_at': DateTime.now().toIso8601String()},
    ];

    for (final product in products) {
      await db.insert(AppConstants.databaseProductsTable, product);
    }
  }
}
