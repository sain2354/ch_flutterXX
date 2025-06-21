class Address {
  final int? id; // Opcional, puede venir asignado por el backend.
  final int userId; // Corresponde a "idUsuario"
  final String direccion;
  final String? referencia;
  final double? lat; // Usaremos "lat"
  final double? lng; // Usaremos "lng"

  Address({
    this.id,
    required this.userId,
    required this.direccion,
    this.referencia,
    this.lat,
    this.lng,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int?, // Si el backend lo devuelve como "id" o similar.
      userId: json['idUsuario'] as int,
      direccion: json['direccion'] as String,
      referencia: json['referencia'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idUsuario": userId,
      "direccion": direccion,
      "lat": lat,
      "lng": lng,
      "referencia": referencia,
    };
  }
}
