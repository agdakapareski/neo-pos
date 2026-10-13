/// App-wide constants for easy configuration and feature flags
class AppConstants {
  static const String appName = 'Si Paling POS';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'pos.db';
  static const int databaseVersion = 4;
  static const String databaseProductsTable = 'products';
  static const String databaseTransactionsTable = 'transactions';
  static const String databaseTransactionItemsTable = 'transaction_items';
  
  // Receipt
  static const double receiptWidth = 80.0; // mm
  static const double receiptFontSize = 12.0;
  static const double receiptHeaderFontSize = 16.0;
  
  // Feature flags
  static const bool enableDiscounts = false;
  static const bool enableInventoryTracking = true;
  static const bool enableMultiUser = false;
  
  // Paths
  static const String receiptsDir = 'receipts';
}
