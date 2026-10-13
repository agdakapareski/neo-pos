import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import '../../data/models/payment_method.dart';
import '../../data/models/transaction.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../presentation/providers/settings_provider.dart';

class ReceiptScreen extends StatefulWidget {
  final double total;
  final double discount;
  final double originalTotal;
  final PaymentMethod paymentMethod;
  final List<CartItem> items;
  final DateTime? date;

  const ReceiptScreen({
    super.key,
    required this.total,
    required this.discount,
    required this.originalTotal,
    required this.paymentMethod,
    required this.items,
    this.date,
  });

  /// Create from Transaction (read-only view from reports)
  factory ReceiptScreen.fromTransaction(Transaction txn) {
    // Calculate original total from stored discount percent
    final originalTotal = txn.discountPercent > 0
        ? txn.total / (1 - txn.discountPercent / 100)
        : txn.total;
    final discount = originalTotal - txn.total;

    // Build items list for display - convert TransactionItem to display format
    return ReceiptScreen(
      total: txn.total,
      discount: discount,
      originalTotal: originalTotal,
      paymentMethod: txn.paymentMethod,
      items: txn.items.map((item) => _CartItemFromTransaction(item)).toList(),
      date: txn.date,
    );
  }

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isExporting = false;

  /// Capture the printable receipt as a black & white PNG and share it.
  /// Output is resized to 576px wide for 80mm thermal printer compatibility.
  Future<void> _exportReceipt() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final boundary =
          _receiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Receipt is not ready yet');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to capture receipt image');
      }

      final decoded = img.decodeImage(byteData.buffer.asUint8List());
      if (decoded == null) {
        throw Exception('Failed to process receipt image');
      }

      // Resize to thermal-printer width first (cheaper), then force grayscale.
      final resized = decoded.width > 576
          ? img.copyResize(decoded, width: 576)
          : decoded;
      final bwBytes = Uint8List.fromList(img.encodePng(img.grayscale(resized)));

      final fileName =
          'receipt_${DateTime.now().millisecondsSinceEpoch}.png';
      final xFile = XFile.fromData(
        bwBytes,
        name: fileName,
        mimeType: 'image/png',
      );

      if (!mounted) return;
      await Share.shareXFiles([xFile], text: 'Receipt');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _handleDone() {
    // Pop back to POS screen or previous screen
    if (widget.date != null) {
      // Coming from reports, just pop once
      Navigator.pop(context);
    } else {
      // Coming from checkout, pop to POS
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = widget.date ?? DateTime.now();
    final storeName = context.watch<SettingsProvider>().brandName;

    // Black-only text styles so the captured PNG is thermal-printer ready
    // even before the grayscale conversion.
    const blackBody = TextStyle(color: Colors.black, fontSize: 14);
    const blackBold = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    const blackHeader = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    const blackTotal = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success icon (screen only, excluded from print capture)
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Success message (screen only)
                  Center(
                    child: Text(
                      'Payment Successful',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date time (screen only)
                  Center(
                    child: Text(
                      DateHelper.formatDateTime(displayDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Printable receipt (captured as B&W PNG)
                  RepaintBoundary(
                    key: _receiptKey,
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: Text(storeName, style: blackHeader)),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              DateHelper.formatDateTime(displayDate),
                              style: blackBody.copyWith(fontSize: 12),
                            ),
                          ),
                          const Divider(height: 24, color: Colors.black),
                          ...widget.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} x${item.quantity}',
                                      style: blackBody,
                                    ),
                                  ),
                                  Text(
                                    CurrencyHelper.formatCurrency(
                                      item.subtotal,
                                    ),
                                    style: blackBody,
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 24, color: Colors.black),

                          // Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: blackBody),
                              Text(
                                CurrencyHelper.formatCurrency(
                                  widget.originalTotal,
                                ),
                                style: blackBody,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Discount
                          if (widget.discount > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Discount', style: blackBody),
                                  Text(
                                    '- ${CurrencyHelper.formatCurrency(widget.discount)}',
                                    style: blackBody,
                                  ),
                                ],
                              ),
                            ),

                          const Divider(height: 24, color: Colors.black),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: blackTotal),
                              Text(
                                CurrencyHelper.formatCurrency(widget.total),
                                style: blackTotal,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Payment method
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payment Method',
                                style: blackBody,
                              ),
                              Text(
                                widget.paymentMethod.displayName,
                                style: blackBold,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Thank you!',
                              style: blackBody.copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Export + Done buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isExporting ? null : _exportReceipt,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.share),
                    label: Text(
                      _isExporting ? 'Exporting...' : 'Export PNG',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleDone,
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Adapter to display TransactionItem as CartItem in receipt
class _CartItemFromTransaction extends CartItem {
  _CartItemFromTransaction(TransactionItem item)
    : super(
        product: Product(
          id: item.productId,
          name: item.productName,
          basePrice: item.unitPrice,
          sellPrice: item.unitPrice,
          stock: 0,
        ),
        quantity: item.quantity,
      );
}
