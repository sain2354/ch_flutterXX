import 'package:flutter/material.dart';

class RechazadoScreen extends StatelessWidget {
  const RechazadoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago Rechazado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pago Rechazado. Por favor, intenta nuevamente o contacta soporte.',
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
