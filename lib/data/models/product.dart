class Product {
  final int? id;
  final String name;
  final double basePrice;
  final double sellPrice;
  final int stock;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.basePrice,
    required this.sellPrice,
    required this.stock,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_price': basePrice,
      'sell_price': sellPrice,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      basePrice: (map['base_price'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toDouble(),
      stock: map['stock'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Copy with overrides
  Product copyWith({
    int? id,
    String? name,
    double? basePrice,
    double? sellPrice,
    int? stock,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, basePrice: $basePrice, sellPrice: $sellPrice, stock: $stock)';
}
