import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product.dart';
import '../providers/product_provider.dart';
// import '../../core/utils/currency_helper.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _basePriceController;
  late TextEditingController _sellPriceController;
  late TextEditingController _stockController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _basePriceController = TextEditingController(text: widget.product?.basePrice.toString() ?? '');
    _sellPriceController = TextEditingController(text: widget.product?.sellPrice.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _basePriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();
    final name = _nameController.text.trim();
    final basePrice = double.parse(_basePriceController.text);
    final sellPrice = double.parse(_sellPriceController.text);
    final stock = int.parse(_stockController.text);

    final product = Product(
      id: widget.product?.id,
      name: name,
      basePrice: basePrice,
      sellPrice: sellPrice,
      stock: stock,
    );

    final success = widget.product == null
        ? await provider.addProduct(product)
        : await provider.updateProduct(product);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null ? 'Product added' : 'Product updated'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'Enter product name',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Product name is required';
                }
                if (value!.length < 3) {
                  return 'Product name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Base Price (cost)
            TextFormField(
              controller: _basePriceController,
              decoration: const InputDecoration(
                labelText: 'Base Price (Cost)',
                hintText: 'Enter base price',
                prefixText: 'Rp ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Base price is required';
                }
                final price = double.tryParse(value!);
                if (price == null || price <= 0) {
                  return 'Base price must be a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Sell Price
            TextFormField(
              controller: _sellPriceController,
              decoration: const InputDecoration(
                labelText: 'Sell Price',
                hintText: 'Enter sell price',
                prefixText: 'Rp ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Sell price is required';
                }
                final price = double.tryParse(value!);
                if (price == null || price <= 0) {
                  return 'Sell price must be a valid positive number';
                }
                if (price < double.parse(_basePriceController.text)) {
                  return 'Sell price must be >= base price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Stock
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock',
                hintText: 'Enter stock quantity',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Stock is required';
                }
                final stock = int.tryParse(value!);
                if (stock == null || stock < 0) {
                  return 'Stock must be a valid non-negative number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text(widget.product == null ? 'Add' : 'Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
