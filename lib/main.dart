import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/data_sources/local/database_service.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/pos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.seedSampleProducts();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();
  runApp(MyApp(settingsProvider: settingsProvider));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const MyApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider(create: (_) => ProductRepositoryImpl()),
        Provider(create: (_) => TransactionRepositoryImpl()),

        // Providers
        ChangeNotifierProvider(
          create: (context) => ProductProvider(
            context.read<ProductRepositoryImpl>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
            context.read<TransactionRepositoryImpl>(),
            context.read<ProductRepositoryImpl>(),
          ),
        ),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const POSScreen(),
      ),
    );
  }
}
