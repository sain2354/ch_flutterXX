import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart'; // tu modelo con idUsuario

class UserService {
  final String baseUrl; // Ej: 'http://www.chbackend.somee.com/api/usuarios'

  UserService({required this.baseUrl});

  Future<UserBackendResponse> syncUser({
    required String username,
    required String password,
    required String nombreCompleto,
    required String email,
    required String telefono,
  }) async {
    final url = Uri.parse('$baseUrl/sync');

    final body = {
      "username": username,
      "password": password,
      "nombreCompleto": nombreCompleto,
      "email": email,
      "telefono": telefono,
    };

    print('[syncUser] POST $url body=$body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Tu backend debe retornar un JSON con idUsuario
      final Map<String, dynamic> data = jsonDecode(response.body);
      return UserBackendResponse.fromJson(data);
    } else {
      throw Exception('Error al sincronizar usuario: ${response.body}');
    }
  }
}
