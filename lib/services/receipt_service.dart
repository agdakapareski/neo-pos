import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_helper.dart';

class ReceiptService {
  /// Generate receipt PDF and return file path
  static Future<String> generateReceipt(Transaction transaction) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  AppConstants.appName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Transaction info
              pw.Text('Transaction #${transaction.id}'),
              pw.Text(
                DateFormat('dd MMM yyyy HH:mm').format(transaction.date),
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Items
              ...transaction.items.map((item) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              item.productName,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Text(CurrencyHelper.formatForReceipt(item.subtotal)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${item.quantity} x ${CurrencyHelper.formatForReceipt(item.unitPrice)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                    ],
                  )),

              pw.Divider(),
              pw.SizedBox(height: 8),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    CurrencyHelper.formatForReceipt(transaction.total),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Payment method
              pw.Text(
                'Payment: ${transaction.paymentMethod.displayName}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 16),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you!',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${directory.path}/${AppConstants.receiptsDir}');
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(transaction.date);
    final filePath = '${receiptsDir.path}/receipt_${transaction.id}_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Delete receipt file
  static Future<bool> deleteReceipt(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if receipt exists
  static Future<bool> receiptExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
