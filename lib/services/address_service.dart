import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address.dart';

class AddressService {
  final String
      baseUrl; // Ej: 'http://www.chbackend.somee.com/api/UsuarioDireccion'

  AddressService({required this.baseUrl});

  /// Obtiene todas las direcciones del usuario.
  /// Se espera que el endpoint sea: GET /usuario/{userId}
  Future<List<Address>> fetchAddresses(int userId) async {
    final url = Uri.parse('$baseUrl/usuario/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Address.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener direcciones: ${response.body}');
    }
  }

  /// Crea una nueva dirección.
  /// Se espera que el endpoint para crear sea: POST / (a la URL base)
  Future<Address> createAddress(Address address) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(address.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Address.fromJson(data);
    } else {
      throw Exception('Error al crear dirección: ${response.body}');
    }
  }
}
