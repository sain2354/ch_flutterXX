import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import '../favorites_data.dart'; // Agregamos la referencia para favoritos

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // ------------------- Lista de banners/promociones -------------------
  // Cada banner tiene su 'url' y la 'category' a la que dirige (Hombres, Mujeres, Infantil)
  final List<Map<String, String>> promoBanners = [
    {
      'url': 'https://img.freepik.com/vector-premium/sneakers-nueva-llegada-50-dolares-descuento_271431-997.jpg', // Ejemplo: Banner "Cyber Papá"
      'category': 'Hombres',
    },
    {
      'url': 'https://estilospe.vtexassets.com/assets/vtex.file-manager-graphql/images/c57c3257-073f-4196-a3df-3a147f358ecc___2c183d145e90f1c11633dcec9dc05a90.webp', // Ejemplo: Zapatillas Hombre S/199
      'category': 'Hombres',
    },
    {
      'url': 'https://img.freepik.com/vector-gratis/banner-venta-descripcion-producto_1361-1333.jpg?semt=ais_items_boosted&w=740', // Ejemplo: Oferta Zapatillas Mujer
      'category': 'Mujeres',
    },
    {
      'url': 'https://img.pikbest.com/templates/20241004/shoes-sale-poster-template-design-for-instagram-flyer-square_10926213.jpg!w700wp', // Ejemplo: Promoción Infantil
      'category': 'Infantil',
    },
    {
      'url': 'https://f.fcdn.app/imgs/2e8782/www.fitpoint.pe/fitppe/ab74/original/recursos/106/1920x800/banner-desktop-100.jpg', // Ejemplo: Otro banner Mujer
      'category': 'Mujeres',
    },
  ];

  /// Controlador del PageView para el carrusel
  late final PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  // ----------------------------------------------------------------------

  // Lista completa de productos (traídos de la API)
  List<Product> products = [];
  // Lista filtrada según la categoría y/o marca
  List<Product> filteredProducts = [];

  bool isLoading = true;
  final ApiService apiService = ApiService();

  // Categorías disponibles
  final List<String> categories = ['Todos', 'Hombres', 'Mujeres', 'Infantil'];

  // Mapa de marcas por categoría.
  final Map<String, List<Map<String, String>>> brandMap = {
    'Hombres': [
      {
        'name': 'I-Run',
        'logo': 'https://m.universidadperu.com/imgmarca/2010-417525.gif'
      },
      {
        'name': 'Nike',
        'logo':
            'https://www.brandemia.org/wp-content/uploads/2011/09/logo_nike_principal.jpg'
      },
      {
        'name': 'Adidas',
        'logo':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGLJC-hmcfN9t5pvZRmFrTBktTfr4lpdWKTA&s'
      },
      {
        'name': 'Puma',
        'logo':
            'https://1000marcas.net/wp-content/uploads/2019/12/Puma-Logo-5.png'
      },
      {
        'name': 'Reebok',
        'logo':
            'https://static.vecteezy.com/system/resources/previews/023/871/113/non_2x/reebok-brand-logo-symbol-clothes-design-icon-abstract-illustration-free-vector.jpg'
      },
    ],
    'Mujeres': [
      {
        'name': 'I-Run',
        'logo': 'https://m.universidadperu.com/imgmarca/2010-417525.gif'
      },
      {
        'name': 'Nike',
        'logo':
            'https://www.brandemia.org/wp-content/uploads/2011/09/logo_nike_principal.jpg'
      },
      {
        'name': 'Adidas',
        'logo':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGLJC-hmcfN9t5pvZRmFrTBktTfr4lpdWKTA&s'
      },
      {
        'name': 'Puma',
        'logo':
            'https://1000marcas.net/wp-content/uploads/2019/12/Puma-Logo-5.png'
      },
      {
        'name': 'Reebok',
        'logo':
            'https://static.vecteezy.com/system/resources/previews/023/871/113/non_2x/reebok-brand-logo-symbol-clothes-design-icon-abstract-illustration-free-vector.jpg'
      },
    ],
    'Infantil': [
      {
        'name': 'I-Run',
        'logo': 'https://m.universidadperu.com/imgmarca/2010-417525.gif'
      },
      {
        'name': 'Nike',
        'logo':
            'https://www.brandemia.org/wp-content/uploads/2011/09/logo_nike_principal.jpg'
      },
      {
        'name': 'Adidas',
        'logo':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGLJC-hmcfN9t5pvZRmFrTBktTfr4lpdWKTA&s'
      },
      {
        'name': 'Puma',
        'logo':
            'https://1000marcas.net/wp-content/uploads/2019/12/Puma-Logo-5.png'
      },
      {
        'name': 'Reebok',
        'logo':
            'https://static.vecteezy.com/system/resources/previews/023/871/113/non_2x/reebok-brand-logo-symbol-clothes-design-icon-abstract-illustration-free-vector.jpg'
      },
    ],
  };

  String selectedCategory = 'Todos';
  String? selectedBrand;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Inicializamos el PageController para el carrusel y agregamos listener
    _bannerController = PageController(viewportFraction: 0.9)
      ..addListener(() {
        final page = _bannerController.page?.round() ?? 0;
        if (page != _currentBannerIndex) {
          setState(() {
            _currentBannerIndex = page;
          });
        }
      });

    // Programamos el Timer para iniciar la auto‐animación después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });

    fetchProducts();
  }

  /// Inicia el Timer que avanza el carrusel cada 3 segundos
  void _startAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (promoBanners.isEmpty) return;
      // Solo auto-deslizar si la categoría actual es "Todos"
      if (selectedCategory == 'Todos') {
        final nextPage = (_currentBannerIndex + 1) % promoBanners.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    final fetchedProducts = await apiService.fetchProducts();
    setState(() {
      products = fetchedProducts;
      filteredProducts = products; // Al inicio, todos los productos
      isLoading = false;
    });
  }

  /// Filtra los productos por la categoría seleccionada
  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      selectedBrand = null; // Reinicia la marca seleccionada
      if (category == 'Todos') {
        filteredProducts = products;
      } else {
        int categoryId = 0;
        if (category == 'Hombres') categoryId = 1;
        if (category == 'Mujeres') categoryId = 2;
        if (category == 'Infantil') categoryId = 3;
        filteredProducts =
            products.where((p) => p.category == categoryId).toList();
      }
    });
  }

  /// Filtra los productos por la marca seleccionada dentro de la categoría actual
  void filterByBrand(String brand) {
    setState(() {
      selectedBrand = brand;
      List<Product> baseList;
      if (selectedCategory == 'Todos') {
        baseList = products;
      } else {
        int categoryId = 0;
        if (selectedCategory == 'Hombres') categoryId = 1;
        if (selectedCategory == 'Mujeres') categoryId = 2;
        if (selectedCategory == 'Infantil') categoryId = 3;
        baseList = products.where((p) => p.category == categoryId).toList();
      }
      filteredProducts = baseList
          .where((p) => p.brand.toLowerCase() == brand.toLowerCase())
          .toList();
    });
  }

  /// Filtra los productos por la búsqueda en el nombre
  void searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        if (selectedBrand == null) {
          filterByCategory(selectedCategory);
        } else {
          filterByBrand(selectedBrand!);
        }
      } else {
        List<Product> baseList;
        if (selectedCategory == 'Todos') {
          baseList = products;
        } else {
          int categoryId = 0;
          if (selectedCategory == 'Hombres') categoryId = 1;
          if (selectedCategory == 'Mujeres') categoryId = 2;
          if (selectedCategory == 'Infantil') categoryId = 3;
          baseList = products.where((p) => p.category == categoryId).toList();
        }
        if (selectedBrand != null) {
          baseList = baseList
              .where(
                  (p) => p.brand.toLowerCase() == selectedBrand!.toLowerCase())
              .toList();
        }
        filteredProducts = baseList
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  /// Retorna el nombre de la categoría a partir de su id
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

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1) Barra superior con título, buscador y categorías
          Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: SafeArea(
              child: Column(
                children: [
                  const Text(
                    'CALZADOS HUANCAYO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
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
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged: searchProducts,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: categories.map((category) {
                      final isSelected = (selectedCategory == category);
                      return GestureDetector(
                        onTap: () => filterByCategory(category),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category,
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
          ),

          // 2) Sección de marcas (solo si la categoría seleccionada no es "Todos")
          if (selectedCategory != 'Todos') buildBrandSection(),

          // 3 + 4) Carrusel público + Grilla de productos dentro de un CustomScrollView
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay productos disponibles',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          // Si la categoría es "Todos", mostramos el carrusel como SliverToBoxAdapter
                          if (selectedCategory == 'Todos')
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: buildPromoCarousel(),
                              ),
                            ),

                          // Grid de productos
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.58,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = filteredProducts[index];
                                  return buildProductItem(
                                      product, cartProvider);
                                },
                                childCount: filteredProducts.length,
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedIconTheme: const IconThemeData(color: Colors.white),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'ordenes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuario',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            filterByCategory('Todos');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/cart');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/orders');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  /// Construye la sección de banners tipo carrusel
  Widget buildPromoCarousel() {
    if (promoBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 160, // Ajusta esta altura según tu diseño
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _bannerController,
              itemCount: promoBanners.length,
              itemBuilder: (context, index) {
                final banner = promoBanners[index];
                final bannerUrl = banner['url']!;
                final bannerCategory = banner['category']!;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Al hacer tap en el banner, filtramos por la categoría asociada
                      filterByCategory(bannerCategory);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Imagen del banner
                          Image.network(
                            bannerUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stack) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.error)),
                              );
                            },
                          ),
                          // Degradado semitransparente en la parte inferior
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          // Texto opcional sobre el banner
                          Positioned(
                            bottom: 8,
                            left: 12,
                            child: Text(
                              bannerCategory == 'Hombres'
                                  ? 'Zapatillas Hombre'
                                  : bannerCategory == 'Mujeres'
                                      ? 'Zapatillas Mujer'
                                      : 'Zapatillas Infantil',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black45)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Indicadores (dots) debajo del carrusel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              promoBanners.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentBannerIndex == i ? 10 : 6,
                height: _currentBannerIndex == i ? 10 : 6,
                decoration: BoxDecoration(
                  color:
                      _currentBannerIndex == i ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBrandSection() {
    final brandList = brandMap[selectedCategory] ?? [];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: brandList.map((brandData) {
            final brandName = brandData['name']!;
            final brandLogo = brandData['logo']!;
            final isSelected = (selectedBrand == brandName);
            return GestureDetector(
              onTap: () => filterByBrand(brandName),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  brandLogo,
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 60,
                      width: 60,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 60,
                      width: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.red),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
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

  Widget buildProductItem(Product product, CartProvider cartProvider) {
    final imageUrl = product.imageUrl;
    if (imageUrl.startsWith('http')) {
      return buildItemLayout(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          height: 100,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return buildErrorImage();
          },
        ),
        product: product,
        cartProvider: cartProvider,
      );
    } else if (imageUrl.startsWith('/uploads')) {
      final fullUrl = 'http://www.chbackend.somee.com$imageUrl';
      return buildItemLayout(
        child: Image.network(
          fullUrl,
          fit: BoxFit.cover,
          height: 100,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return buildErrorImage();
          },
        ),
        product: product,
        cartProvider: cartProvider,
      );
    } else {
      try {
        final decodedBytes = base64Decode(imageUrl);
        return buildItemLayout(
          child: Image.memory(
            decodedBytes,
            fit: BoxFit.cover,
            height: 100,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return buildErrorImage();
            },
          ),
          product: product,
          cartProvider: cartProvider,
        );
      } catch (e) {
        return buildErrorItemLayout();
      }
    }
  }

  Widget buildErrorImage() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.error, color: Colors.red),
    );
  }

  Widget buildItemLayout({
    required Widget child,
    required Product product,
    required CartProvider cartProvider,
  }) {
    final isFav = FavoritesData.isFavorite(product.id);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(child: child),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isFav) {
                          FavoritesData.removeFavorite(product);
                        } else {
                          FavoritesData.addFavorite(product);
                        }
                      });
                    },
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getCategoryName(product.category),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NUEVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'S/${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
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
                            content:
                                Text('${product.name} agregado al carrito'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        'Agregar carrito',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorItemLayout() {
    return Container(
      color: Colors.red,
      child: const Center(
        child: Text(
          'Error al decodificar imagen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
