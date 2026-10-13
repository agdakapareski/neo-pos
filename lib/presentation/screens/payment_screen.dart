import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/payment_method.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../../core/utils/currency_helper.dart';
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  final List<CartItem> items;

  const PaymentScreen({
    super.key,
    required this.total,
    required this.items,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late TextEditingController _nominalController;
  late TextEditingController _discountController;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _nominalController = TextEditingController();
    _discountController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  double get _nominal {
    return double.tryParse(_nominalController.text) ?? 0;
  }

  double get _discountPercent {
    return double.tryParse(_discountController.text) ?? 0;
  }

  double get _discountAmount {
    return widget.total * (_discountPercent / 100);
  }

  double get _amountDue {
    return max(0, widget.total - _discountAmount);
  }

  double get _change {
    if (_selectedPaymentMethod != PaymentMethod.cash) return 0;
    final change = _nominal - _amountDue;
    return change > 0 ? change : 0;
  }

  void _useTotal() {
    _nominalController.text = _amountDue.toStringAsFixed(0);
  }

  Future<void> _processPayment() async {
    // Validate for cash payments
    if (_selectedPaymentMethod == PaymentMethod.cash) {
      if (_nominalController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter nominal')),
        );
        return;
      }

      if (_nominal < _amountDue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount paid is less than amount payable')),
        );
        return;
      }
    }

    if (_amountDue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount payable must be greater than 0')),
      );
      return;
    }

    final transactionProvider = context.read<TransactionProvider>();
    final cartProvider = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();

    try {
      await transactionProvider.completeSale(
        cartItems: widget.items,
        total: _amountDue,
        discountPercent: _discountPercent,
        paymentMethod: _selectedPaymentMethod,
      );

      if (!mounted) return;

      // Clear cart and reload products (stock changed)
      cartProvider.clearCart();
      productProvider.loadProducts();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            total: _amountDue,
            discount: _discountAmount,
            originalTotal: widget.total,
            paymentMethod: _selectedPaymentMethod,
            items: widget.items,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart total display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cart Total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyHelper.formatCurrency(widget.total),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Discount input
              Text(
                'Discount (%)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0%',
                  suffixText: '%',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Amount payable
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount Payable',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      CurrencyHelper.formatCurrency(_amountDue),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment method dropdown
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Row(
                      children: [
                        Icon(method.icon, size: 20),
                        const SizedBox(width: 12),
                        Text(method.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                    // Clear nominal when switching away from cash
                    if (_selectedPaymentMethod != PaymentMethod.cash) {
                      _nominalController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // Nominal input (Cash only)
              if (_selectedPaymentMethod == PaymentMethod.cash) ...[
                Text(
                  'Cash Received',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nominalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _useTotal,
                      child: const Text('Exact'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Change display (Cash only, when change > 0)
              if (_selectedPaymentMethod == PaymentMethod.cash && _change > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green.shade800,
                            ),
                      ),
                      Text(
                        CurrencyHelper.formatCurrency(_change),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Pay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processPayment,
                  child: const Text('Complete Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
