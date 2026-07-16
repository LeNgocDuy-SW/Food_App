import 'package:flutter/material.dart';
import 'package:food_app/features/food_catalog/presentation/widgets/taskbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:food_app/features/cart/data/cart_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartManager())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskBarWidget(),
    );
  }
}
