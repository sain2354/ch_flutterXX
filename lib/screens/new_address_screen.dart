import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/address_service.dart';
import '../models/address.dart';
// Importa tu AuthProvider usando un alias para evitar conflictos
import '../providers/auth_provider.dart' as myAuth;

class NewAddressScreen extends StatefulWidget {
  const NewAddressScreen({Key? key}) : super(key: key);

  @override
  State<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _referenciaCtrl = TextEditingController();

  bool isSaving = false;

  // Variables para el mapa
  GoogleMapController? _mapController;
  Marker? _selectedMarker;
  LatLng? _selectedLocation;

  // Ubicación de la tienda (Huancayo) para centrar el mapa inicialmente
  final LatLng _defaultLocation = const LatLng(-12.06849, -75.20538);

  // Instancia de AddressService con la URL base para UsuarioDireccion.
  final AddressService addressService = AddressService(
    baseUrl: 'http://www.chbackend.somee.com/api/UsuarioDireccion',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Dirección'),
        backgroundColor: Colors.red, // Ajusta el color si deseas
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo DIRECCIÓN
              TextFormField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingrese dirección'
                    : null,
              ),
              const SizedBox(height: 10),
              // Campo REFERENCIA
              TextFormField(
                controller: _referenciaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Referencia',
                  border: OutlineInputBorder(),
                ),
                // La referencia es opcional
              ),
              const SizedBox(height: 20),
              // Muestra el mapa de Google para seleccionar la ubicación
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _defaultLocation,
                    zoom: 14, // Ajusta el zoom a tu preferencia
                  ),
                  markers: {
                    if (_selectedMarker != null) _selectedMarker!,
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  // Al hacer long press en el mapa, se actualiza la ubicación seleccionada
                  onLongPress: _onMapLongPressed,
                ),
              ),
              const SizedBox(height: 10),
              if (_selectedLocation != null)
                Text(
                  'Ubicación seleccionada: '
                  '(${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                  '${_selectedLocation!.longitude.toStringAsFixed(4)})',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 20),
              // Botón GUARDAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _guardarDireccion,
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('GUARDAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Actualiza la ubicación y crea un marcador cuando el usuario hace long press en el mapa
  void _onMapLongPressed(LatLng position) {
    // FORZAMOS que lat y lng sean negativas (parche para Huancayo, Perú)
    final correctedLat =
        position.latitude > 0 ? -position.latitude : position.latitude;
    final correctedLng =
        position.longitude > 0 ? -position.longitude : position.longitude;

    setState(() {
      _selectedLocation = LatLng(correctedLat, correctedLng);
      _selectedMarker = Marker(
        markerId: const MarkerId('selected'),
        position: LatLng(correctedLat, correctedLng),
      );
    });
  }

  Future<void> _guardarDireccion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una ubicación en el mapa')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      // Obtén el idUsuario real del usuario autenticado desde AuthProvider
      final authProvider =
          Provider.of<myAuth.AuthProvider>(context, listen: false);
      final userId = authProvider.loggedUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final nuevaDireccion = Address(
        userId: userId,
        direccion: _direccionCtrl.text.trim(),
        referencia: _referenciaCtrl.text.trim(),
        lat: _selectedLocation!.latitude,
        lng: _selectedLocation!.longitude,
      );

      final creada = await addressService.createAddress(nuevaDireccion);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dirección creada: ${creada.direccion}')),
      );

      Navigator.pop(context, 'success');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear dirección: $e')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }
}
