import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderCreatedScreen extends StatefulWidget {
  const OrderCreatedScreen({Key? key}) : super(key: key);

  @override
  State<OrderCreatedScreen> createState() => _OrderCreatedScreenState();
}

class _OrderCreatedScreenState extends State<OrderCreatedScreen> {
  bool isLoading = true;
  String? estadoPago;
  String errorMessage = "";
  int? idVenta;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se espera que se pase el idVenta como argumento al navegar a esta pantalla
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      idVenta = args;
      _fetchVentaStatus();
    } else {
      setState(() {
        errorMessage = "No se recibió el idVenta.";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchVentaStatus() async {
    // Reemplaza con la URL de tu backend
    final url = Uri.parse('https://tu-backend.com/api/Venta/$idVenta');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Se asume que el JSON tiene un campo "estadoPago"
          estadoPago = data['estadoPago'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const CircularProgressIndicator();
    } else if (errorMessage.isNotEmpty) {
      return Text(errorMessage, style: const TextStyle(color: Colors.red));
    } else {
      // Mostrar mensaje según estadoPago
      String message;
      if (estadoPago == "Pagado") {
        message = "¡Pago Aprobado! Tu orden ha sido procesada correctamente.";
      } else if (estadoPago == "Rechazado") {
        message =
            "Pago Rechazado. Por favor, intenta nuevamente o contacta soporte.";
      } else if (estadoPago == "Pendiente") {
        message =
            "Pago Pendiente. Te notificaremos cuando se confirme el pago.";
      } else {
        message = "Estado desconocido: $estadoPago";
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Regresar a la pantalla principal
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
            child: const Text('Volver al Inicio'),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de la Orden'),
      ),
      body: Center(child: _buildContent()),
    );
  }
}
