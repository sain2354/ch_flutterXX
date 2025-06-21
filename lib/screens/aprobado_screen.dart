import 'package:flutter/material.dart';

class AprobadoScreen extends StatelessWidget {
  const AprobadoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago Aprobado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Pago Aprobado! Tu orden ha sido procesada correctamente.',
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
