import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Endpoints de tu API desplegada
const String ventaUrl   = 'http://www.chbackend.somee.com/api/Venta';
const String detalleUrl = 'http://www.chbackend.somee.com/api/DetalleVenta';
const String pagoUrl    = 'http://www.chbackend.somee.com/api/Pago';

class PreferenceResult {
  final String preferenceId;
  final String initPoint;
  PreferenceResult({ required this.preferenceId, required this.initPoint });
}

class PaymentService {
  /// 1) Crea la venta y devuelve el idVenta
  Future<int?> createVenta({
    required double total,
    required int idUsuario,
    required String comprobante,
    required double costoEnvio,
  }) async {
    final uri = Uri.parse(ventaUrl);
    final body = {
      "idUsuario": idUsuario,
      "tipoComprobante": comprobante,
      "fecha": DateTime.now().toIso8601String(),
      "total": double.parse(total.toStringAsFixed(2)),
      "estado": "Pendiente",
      "serie": null,
      "numeroComprobante": null,
      "totalIgv": 0,
      "costo_envio": double.parse(costoEnvio.toStringAsFixed(2)),
    };
    debugPrint('JSON enviado (Venta): ${jsonEncode(body)}');
    try {
      final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint('createVenta status: ${resp.statusCode}');
      debugPrint('createVenta body: ${resp.body}');
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return jsonDecode(resp.body)["idVenta"] as int;
      }
    } catch (e) {
      debugPrint('Exception en createVenta: $e');
    }
    return null;
  }

  /// 2) Agrega los detalles de la venta
  Future<bool> agregarDetallesVenta(int idVenta, List<dynamic> items) async {
    final uri = Uri.parse(detalleUrl);
    for (var item in items) {
      final detalle = {
        "IdVenta": idVenta,
        "IdProducto": item.id,
        "Cantidad": item.quantity.toDouble(),
        "Precio": double.parse(item.price.toStringAsFixed(2)),
        "Descuento": 0,
        "Total": double.parse((item.quantity * item.price).toStringAsFixed(2)),
        "IdUnidadMedida": null,
        "Igv": 0,
      };
      debugPrint('JSON enviado (DetalleVenta): ${jsonEncode(detalle)}');
      try {
        final resp = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(detalle),
        );
        debugPrint('detalle status: ${resp.statusCode}');
        if (resp.statusCode != 200 && resp.statusCode != 201) {
          debugPrint('detalle body: ${resp.body}');
          return false;
        }
      } catch (e) {
        debugPrint('Exception en agregarDetalle: $e');
        return false;
      }
    }
    return true;
  }

  /// 4) Registra el pago manual con comprobante (ID de transacción)
  Future<bool> createPayment({
    required int idVenta,
    required String comprobanteManual,
  }) async {
    final uri = Uri.parse(pagoUrl);
    final body = {
      "idVenta": idVenta,
      "montoPagado": null,
      "idMedioPago": null,
      "estadoPago": "Pendiente",
      "idTransaccionMP": comprobanteManual,
    };
    debugPrint('JSON enviado (CreatePayment): ${jsonEncode(body)}');
    try {
      final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint('createPayment status: ${resp.statusCode}');
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      debugPrint('Exception en createPayment: $e');
      return false;
    }
  }
}
