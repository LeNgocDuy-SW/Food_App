import 'package:flutter/material.dart';
import 'package:food_app/features/food_catalog/presentation/widgets/taskbar_widget.dart';

void main() {
  runApp(const MyApp());
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
