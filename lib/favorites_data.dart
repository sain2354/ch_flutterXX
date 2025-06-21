import 'models/product.dart';

class FavoritesData {
  static final List<Product> favorites = [];

  /// Devuelve la lista de favoritos de forma inmodificable.
  static List<Product> getFavorites() => List.unmodifiable(favorites);

  /// Agrega un producto a favoritos si no existe ya.
  static void addFavorite(Product product) {
    if (!favorites.any((p) => p.id == product.id)) {
      favorites.add(product);
    }
  }

  /// Remueve un producto de la lista de favoritos.
  static void removeFavorite(Product product) {
    favorites.removeWhere((p) => p.id == product.id);
  }

  /// Verifica si un producto está marcado como favorito.
  static bool isFavorite(int productId) {
    return favorites.any((p) => p.id == productId);
  }
}
