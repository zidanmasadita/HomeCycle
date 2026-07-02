import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'data/remote/supabase_service.dart';
import 'features/category/repository/category_repository.dart';
import 'features/category/provider/category_provider.dart';
import 'features/inventory/repository/inventory_repository.dart';
import 'features/inventory/provider/inventory_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SupabaseService.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('id'),
      child: const HomeCycleApp(),
    ),
  );
}

class HomeCycleApp extends StatelessWidget {
  const HomeCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              CategoryProvider(CategoryRepository())..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(InventoryRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'HomeCycle',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const Placeholder(),
      ),
    );
  }
}
