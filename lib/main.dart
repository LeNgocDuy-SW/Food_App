import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_app/features/cart/data/cart_manager.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/injection_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => getIt<CartManager>())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
