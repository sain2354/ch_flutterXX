import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../favorites_data.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Lista de categorías iguales a las que tienes en ProductScreen
  final List<String> categories = ['Todos', 'Hombres', 'Mujeres', 'Infantil'];

  // Controladores de estado
  String selectedCategory = 'Todos';
  final TextEditingController searchController = TextEditingController();

  // Listas internas
  List<Product> favoriteProducts = [];
  List<Product> filteredFavorites = [];

  @override
  void initState() {
    super.initState();
    // Carga inicial
    loadFavorites();
    // Cada vez que cambie el texto en el buscador, filtramos
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  /// Carga todos los favoritos desde FavoritesData y aplica filtros
  void loadFavorites() {
    setState(() {
      favoriteProducts = FavoritesData.getFavorites();
      _applyFilters();
    });
  }

  /// Se llama cuando cambia el texto del buscador
  void _onSearchChanged() {
    _applyFilters();
  }

  /// Obtiene el nombre de la categoría a partir de su ID (igual que en ProductScreen)
  String getCategoryName(int catId) {
    switch (catId) {
      case 1:
        return 'Hombres';
      case 2:
        return 'Mujeres';
      case 3:
        return 'Infantil';
      default:
        return 'Otros';
    }
  }

  /// Aplica filtros de categoría y búsqueda sobre la lista completa de favoritos
  void _applyFilters() {
    final query = searchController.text.toLowerCase();
    List<Product> temp = [];

    for (var prod in favoriteProducts) {
      final catName = getCategoryName(prod.category);
      final matchesCategory =
          (selectedCategory == 'Todos') || (catName == selectedCategory);

      final matchesSearch =
          prod.name.toLowerCase().contains(query);

      if (matchesCategory && matchesSearch) {
        temp.add(prod);
      }
    }

    setState(() {
      filteredFavorites = temp;
    });
  }

  /// Muestra un diálogo de confirmación antes de quitar un producto de favoritos
  void _confirmRemoveFavorite(Product product) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar de favoritos'),
          content: const Text('¿Quieres eliminar este producto de tus favoritos?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Cerrar diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FavoritesData.removeFavorite(product);
                loadFavorites(); // Volver a cargar lista
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} eliminado de favoritos'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      // AppBar sólo con fondo rojo y botón de retroceso
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),

      body: Column(
        children: [
          // 1) Barra de búsqueda + categorías (igual que en ProductScreen, debajo del AppBar)
          Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              children: [
                // Campo de búsqueda (filtra solo dentro de Favoritos)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Buscar en favoritos...',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Row de categorías. Al hacer tap, navegamos a /home con argumento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: categories.map((cat) {
                    final isSelected = (selectedCategory == cat);
                    return GestureDetector(
                      onTap: () {
                        // 1) Actualizo el estado de la categoría seleccionada localmente (para filtrar Favoritos)
                        setState(() {
                          selectedCategory = cat;
                          _applyFilters();
                        });
                        // 2) Además, navego a la pantalla principal de productos PASANDO la categoría como argumento
                        Navigator.pushNamed(
                          context,
                          '/home',
                          arguments: cat, // ProductScreen debe leer este argumento para filtrar
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 2,
                              width: 30,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // 2) Título "Favoritos" sobre fondo blanco (justo encima de la lista de favoritos)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: const Text(
              'Favoritos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // 3) Lista de favoritos (o vista “vacía” si no hay nada)
          Expanded(
            child: filteredFavorites.isEmpty
                ? _buildEmptyView()
                : _buildFavoritesList(cartProvider),
          ),
        ],
      ),
    );
  }

  /// Se muestra cuando no hay coincidencias en favoritos
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin favoritos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No tienes productos favoritos con estos criterios.\nPrueba con otra búsqueda o categoría.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Restaurar estado “todos” y recargar
              setState(() {
                selectedCategory = 'Todos';
                searchController.clear();
                loadFavorites();
              });
            },
            child: const Text('VER TODOS LOS FAVORITOS'),
          ),
        ],
      ),
    );
  }

  /// Lista de tarjetas con cada producto favorito
  Widget _buildFavoritesList(CartProvider cartProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredFavorites.length,
      itemBuilder: (context, index) {
        final product = filteredFavorites[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Imagen del producto ---
                _buildProductImage(product.imageUrl),
                const SizedBox(width: 12),

                // --- Datos del producto: categoría, nombre, precio, botones ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getCategoryName(product.category),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'S/${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Icono de corazón lleno: al tocar, confirma eliminación
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 28,
                            ),
                            onPressed: () {
                              _confirmRemoveFavorite(product);
                            },
                          ),
                          const Spacer(),
                          // Botón “Agregar a carrito”
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text("Agregar a carrito"),
                            onPressed: () {
                              cartProvider.addToCart(
                                CartItem(
                                  id: product.id,
                                  name: product.name,
                                  price: product.price,
                                  imageUrl: product.imageUrl,
                                  quantity: 1,
                                  availableSizes: product.sizes,
                                  selectedSize: '',
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} agregado al carrito',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye la imagen del producto (URL, relativa o base64) con bordes redondeados
  Widget _buildProductImage(String url) {
    const double imageSize = 130;
    Widget imageWidget;

    if (url.startsWith('http') || url.startsWith('https')) {
      imageWidget = Image.network(
        url,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _errorImage();
        },
      );
    } else if (url.startsWith('/uploads')) {
      final fullUrl = 'http://www.chbackend.somee.com$url';
      imageWidget = Image.network(
        fullUrl,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _errorImage();
        },
      );
    } else {
      try {
        final decodedBytes = base64Decode(url);
        imageWidget = Image.memory(
          decodedBytes,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _errorImage();
          },
        );
      } catch (_) {
        imageWidget = _errorImage();
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageWidget,
    );
  }

  Widget _errorImage() {
    return Container(
      width: 130,
      height: 130,
      color: Colors.grey[200],
      child: const Icon(Icons.error, color: Colors.red),
    );
  }
}
