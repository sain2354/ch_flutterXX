import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderStatusController extends StatefulWidget {
  final int idVenta;
  const OrderStatusController({Key? key, required this.idVenta})
      : super(key: key);

  @override
  _OrderStatusControllerState createState() => _OrderStatusControllerState();
}

class _OrderStatusControllerState extends State<OrderStatusController> {
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchVentaStatus();
  }

  Future<void> _fetchVentaStatus() async {
    final url =
        Uri.parse('http://www.chbackend.somee.com/api/Venta/${widget.idVenta}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final estadoPago = data['estadoPago'];
        if (estadoPago == 'Pagado') {
          Navigator.pushReplacementNamed(context, '/aprobado');
        } else if (estadoPago == 'Rechazado') {
          Navigator.pushReplacementNamed(context, '/rechazado');
        } else if (estadoPago == 'Pendiente') {
          Navigator.pushReplacementNamed(context, '/pendiente');
        } else {
          setState(() {
            errorMessage = 'Estado desconocido: $estadoPago';
            isLoading = false;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estado de la Orden')),
        body: Center(
            child:
                Text(errorMessage, style: const TextStyle(color: Colors.red))),
      );
    }
    return const SizedBox.shrink();
  }
}
