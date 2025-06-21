import 'package:flutter/material.dart';
import 'product_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simplemente muestra la pantalla de productos
    return const ProductScreen();
  }
}
