# Kanban

## Pending

### Task 13: POS Screen Restyle (Stitch "Products")
**Reference**: `design/stitch/1-products.png` + `1-products.html`

**Scope** (visual only; keep current behavior: add-to-cart, stock cap, settings/products/reports nav):
- Header: brand + status ticker line, product search field.
- Filter chips row (All / categories — keep only if cheap with current data, else skip).
- Product rows: name, price, stock ("15 IN STOCK" / "OUT OF STOCK" label), `[ + ]` add button (disabled at stock 0 — keep Task 11 behavior).
- Bottom: current ticket summary + `[ CART (n) ]` bar replacing the FAB.

**Files likely involved**:
- `lib/presentation/screens/pos_screen.dart`

---

### Task 14: Cart Screen Restyle (Stitch "Cart")
**Reference**: `design/stitch/2-cart.png` + `2-cart.html`

**Scope** (keep quantity cap, remove item, totals math):
- "CURRENT ORDER TICKET" header with ticket meta line.
- Item rows: index (`01/`), name, price, qty stepper `[ - ] n [ + ]`, `[ REMOVE ITEM ]` (keep stock cap on `+`).
- Totals block: items count, subtotal, tax line, discount (only if already supported — no new fields), total.
- `[ PROCEED / RP ... ]` full-width bottom action (replaces current checkout button).

**Files likely involved**:
- `lib/presentation/screens/cart_screen.dart`

---

### Task 15: Payment Screen Restyle (Stitch "Payment")
**Reference**: `design/stitch/3-payment.png` + `3-payment.html`

**Scope** (keep Task 10 logic: amountDue = total - discount, change calc, validation, stored total):
- Order checkout header with ticker meta (ticket id, table label = static meta line ok).
- Summary: cart total, discount, `TOTAL DUE` (bold receipt block).
- Payment method: two selectable cards `[ CASH ]` / `[ QRIS ]` (map to existing `PaymentMethod` values; dropdown stays under the hood or gets replaced by cards).
- Cash received field + quick tender presets `[ EXACT ] [ +50K ] [ +100K ]` (functional: fill nominal).
- Change due block (`KEMBALIAN`).
- `[ COMPLETE & PRINT RECEIPT ]` bottom action.

**Files likely involved**:
- `lib/presentation/screens/payment_screen.dart`

---

### Task 16: Receipt Screen Restyle (Stitch "Receipt")
**Reference**: `design/stitch/4-receipt.png` + `4-receipt.html`

**Scope** (keep Task 5 export PNG + read-only from-reports mode + Task 6 brand name):
- `RECEIPT PRINT PREVIEW` header + `[ PAYMENT COMMITTED ]` badge.
- Receipt paper block: store name/address lines, date + ticket no, item rows (qty x price, line total), subtotal/discount/total, payment method/change, footer thank-you text.
- Barcode placeholder strip (decorative, no new scanning feature).
- `[ PRINT/PNG ]` + `[ NEW ORDER ]` actions (keep existing export + back logic).

**Files likely involved**:
- `lib/presentation/screens/receipt_screen.dart`

---

### Task 17 (optional): Bottom Nav Bar `[MENU] [CART] [LOG] [SETUP]`
**Scope**:
- Replace AppBar icon navigation with a fixed bottom bar matching the mockups (POS = menu, Cart, Reports = log, Settings = setup). Cart shows count badge.
- Only after Tasks 13-16 land. Skip if current navigation proves sufficient.

**Files likely involved**:
- `lib/presentation/screens/pos_screen.dart` (or a small shell widget)

---

## Completed

### Task 12: Stitch Design Tokens + Shared Terminal UI ✓
**Completed**: 2026-10-13

**Scope**:
- Design references downloaded to `design/stitch/` (4 PNG + 4 HTML, "Receipt POS System" / Kopisop JOS).
- Adopted **Stitch monochrome** style (black/white/gray, Space Mono look), replacing white/green for the POS flow screens. Font: **system monospace** (no new dependency).
- Extracted design tokens from `design/stitch/*.html` Tailwind config into `lib/core/theme/app_theme.dart`.
- Small shared widgets only where reused across screens. No design system, no abstractions beyond that.
- `UI_DESIGN.md` note recording the monochrome decision.

**Changes Made**:
- `app_theme.dart` rewritten: surface `#f9f9f9`, primary `#000000`, on-surface `#1a1c1c`, outline `#7e7576`, error `#ba1a1a`, spacing (4/8/16/24/40), radius (4/8/12), mono text styles with label letterSpacing. Legacy color aliases kept so existing screens compile.
- Shared widgets in `lib/core/widgets/`: `BracketButton`, `OutlineBracketButton`, `TerminalLabel`, `DashedDivider`.
- `UI_DESIGN.md`: monochrome decision note added (supersedes white/green for POS flow screens).

