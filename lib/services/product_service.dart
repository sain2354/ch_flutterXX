import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ApiService {
  final String baseUrl = "http://www.chbackend.somee.com/api/Producto";

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        debugPrint("Datos recibidos: ${json.encode(jsonData)}");

        final List<Product> products =
            jsonData.map((item) => Product.fromJson(item)).toList();

        debugPrint("Productos cargados correctamente: ${products.length}");
        return products;
      } else {
        debugPrint("Error al obtener productos: Código ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error en la API: $e");
      return [];
    }
  }
}
