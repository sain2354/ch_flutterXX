import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';

class CartService {
  final String baseUrl = 'http://www.chbackend.somee.com/api/Carrito';

  /// Obtiene el carrito del usuario si ya existe.
  Future<Map<String, dynamic>?> getCartForUser(int userId) async {
    final url = Uri.parse('$baseUrl/$userId');
    final headers = {'Content-Type': 'application/json'};
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
          "CartService.getCartForUser: Error al obtener el carrito. Respuesta: ${response.body}");
    }
  }

  /// Crea un carrito para el usuario solo si no tiene uno.
  Future<void> createCartForUser(int userId) async {
    final existingCart = await getCartForUser(userId);

    if (existingCart != null) {
      print(
          "CartService.createCartForUser: El usuario $userId ya tiene un carrito.");
      return; // No creamos otro carrito si ya existe
    }

    final url = Uri.parse(baseUrl);
    final body = json.encode({
      "idUsuario": userId,
      "fechaCreacion": DateTime.now().toIso8601String(),
    });
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          "CartService.createCartForUser: No se pudo crear el carrito. Respuesta: ${response.body}");
    }

    print(
        "CartService.createCartForUser: Carrito creado para el usuario $userId.");
  }

  /// Agrega un ítem al carrito del usuario.
  Future<void> addItemToCartDetail(int userId, CartItem item) async {
    final url = Uri.parse('$baseUrl/detalle');
    final body = json.encode({
      "idUsuario": userId,
      "idProducto": item.id,
      "cantidad": item.quantity,
      "selectedSize": item.selectedSize,
    });
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          "CartService.addItemToCartDetail: Error al agregar el ítem. Respuesta: ${response.body}");
    }

    print(
        "CartService.addItemToCartDetail: Ítem ${item.id} agregado para el usuario $userId.");
  }
}
