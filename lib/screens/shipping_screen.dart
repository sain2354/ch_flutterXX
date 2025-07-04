import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../services/address_service.dart';
import '../models/address.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/pago_service.dart';
import 'payment_screen.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final AddressService addressService = AddressService(
    baseUrl: 'http://www.chbackend.somee.com/api/UsuarioDireccion',
  );

  List<Address> savedAddresses = [];
  bool isLoading = true;

  // Ubicación fija de la tienda para el cálculo de distancia
  final LatLng storeLocation = const LatLng(-12.06849, -75.20538);
  // Tarifa por km
  final double ratePerKm = 0.50;

  Address? _selectedAddress;
  double? _distanceKm;
  double? _shippingCost;
  final double _discount = 0.0;
  int? _lastUserId;

  @override
  void initState() {
    super.initState();
    _tryLoadAddresses();
  }

  Future<void> _tryLoadAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedUserId;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        savedAddresses = [];
      });
      return;
    }
    await _loadAddresses(userId);
  }

  Future<void> _loadAddresses(int userId) async {
    setState(() => isLoading = true);
    try {
      final addresses = await addressService.fetchAddresses(userId);
      if (!mounted) return;
      setState(() {
        savedAddresses = addresses;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando direcciones: $e')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.loggedUserId;
    if (currentUserId != _lastUserId) {
      _lastUserId = currentUserId;
      if (currentUserId != null) {
        _loadAddresses(currentUserId);
      } else {
        setState(() {
          savedAddresses = [];
        });
      }
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((end.latitude - start.latitude) * p) / 2 +
        cos(start.latitude * p) *
            cos(end.latitude * p) *
            (1 - cos((end.longitude - start.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  void _onSelectAddress(Address addr) {
    setState(() {
      _selectedAddress = addr;
      if (addr.lat == null || addr.lng == null) {
        _distanceKm = null;
        _shippingCost = null;
        return;
      }
      final userLocation = LatLng(addr.lat!, addr.lng!);
      _distanceKm = _calculateDistance(storeLocation, userLocation);
      _shippingCost = _distanceKm! * ratePerKm;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dirección seleccionada: ${addr.direccion}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartTotal = cartProvider.totalPrice;
    // Nunca nulo
    final shippingCost = _shippingCost ?? 0.0;
    final total = cartTotal - _discount + shippingCost;

    return Scaffold(
      appBar: AppBar(title: const Text('Calzados')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStepBar(),
            const SizedBox(height: 20),
            const Text(
              'Dirección de envío',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona o ingresa tu dirección de envío',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildSavedAddressesSection(savedAddresses),
            const SizedBox(height: 20),
            _shippingOption(
              context,
              title: 'AÑADIR NUEVA DIRECCIÓN',
              onTap: () {
                Navigator.pushNamed(context, '/new-address')
                    .then((_) => _tryLoadAddresses());
              },
            ),
            const SizedBox(height: 20),
            _buildCostSummary(cartTotal, shippingCost, total),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedAddress == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Por favor selecciona una dirección')),
                    );
                    return;
                  }
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final userId = authProvider.loggedUserId;
                  if (userId == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Debes iniciar sesión')),
                    );
                    return;
                  }

                  final pagoService = PagoService();
                  final ventaId = await pagoService.createVenta(
                    total: total,
                    idUsuario: userId,
                    tipoComprobante: 'Boleta',
                    costoEnvio: shippingCost,
                  );
                  if (ventaId == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al crear la venta')),
                    );
                    return;
                  }

                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        ventaId: ventaId,
                        montoTotal: total,
                      ),
                    ),
                  );
                },
                child: const Text('CONTINUAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(icon: Icons.shopping_cart, label: 'Carrito', active: true),
        _buildConnector(active: true),
        _buildStep(icon: Icons.location_on, label: 'Dirección', active: true),
        _buildConnector(active: false),
        _buildStep(icon: Icons.attach_money, label: 'Pago', active: false),
        _buildConnector(active: false),
        _buildStep(icon: Icons.description, label: 'Creada', active: false),
      ],
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    final color = active ? Colors.green : Colors.grey;
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  Widget _buildConnector({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _buildSavedAddressesSection(List<Address> addresses) {
    if (addresses.isEmpty) {
      return const Text('No tienes direcciones guardadas.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tus direcciones guardadas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final addr = addresses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('Dirección: ${addr.direccion}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (addr.referencia?.isNotEmpty ?? false)
                      Text('Ref: ${addr.referencia}'),
                    Text('ID: ${addr.id}'),
                    if (addr.lat != null && addr.lng != null)
                      Text(
                          'Ubicación: (${addr.lat!.toStringAsFixed(4)}, ${addr.lng!.toStringAsFixed(4)})'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _onSelectAddress(addr),
                  child: const Text('Usar'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _shippingOption(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(title, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildCostSummary(
    double cartTotal,
    double shippingCost,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subtotal (productos): S/ ${cartTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          Text('Descuento: S/ ${_discount.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _shippingCost == null
              ? const Text('Costo de envío: Por definir')
              : Text('Costo de envío: S/ ${shippingCost.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          const Divider(),
          Text('Total: S/ ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}



























