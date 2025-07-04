import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../favorites_data.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isFav = FavoritesData.isFavorite(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.white),
            onPressed: () {
              setState(() {
                if (isFav) FavoritesData.removeFavorite(product);
                else FavoritesData.addFavorite(product);
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl.startsWith('http')
                      ? product.imageUrl
                      : 'http://www.chbackend.somee.com${product.imageUrl}',
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nombre y precio
            Text(product.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('S/\${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const SizedBox(height: 16),
            // Selector de tallas
            if (product.sizes.isNotEmpty) ...[
              const Text('Elige talla:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSize,
                items: product.sizes
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSize = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Botón agregar al carrito
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  cartProvider.addToCart(
                    product: product,
                    quantity: 1,
                    selectedSize: _selectedSize ?? '',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Agregaste \${product.name} (talla \${_selectedSize ?? '-'}) al carrito'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Agregar al carrito'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Sección de características
            const Text('Características',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildFeatureRow('SKU:', 'FDVA2YMDVRK6'),
            _buildFeatureRow('Marca:', product.brand),
            _buildFeatureRow('Categoría:', _categoryName(product.category)),
            _buildFeatureRow('Stock:', product.stock.toString()),
            _buildFeatureRow('Envío:', 'Envíos a nivel nacional, precio delivery no incluido'),
            _buildFeatureRow('Material:', 'Sintético-textil'),
            _buildFeatureRow('Color:', 'Olivo'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _categoryName(int id) {
    switch (id) {
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
}

// En tu product_screen.dart, al navegar:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => ProductDetailScreen(product: product),
//   ),
// );
