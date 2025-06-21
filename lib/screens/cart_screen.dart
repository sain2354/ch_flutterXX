import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.red,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Tu carrito está vacío',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                // 1) Lista de productos en carrito
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen del producto
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: buildCartItemImage(item.imageUrl),
                            ),
                            const SizedBox(width: 10),
                            // Detalles
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Tallas disponibles
                                  if (item.availableSizes.isNotEmpty) ...[
                                    const Text(
                                      'Tallas disponibles',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      children:
                                          item.availableSizes.map((rawSize) {
                                        final size = rawSize.replaceFirst(
                                          RegExp(r'^Talla\s*'),
                                          '',
                                        );
                                        final isSelected =
                                            (item.selectedSize == rawSize);
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              item.selectedSize = rawSize;
                                            });
                                          },
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.red
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                            ),
                                            child: Text(
                                              size,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  // Precio
                                  Text(
                                    "S/${item.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Botón eliminar
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.black,
                                size: 28,
                              ),
                              onPressed: () {
                                cartProvider.removeFromCart(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item.name} eliminado del carrito',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 2) Cuadro de resumen (subtotal, descuento, envío, total)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        label: 'Subtotal (${cartItems.length} productos)',
                        // Usamos totalPrice como subtotal porque no hay getter específico
                        value:
                            'S/${cartProvider.totalPrice.toStringAsFixed(2)}',
                        labelSize: 16,
                        valueSize: 16,
                      ),
                      const SizedBox(height: 4),
                      _buildSummaryRow(
                        label: 'Descuento',
                        value: 'S/0.00',
                        labelSize: 16,
                        valueSize: 16,
                      ),
                      const SizedBox(height: 4),
                      _buildSummaryRow(
                        label: 'Costo de envío',
                        value: 'Por definir',
                        isMoney: false,
                        labelSize: 16,
                        valueSize: 16,
                      ),
                      const Divider(height: 16, thickness: 1),
                      _buildSummaryRow(
                        label: 'Total',
                        value:
                            'S/${cartProvider.totalPrice.toStringAsFixed(2)}',
                        isBold: true,
                        labelSize: 18,
                        valueSize: 18,
                      ),
                    ],
                  ),
                ),

                // 3) Botón de continuar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        final user =
                            FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.pushNamed(context, '/shipping');
                        } else {
                          Navigator.pushNamed(context, '/auth');
                        }
                      },
                      child: const Text(
                        'Continuar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Construye una fila de resumen con etiqueta y valor.
  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isBold = false,
    bool isMoney = true,
    double labelSize = 14,
    double valueSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isMoney ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Construye el widget de imagen para cada ítem del carrito,
  /// manejando distintas variantes: URL absoluta, ruta relativa (/uploads), data:image o base64 pura.
  Widget buildCartItemImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return placeholderErrorImage();
        },
      );
    } else if (imageUrl.startsWith('/uploads')) {
      final fullUrl = 'http://www.chbackend.somee.com$imageUrl';
      return Image.network(
        fullUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return placeholderErrorImage();
        },
      );
    } else if (imageUrl.startsWith('data:image')) {
      final pureBase64 = removeDataUrlPrefix(imageUrl);
      try {
        final decodedBytes = base64Decode(pureBase64);
        return Image.memory(
          decodedBytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return placeholderErrorImage();
          },
        );
      } catch (_) {
        return placeholderErrorImage();
      }
    } else {
      try {
        final decodedBytes = base64Decode(imageUrl);
        return Image.memory(
          decodedBytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return placeholderErrorImage();
          },
        );
      } catch (_) {
        return placeholderErrorImage();
      }
    }
  }

  /// Elimina el prefijo 'data:image/...;base64,' si existe
  String removeDataUrlPrefix(String dataUrl) {
    final base64Index = dataUrl.indexOf('base64,');
    if (base64Index != -1) {
      return dataUrl.substring(base64Index + 7);
    } else {
      return dataUrl;
    }
  }

  /// Imagen de error / placeholder
  Widget placeholderErrorImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(
        Icons.broken_image,
        color: Colors.red,
        size: 32,
      ),
    );
  }
}
