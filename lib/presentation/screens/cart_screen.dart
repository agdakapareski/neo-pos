import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/widgets/bracket_button.dart';
import '../../core/widgets/dashed_divider.dart';
import '../../core/widgets/terminal_label.dart';
import '../../data/models/cart_item.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: cart.items.isEmpty
                      ? const Center(
                          child: TerminalLabel('Cart is empty', muted: true),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.gutter,
                            AppTheme.spaceSm,
                            AppTheme.gutter,
                            AppTheme.spaceLg,
                          ),
                          itemCount: cart.items.length,
                          separatorBuilder: (context, index) =>
                              const DashedDivider(),
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            return _CartItemRow(index: index, item: item);
                          },
                        ),
                ),
                if (cart.items.isNotEmpty) _buildTotals(context, cart),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final meta = DateFormat('EEE, dd MMM yyyy · HH:mm').format(now);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceSm,
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
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 20),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: TerminalLabel(
                  'Current Order Ticket',
                  style: AppTheme.headlineSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Padding(
            padding: const EdgeInsets.only(left: AppTheme.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: TerminalLabel(
                        'New Order',
                        style: AppTheme.labelSm,
                        color: AppTheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: TerminalLabel(
                        meta,
                        style: AppTheme.labelSm,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceXs),
                TerminalLabel(
                  'Cart ref / items',
                  style: AppTheme.labelSm,
                  color: AppTheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context, CartProvider cart) {
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
          _totalsRow('Items count', '${cart.itemCount} units'),
          _totalsRow('Subtotal', CurrencyHelper.formatCurrency(cart.total)),
          _totalsRow('Tax (11% incl.)', 'Incl.'),
          const SizedBox(height: AppTheme.spaceXs),
          const DashedDivider(),
          const SizedBox(height: AppTheme.spaceXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TerminalLabel('Total due', style: AppTheme.labelLg),
              TerminalLabel(
                CurrencyHelper.formatCurrency(cart.total),
                style: AppTheme.labelLg,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          BracketButton(
            label: 'PROCEED / ${CurrencyHelper.formatCurrency(cart.total)}',
            expand: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(
                    total: cart.total,
                    items: cart.items,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _totalsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TerminalLabel(
            label,
            style: AppTheme.labelSm,
            color: AppTheme.onSurfaceVariant,
          ),
          TerminalLabel(
            value,
            style: AppTheme.bodySm,
            color: AppTheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.index, required this.item});

  final int index;
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final bool atStockCap = item.quantity >= item.product.stock;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TerminalLabel(
                '${(index + 1).toString().padLeft(2, '0')}/',
                style: AppTheme.labelMd,
                color: AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: TerminalLabel(item.product.name, style: AppTheme.labelLg),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              TerminalLabel(
                CurrencyHelper.formatCurrency(item.subtotal),
                style: AppTheme.bodyMd,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              OutlineBracketButton(
                label: '-',
                onPressed: () => cart.updateQuantity(
                  item.product.id!,
                  item.quantity - 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceSm,
                ),
                child: Text('${item.quantity}', style: AppTheme.headlineSm),
              ),
              OutlineBracketButton(
                label: '+',
                onPressed: atStockCap
                    ? null
                    : () => cart.updateQuantity(
                          item.product.id!,
                          item.quantity + 1,
                        ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              OutlineBracketButton(
                label: 'Remove item',
                onPressed: () => cart.removeFromCart(item.product.id!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
