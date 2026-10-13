# Flutter POS

Simple Point of Sale (POS) application built with Flutter and local SQLite storage.

## Features

- **Product Management**: Add, edit, delete, and search products with stock tracking
- **POS Checkout**: Quick product selection with cart management
- **Multiple Payment Methods**: Cash, QRIS, Debit, Credit
- **Receipt Generation**: PDF receipts saved locally for external printing
- **Sales Reports**: Daily, monthly, and yearly reports with payment method breakdown
- **Offline-First**: All data stored locally in SQLite

## Architecture

Clean architecture with separated layers:

```
lib/
├── core/              # Constants, utils, theme
├── data/              # Models, repositories, database
├── services/          # Receipt generation
└── presentation/      # Screens, providers, widgets
```

## Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Local Database**: sqflite
- **PDF Generation**: pdf + printing packages
- **Date/Number Formatting**: intl

## Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart 3.0 or higher

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd POS
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Usage

### 1. Add Products
- Open Products screen from POS toolbar
- Tap + button to add new product
- Enter product name, price, and stock
- Save product

### 2. Process Sale
- From POS screen, tap product cards to add to cart
- Adjust quantities using +/- buttons
- Tap Checkout
- Select payment method
- Complete sale

### 3. View Reports
- Open Reports screen from POS toolbar
- Select period: Today, This Month, This Year, or Custom
- View total sales, transaction count, and payment breakdown

### 4. Receipt Generation

Receipts are automatically generated and saved as PDF files in:
```
<Documents>/receipts/receipt_<id>_<timestamp>.pdf
```

Use any PDF viewer or print app to access and print receipts.

## Database Schema

```sql
products (
  id INTEGER PRIMARY KEY,
  name TEXT,
  price REAL,
  stock INTEGER,
  created_at TEXT
)

transactions (
  id INTEGER PRIMARY KEY,
  date TEXT,
  total REAL,
  payment_method TEXT,
  receipt_path TEXT
)

transaction_items (
  id INTEGER PRIMARY KEY,
  transaction_id INTEGER,
  product_id INTEGER,
  product_name TEXT,
  quantity INTEGER,
  unit_price REAL,
  subtotal REAL
)
```

## Future Enhancements

The app is designed to be scalable. Planned features:

- [ ] Product categories
- [ ] Discount system
- [ ] Multi-user support
- [ ] Cloud sync
- [ ] Barcode scanner integration
- [ ] Customer management
- [ ] Inventory alerts
- [ ] Export reports to Excel/PDF
- [ ] WhatsApp/Email receipt sharing

## Contributing

Contributions welcome! The architecture supports easy feature additions through:

- **Repository Pattern**: Swap SQLite for cloud storage
- **Feature Flags**: Toggle features in `AppConstants`
- **Clean Separation**: Add features without touching existing code

## License

This project is open source and available under the MIT License.
