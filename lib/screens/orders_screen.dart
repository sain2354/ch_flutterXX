// lib/screens/orders_screen.dart

import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder para "Tus pedidos"
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus ordenes'),
      ),
      body: const Center(
        child: Text('No tienes ordenes .'),
      ),
    );
  }
}
