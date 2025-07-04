import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Endpoints de tu API desplegada
const String ventaUrl   = 'http://www.chbackend.somee.com/api/Venta';
const String detalleUrl = 'http://www.chbackend.somee.com/api/DetalleVenta';
const String pagoUrl    = 'http://www.chbackend.somee.com/api/Pago';

class PagoService {
  /// 1) Crea la venta y devuelve el idVenta
  Future<int?> createVenta({
    required double total,
    required int idUsuario,
    required String tipoComprobante,
    required double costoEnvio,
  }) async {
    final uri = Uri.parse(ventaUrl);
    final body = {
      "idUsuario": idUsuario,
      "tipoComprobante": tipoComprobante,
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
      final resp = await http.post(
        uri,
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
        final resp = await http.post(
          uri,
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

  /// 3) Registra el pago manual con JSON puro (no sube archivo)
  Future<bool> createPayment({
    required int idVenta,
    required double montoPagado,
    required DateTime fechaPago,
    required int idMedioPago,
    required String idTransaccionMP,
    required String estadoPago,
    String comprobanteUrl = '',
  }) async {
    final uri = Uri.parse('$pagoUrl/$idVenta');
    final body = {
      "montoPagado": double.parse(montoPagado.toStringAsFixed(2)),
      "fechaPago": fechaPago.toIso8601String(),
      "idMedioPago": idMedioPago,
      "idTransaccionMP": idTransaccionMP,
      "estadoPago": estadoPago,
      "comprobanteUrl": comprobanteUrl,
    };
    debugPrint('JSON enviado (CreatePayment): ${jsonEncode(body)}');

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint('createPayment status: ${resp.statusCode}');
      debugPrint('createPayment body: ${resp.body}');
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      debugPrint('Exception en createPayment: $e');
      return false;
    }
  }

  /// 4) Sube el comprobante con multipart/form-data
  Future<bool> uploadComprobante({
    required int idVenta,
    required String filePath,
    required double montoPagado,
    required DateTime fechaPago,
    required int idMedioPago,
    required String idTransaccionMP,
    required String estadoPago,
  }) async {
    final uri = Uri.parse('$ventaUrl/$idVenta/pago');
    final request = http.MultipartRequest('POST', uri)
      ..fields['montoPagado']     = montoPagado.toStringAsFixed(2)
      ..fields['fechaPago']       = fechaPago.toIso8601String()
      ..fields['idMedioPago']     = idMedioPago.toString()
      ..fields['idTransaccionMP'] = idTransaccionMP
      ..fields['estadoPago']      = estadoPago
      ..files.add(await http.MultipartFile.fromPath(
        'comprobante',
        filePath,
        contentType: MediaType('image', 'jpeg'),
      ));

    debugPrint('Enviando MultipartRequest a $uri');

    final streamedResp = await request.send();
    final resp = await http.Response.fromStream(streamedResp);
    debugPrint('uploadComprobante status: ${resp.statusCode}');
    debugPrint('uploadComprobante body: ${resp.body}');
    return resp.statusCode == 204;
  }
}
