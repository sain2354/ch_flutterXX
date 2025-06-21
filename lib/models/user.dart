class UserBackendResponse {
  final int idUsuario;
  final String username;
  // Agrega más campos si tu backend los devuelve

  UserBackendResponse({
    required this.idUsuario,
    required this.username,
  });

  factory UserBackendResponse.fromJson(Map<String, dynamic> json) {
    return UserBackendResponse(
      idUsuario: json['idUsuario'] as int,
      username: json['username'] as String,
      // y otros campos
    );
  }
}