**Files Modified**:
- `lib/core/theme/app_theme.dart`
- `UI_DESIGN.md`

**Files Created**:
- `design/stitch/` (4 PNG + 4 HTML references)
- `lib/core/widgets/bracket_button.dart`
- `lib/core/widgets/terminal_label.dart`
- `lib/core/widgets/dashed_divider.dart`

**Verified**: `flutter analyze` clean (1 pre-existing info in `reports_screen.dart`). `flutter test` fails only on the stale default counter smoke test (`test/widget_test.dart`) — pre-existing, unrelated.

### Task 11: Cap Cart Quantity at Stock (Block Out-of-Stock Add) ✓
**Completed**: 2026-10-07

**Changes Made**:
- POS list: `+` button disabled + "Out of stock" red label when `stock == 0` (product stays visible)
- `CartProvider.addToCart` / `updateQuantity`: quantity capped at `product.stock`
- Cart screen: `+` button disabled when `item.quantity >= item.product.stock`
- `PaymentScreen`: reload `ProductProvider` after successful sale (stock decremented)
- `ReportsScreen`: reload `ProductProvider` after void (stock restored)
- Reason for reloads: `POSScreen.initState` runs once; stock went stale after sale/void

**Files Modified**:
- `lib/presentation/screens/pos_screen.dart`
- `lib/presentation/providers/cart_provider.dart`
- `lib/presentation/screens/cart_screen.dart`
- `lib/presentation/screens/payment_screen.dart`
- `lib/presentation/screens/reports_screen.dart`

### Task 9: Stock Management + Void Transaction ✓
**Completed**: 2026-10-07

**Scope**:
- Decrement product stock on `completeSale`.
- Add `ProductRepository.updateStock(productId, delta)`.
- Reports transaction tile: delete/void action with confirm.
- Void restores stock (+quantity per item), then deletes transaction.
- No other stock UI changes.

**Files likely involved**:
- `lib/data/repositories/product_repository_impl.dart`
- `lib/presentation/providers/transaction_provider.dart`
- `lib/presentation/screens/reports_screen.dart`

---

## Completed

### Task 10: Cash Change Calculation + Payment Method Dropdown ✓
**Completed**: 2026-10-07

**Problem**:
- Amount Payable showed Rp 0 until user entered cash amount
- No change (kembalian) calculation for cash payments
- Payment method selector took too much space (4 radio tiles)
- Stored transaction total was incorrect (saved cash received instead of actual sale amount)

**Changes Made**:
- Fixed amount math: `Amount Payable = total - discount` (always visible, never Rp 0)
- Added change calculation: `Change = cash received - amount payable` (Cash only, when overpaid)
- Replaced 4 RadioListTiles with compact DropdownButtonFormField
- Cash Received field now only shows for Cash payment method
- "Use Total" button renamed to "Exact" and now fills discount-adjusted amount
- Fixed stored transaction total: now saves `amountDue` instead of `nominal - discount`
- Validation: Cash requires nominal ≥ amountDue; other methods skip nominal validation
- Button text changed to "Complete Payment"

**Files Modified**:
- `lib/presentation/screens/payment_screen.dart`

### Task 8: Fix Empty Reports After Transaction ✓
**Completed**: 2026-10-07

**Root Cause**:
- Database schema mismatch: `Transaction.toMap()` includes `discount_percent` column, but `_onCreate` was missing it.
- Any database created fresh at version 3 lacked the `discount_percent` column.
- `completeSale` insert would fail silently, transaction never saved.

**Changes Made**:
- Added `discount_percent REAL DEFAULT 0` to transactions table in `_onCreate`.
- Bumped database version from 3 to 4.
- Added defensive migration in `_onUpgrade` that checks and adds column if missing (repairs v3 DBs).
- Made `completeSale` rethrow errors so PaymentScreen's existing error SnackBar displays failures.

**Files Modified**:
- `lib/core/constants/app_constants.dart` (databaseVersion = 4)
- `lib/data/data_sources/local/database_service.dart` (_onCreate, _onUpgrade)
- `lib/presentation/providers/transaction_provider.dart` (rethrow on error)

### Task 7: Display Name "Si Paling POS" ✓

### Task 7: Display Name "Si Paling POS" ✓
**Completed**: 2026-10-06

**Changes Made**:
- Updated app display name from "Flutter POS" to "Si Paling POS"
- Package name `flutter_pos` kept unchanged (no import changes)
- Platform-specific display names updated

**Files Modified**:
- `lib/core/constants/app_constants.dart` — appName = 'Si Paling POS'
- `android/app/src/main/AndroidManifest.xml` — android:label
- `ios/Runner/Info.plist` — CFBundleDisplayName
- `macos/Runner/Configs/AppInfo.xcconfig` — PRODUCT_NAME
- `windows/runner/main.cpp` — window title
- `windows/runner/Runner.rc` — FileDescription, ProductName
- `web/index.html` — <title>, apple-mobile-web-app-title
- `web/manifest.json` — name, short_name

