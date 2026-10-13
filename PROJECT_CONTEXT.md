# Project Context

## Project Overview
- **Goal**: Simple POS app with local SQLite storage, receipt generation, and reports
- **Target**: Single cashier, minimal UI, clean and modern interface
- **Key Features**: Product catalog, cart, checkout with 4 payment methods (cash/qris/debit/credit), receipt generation for external print app, daily/monthly/yearly reports

## Tech Stack
- **State management**: provider (lightweight, used throughout)
- **Local database**: sqflite + path + path_provider
- **PDF/Receipt**: pdf + printing packages
- **Date/number**: intl package
- **Platform**: Flutter, Android + iOS compatible

## Architecture
```text
lib/
├── core/           # Constants, utils, theme
├── data/           # Models, repositories, database
├── domain/         # Use cases (business logic)
└── presentation/   # Screens, providers, widgets
    └── services/   # Receipt generation
```

## Database Schema (v1)
```sql
products (id INTEGER PRIMARY KEY, name TEXT, price REAL, stock INTEGER, created_at TEXT)
transactions (id INTEGER PRIMARY KEY, date TEXT, total REAL, payment_method TEXT, receipt_path TEXT)
transaction_items (id INTEGER PRIMARY KEY, transaction_id INTEGER, product_id INTEGER, qty INTEGER, unit_price REAL, subtotal REAL)
```

## Database Schema (v2 - Pending)
```sql
products (id INTEGER PRIMARY KEY, name TEXT, base_price REAL, sell_price REAL, stock INTEGER, created_at TEXT)
transaction_items (id INTEGER PRIMARY KEY, transaction_id INTEGER, product_id INTEGER, qty INTEGER, unit_price REAL, item_discount REAL, subtotal REAL)
```

## Conventions
- IDs: `INTEGER PRIMARY KEY AUTOINCREMENT`
- Dates: ISO 8601 TEXT (`yyyy-MM-dd HH:mm:ss`)
- Money: REAL (store as minor units - cents/rupiah - for precision)
- Payment methods: enum `cash | qris | debit | credit`
- Feature flags in `AppConstants` for future toggles

## Current Architecture / Screens
```text
lib/
├── core/
├── data/
├── domain/
└── presentation/
    ├── screens/
    │   ├── pos_screen.dart
    │   ├── cart_screen.dart
    │   ├── products_screen.dart
    │   ├── add_product_screen.dart
    │   └── reports_screen.dart
    ├── providers/
    │   ├── product_provider.dart
    │   ├── cart_provider.dart
    │   └── transaction_provider.dart
    └── services/
        └── receipt_service.dart
```

## Progress
- Flutter scaffold + pubspec dependencies
- Core constants/theme/utils
- Data models
- DatabaseService with migrations + seedSampleProducts()
- Repositories and providers
- POS, Products, AddProduct, Reports, and Cart screens
- ReceiptService PDF generation
- main.dart async seed wiring
- POS product grid and responsive layout
- Separate Cart screen + Cart FAB
- Sample products: Coffee, Tea, Donut, Croissant, Sandwich

## Known Issues
- Android NDK version mismatch warning (path_provider_android, printing, sqflite_android require NDK 27.0.12077973) — optional fix if build fails
- Windows requires Developer Mode for symlink support

## Future Enhancements
- Export receipt to external print app
- Categories for products
- Discount system
- Multi-user support
- Cloud sync
- Barcode scanner integration
