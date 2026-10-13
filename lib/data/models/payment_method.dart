import 'package:flutter/material.dart';

/// Payment method enumeration for transactions
enum PaymentMethod {
  cash,
  qris,
  debit,
  credit;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.debit:
        return 'Debit';
      case PaymentMethod.credit:
        return 'Credit';
    }
  }

  /// Icon for UI
  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.qris:
        return Icons.qr_code;
      case PaymentMethod.debit:
        return Icons.credit_card;
      case PaymentMethod.credit:
        return Icons.credit_card;
    }
  }

  /// Parse from string (database)
  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  /// Convert to string (database)
  String toDatabaseString() => name;
}