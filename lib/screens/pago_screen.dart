import 'package:flutter/material.dart';

class PagoScreen extends StatefulWidget {
  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Aquí puedes implementar tu lógica de pago alternativa
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Funcionalidad de pago deshabilitada.')),
            );
          },
          child: Text('Realizar Pago'),
        ),
      ),
    );
  }
}