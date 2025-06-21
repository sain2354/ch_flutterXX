class CartItem {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  final List<String> availableSizes;
  String selectedSize;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.availableSizes = const [],
    this.selectedSize = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'availableSizes': availableSizes,
      'selectedSize': selectedSize,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      quantity: json['quantity'] ?? 1,
      availableSizes: List<String>.from(json['availableSizes'] ?? []),
      selectedSize: json['selectedSize'] ?? '',
    );
  }
}
