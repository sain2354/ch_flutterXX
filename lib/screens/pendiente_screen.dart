import 'package:flutter/material.dart';

class PendienteScreen extends StatelessWidget {
  const PendienteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orden Pendiente')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pago Pendiente. Te notificaremos cuando se confirme el pago.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
              child: const Text('Volver al Inicio'),
            )
          ],
        ),
      ),
    );
  }
}
