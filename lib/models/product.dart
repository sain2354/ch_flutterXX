class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String imageUrl;
  final int category;
  final String brand;
  final List<String> sizes; // Tallas disponibles

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
    required this.brand,
    this.sizes = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Suponemos que en tu JSON viene un campo "tallas" como array de strings.
    final List<dynamic> tallasData = json['tallas'] ?? [];
    final List<String> parsedTallas = tallasData
        .map((t) => t.toString()) // Convertir cada elemento a string
        .toList();

    return Product(
      // Convierte idProducto a int (si viene double o int o null)
      id: (json['idProducto'] as num?)?.toInt() ?? 0,

      // Si "nombre" es null, usa "Producto sin nombre"
      name: json['nombre']?.toString() ?? 'Producto sin nombre',

      // Convierte precioVenta a double (si viene int o double o null)
      price: (json['precioVenta'] as num?)?.toDouble() ?? 0.0,

      // Convierte stock a int (si viene int o double o null)
      stock: (json['stock'] as num?)?.toInt() ?? 0,

      // Si "foto" es null, usa un placeholder
      imageUrl: json['foto']?.toString() ?? 'https://via.placeholder.com/150',

      // Convierte idCategoria a int
      category: (json['idCategoria'] as num?)?.toInt() ?? 0,

      // Si "marca" es null, usa "Sin marca"
      brand: json['marca']?.toString() ?? 'Sin marca',

      // Asignamos las tallas parseadas
      sizes: parsedTallas,
    );
  }
}