**Files NOT Modified**:
- `pubspec.yaml` name (package ID stays flutter_pos)
- Bundle IDs / applicationId

### Task 6: Settings Page - Brand Name Configuration ✓
**Completed**: 2026-10-06

**Changes Made**:
- Created `SettingsProvider` with `shared_preferences` persistence (brand name, default "My Store")
- Created `SettingsScreen` with brand name input, save/cancel buttons
- ReceiptScreen: removed `storeName` param, reads brand via `context.watch<SettingsProvider>().brandName`
- POS AppBar: added gear icon → navigate to `SettingsScreen`
- main.dart: load settings on startup, pass `SettingsProvider` to `MyApp`
- pubspec.yaml: added `shared_preferences: ^2.2.0`

**Files Created**:
- `lib/presentation/providers/settings_provider.dart`
- `lib/presentation/screens/settings_screen.dart`

**Files Modified**:
- `lib/presentation/screens/receipt_screen.dart` (provider import, watch brandName)
- `lib/presentation/screens/pos_screen.dart` (settings nav icon, load on init)
- `lib/main.dart` (settingsProvider param, async load)
- `test/widget_test.dart` (settingsProvider param)
- `pubspec.yaml` (shared_preferences)

### Task 5: Export Receipt as PNG for Printing (Black & White) ✓
**Completed**: 2026-10-06

**Changes Made**:
- ReceiptScreen converted to StatefulWidget with `GlobalKey`/`RepaintBoundary`
- Printable receipt wrapped in white Container with black text styles
- `_exportReceipt()` captures via `toImage(pixelRatio: 3.0)`, resizes to 576px, grayscale via `image` package
- Export PNG + Done footer buttons added
- Dependencies: `share_plus: ^10.1.4`, `image: ^4.2.0`

**Files Modified**:
- `lib/presentation/screens/receipt_screen.dart` (StatefulWidget, export logic)
- `pubspec.yaml` (share_plus, image)

### Task 4: Transaction Receipt View in Reports ✓
**Completed**: 2026-10-03

**Changes Made**:
- ReportsScreen: removed custom date picker UI (kept today/month/year chips only)
- `_TransactionTile`: added `InkWell` tap handler → navigate to `ReceiptScreen.fromTransaction(txn)`
- ReceiptScreen: added `date` and `storeName` optional fields
- ReceiptScreen: added factory constructor `ReceiptScreen.fromTransaction(Transaction txn)` for read-only mode
- ReceiptScreen: back button logic → if `date != null` (from reports) `pop()`, else `popUntil isFirst` (from checkout)
- Transaction items rendered via `_CartItemFromTransaction` adapter wrapping `Product` stub
- Back button returns to reports transaction tab on read-only receipt

**Files Modified**:
- `lib/presentation/screens/reports_screen.dart` (removed custom picker, added tap navigation)
- `lib/presentation/screens/receipt_screen.dart` (added transaction read-only mode, import Product)

### Task 1: Base Price for Products ✓
**Completed**: 2026-10-02

**Changes Made**:
- Product model: added `basePrice`, `sellPrice` fields
- DB migration v1→v2: added `base_price`, `sell_price` columns, migrated existing price data (30% margin)
- AddProductScreen: two inputs with validation (sell price ≥ base price)
- Updated all screens to use `sellPrice`: POS, Products, Cart, Receipt
- Updated seed data with base/sell prices
- TransactionItem stores `sellPrice` as `unitPrice`

**Files Modified**:
- `lib/data/models/product.dart`
- `lib/data/models/cart_item.dart`
- `lib/data/models/transaction.dart`
- `lib/data/data_sources/local/database_service.dart`
- `lib/presentation/screens/add_product_screen.dart`
- `lib/presentation/screens/pos_screen.dart`
- `lib/presentation/screens/products_screen.dart`
- `lib/presentation/screens/cart_screen.dart`

### Task 2: Daily Transaction History in Reports ✓
**Completed**: 2026-10-02

**Changes Made**:
- ReportsScreen: added TabBar with Summary + Transactions tabs
- Transaction list: shows date, time, total, payment method, item count
- Expandable ExpansionTile per transaction showing all cart items with qty × price
- Fixed repository `getByDateRange` and `getAll` to load transaction items
- Period filters (today/month/year/custom) apply to both tabs

**Files Modified**:
- `lib/presentation/screens/reports_screen.dart` (added TabController, _TransactionTile widget)
- `lib/data/repositories/transaction_repository_impl.dart` (load items in queries)

---

## How to Use This Kanban
- Work on one task at a time.
- Keep the current task focused.
- Avoid adding unrelated improvements.
- Move completed work out of Pending when appropriate, but preserve the task description/history.
