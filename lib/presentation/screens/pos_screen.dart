import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/widgets/bracket_button.dart';
import '../../core/widgets/dashed_divider.dart';
import '../../core/widgets/terminal_label.dart';
import 'cart_screen.dart';
import 'products_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            if (productProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${productProvider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => productProvider.loadProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final products = productProvider.products;
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No products available'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProductsScreen()),
                        );
                      },
                      child: const Text('Add Products'),
                    ),
                  ],
                ),
              );
            }

            final normalizedQuery = _query.trim().toLowerCase();
            final visibleProducts = normalizedQuery.isEmpty
                ? products
                : products
                    .where((p) => p.name.toLowerCase().contains(normalizedQuery))
                    .toList();

            return Column(
              children: [
                _buildHeader(context, productProvider, visibleProducts.length),
                Expanded(
                  child: visibleProducts.isEmpty
                      ? Center(
                          child: TerminalLabel(
                            'No products match "$_query"',
                            muted: true,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.gutter,
                            AppTheme.spaceSm,
                            AppTheme.gutter,
                            AppTheme.spaceLg,
                          ),
                          itemCount: visibleProducts.length,
                          separatorBuilder: (context, index) =>
                              const DashedDivider(),
                          itemBuilder: (context, index) {
                            final product = visibleProducts[index];
                            return _ProductRow(product: product);
                          },
                        ),
                ),
                _buildCartBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Widget _buildHeader(BuildContext context, ProductProvider productProvider,
      int visibleCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.gutter,
        AppTheme.spaceSm,
        AppTheme.gutter,
        AppTheme.spaceMd,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppTheme.onSurface, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status ticker line.
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.onSurface,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              TerminalLabel('Online / Sync / Shift A', style: AppTheme.labelSm),
              const Spacer(),
              TerminalLabel(
                'Ready',
                style: AppTheme.labelSm,
                color: AppTheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Row(
            children: [
              Expanded(
                child: TerminalLabel(
                  context.watch<SettingsProvider>().brandName,
                  style: AppTheme.headlineSm,
                ),
              ),
              _navIcon(
                Icons.shopping_bag,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductsScreen()),
                ),
              ),
              _navIcon(
                Icons.assessment,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportsScreen()),
                ),
              ),
              _navIcon(
                Icons.settings,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          // Search field.
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            style: AppTheme.bodyMd,
            decoration: const InputDecoration(
              hintText: 'SEARCH PRODUCTS ...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              TerminalLabel(
                'All',
                style: AppTheme.labelSm,
                color: AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              TerminalLabel(
                'Products / ${productProvider.products.length} sku',
                style: AppTheme.labelSm,
                color: AppTheme.onSurfaceVariant,
              ),
              const Spacer(),
              TerminalLabel(
                '$visibleCount shown',
                style: AppTheme.labelSm,
                color: AppTheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartBar(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.gutter,
            AppTheme.spaceSm,
            AppTheme.gutter,
            AppTheme.spaceSm,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            border: Border(
              top: BorderSide(color: AppTheme.onSurface, width: 2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TerminalLabel(
                      'Current ticket draft',
                      style: AppTheme.labelSm,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  TerminalLabel(
                    'Items: ${cart.itemCount} units',
                    style: AppTheme.labelSm,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceXs),
              BracketButton(
                label:
                    'CART (${cart.itemCount})  ${CurrencyHelper.formatCurrency(cart.total)} >>',
                expand: true,
                onPressed: cart.items.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()),
                        );
                      },
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TerminalLabel(
                    'Press to emit bill',
                    style: AppTheme.labelSm,
                    color: AppTheme.onSurfaceVariant,
                  ),
                  TerminalLabel(
                    'Printer ready [ok]',
                    style: AppTheme.labelSm,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final bool isOutOfStock = p.stock == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.square, size: 18, color: AppTheme.onSurface),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TerminalLabel(p.name, style: AppTheme.headlineSm),
                const SizedBox(height: AppTheme.spaceXs),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: CurrencyHelper.formatCurrency(p.sellPrice),
                        style: AppTheme.bodySm.copyWith(
                          color: AppTheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: isOutOfStock
                            ? '   ·   OUT OF STOCK'
                            : '   ·   ${p.stock}',
                        style: AppTheme.labelSm.copyWith(
                          color:
                              isOutOfStock ? AppTheme.error : AppTheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          SizedBox(
            width: 72,
            height: 48,
            child: Center(
              child: OutlineBracketButton(
                label: '+',
                onPressed: isOutOfStock
                    ? null
                    : () => context.read<CartProvider>().addToCart(p),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
