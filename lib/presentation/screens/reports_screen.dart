import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/product_provider.dart';
import '../../data/models/payment_method.dart';
import '../../data/models/transaction.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/currency_helper.dart';
import 'receipt_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedPeriod = 'today';
  late TabController _tabController;

  late Future<double> _totalSalesFuture;
  late Future<int> _transactionCountFuture;
  late Future<Map<PaymentMethod, double>> _paymentBreakdownFuture;
  late Future<List<Transaction>> _transactionsFuture;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setPeriodToday();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadReportData(notify: false);
    }
  }

  void _setPeriodToday() {
    _startDate = DateHelper.getStartOfDay(DateTime.now());
    _endDate = DateHelper.getEndOfDay(DateTime.now());
    _selectedPeriod = 'today';
  }

  void _setPeriodMonth() {
    _startDate = DateHelper.getStartOfMonth(DateTime.now());
    _endDate = DateHelper.getEndOfMonth(DateTime.now());
    _selectedPeriod = 'month';
  }

  void _setPeriodYear() {
    _startDate = DateHelper.getStartOfYear(DateTime.now());
    _endDate = DateHelper.getEndOfYear(DateTime.now());
    _selectedPeriod = 'year';
  }

  void _loadReportData({bool notify = true}) {
    final provider = context.read<TransactionProvider>();
    _totalSalesFuture = provider.getTotalSales(_startDate, _endDate);
    _transactionCountFuture = provider.getTransactionCount(_startDate, _endDate);
    _paymentBreakdownFuture = provider.getPaymentBreakdown(_startDate, _endDate);
    _transactionsFuture = provider.getTransactionsByRange(_startDate, _endDate);
    if (notify) setState(() {});
  }

  Future<void> _voidTransaction(Transaction txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Void Transaction'),
        content: const Text('Delete this transaction and restore stock?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<TransactionProvider>().voidTransaction(txn.id!, txn.items);
      if (!mounted) return;
      
      // Reload products (stock restored) and reports
      context.read<ProductProvider>().loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction voided successfully')),
      );
      _loadReportData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Today'),
                    selected: _selectedPeriod == 'today',
                    onSelected: (selected) {
                      _setPeriodToday();
                      _loadReportData();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('This Month'),
                    selected: _selectedPeriod == 'month',
                    onSelected: (selected) {
                      _setPeriodMonth();
                      _loadReportData();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('This Year'),
                    selected: _selectedPeriod == 'year',
                    onSelected: (selected) {
                      _setPeriodYear();
                      _loadReportData();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Date range display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DateHelper.getDateRangeLabel(_startDate, _endDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'Transactions'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Summary tab
                _buildSummaryTab(),
                // Transactions tab
                _buildTransactionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _totalSalesFuture,
        _transactionCountFuture,
        _paymentBreakdownFuture,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data'));
        }

        final totalSales = snapshot.data![0] as double;
        final transactionCount = snapshot.data![1] as int;
        final paymentBreakdown = snapshot.data![2] as Map<PaymentMethod, double>;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary containers
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Sales',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyHelper.formatCurrency(totalSales),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transactions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$transactionCount transactions',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Payment method breakdown
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Methods',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (paymentBreakdown.isEmpty)
                    const Text('No transactions')
                  else
                    ...paymentBreakdown.entries.map((entry) {
                      final percentage = totalSales > 0
                          ? (entry.value / totalSales * 100).toStringAsFixed(1)
                          : '0.0';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key.displayName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: totalSales > 0 ? entry.value / totalSales : 0,
                                      minHeight: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyHelper.formatCurrency(entry.value),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  '$percentage%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    return FutureBuilder<List<Transaction>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No transactions'));
        }

        final transactions = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final txn = transactions[index];
            return _TransactionTile(transaction: txn, onVoid: () => _voidTransaction(txn));
          },
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onVoid;

  const _TransactionTile({required this.transaction, required this.onVoid});

  @override
  Widget build(BuildContext context) {
    final txn = transaction;
    final dateFormat = DateFormat('MMM dd, HH:mm');
    final itemsCount = txn.items.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptScreen.fromTransaction(txn),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date/time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(txn.date.toLocal()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '$itemsCount item${itemsCount != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              // Amount + method
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyHelper.formatCurrency(txn.total),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    txn.paymentMethod.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Void button
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: onVoid,
                tooltip: 'Void transaction',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
