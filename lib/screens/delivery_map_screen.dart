import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  // Coordenadas fijas de la tienda de Huancayo (ubicación real)
  final LatLng storeLocation = const LatLng(-12.06849, -75.20538);

  // Tarifa por kilómetro (ejemplo: S/ 1.00 por km)
  final double ratePerKm = 0.50;

  late GoogleMapController _mapController;
  Marker? _selectedMarker;
  double? _distanceKm;
  double? _deliveryCost;

  // Calcula la distancia en km usando la fórmula de Haversine
  double calculateDistance(LatLng start, LatLng end) {
    const p = 0.017453292519943295; // pi / 180
    final a = 0.5 -
        cos((end.latitude - start.latitude) * p) / 2 +
        cos(start.latitude * p) *
            cos(end.latitude * p) *
            (1 - cos((end.longitude - start.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Se llama cuando el usuario hace long press en el mapa
  void _onMapLongPressed(LatLng position) {
    setState(() {
      _selectedMarker = Marker(
        markerId: const MarkerId('selected'),
        position: position,
      );
      _distanceKm = calculateDistance(storeLocation, position);
      _deliveryCost = _distanceKm! * ratePerKm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu dirección de entrega'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: storeLocation,
                zoom: 14,
              ),
              markers: {
                // Marcador de la tienda (fijo)
                Marker(
                  markerId: const MarkerId('store'),
                  position: storeLocation,
                  infoWindow: const InfoWindow(title: 'Tienda'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
                // Marcador del punto seleccionado (si existe)
                if (_selectedMarker != null) _selectedMarker!,
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onLongPress: _onMapLongPressed,
            ),
          ),
          if (_distanceKm != null && _deliveryCost != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Distancia: ${_distanceKm!.toStringAsFixed(2)} km',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Costo de delivery: S/ ${_deliveryCost!.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _selectedMarker != null
                  ? () {
                      // Aquí puedes enviar estos datos a la siguiente pantalla, por ejemplo, a '/payment'
                      Navigator.pushNamed(context, '/payment', arguments: {
                        'deliveryCost': _deliveryCost,
                        'selectedLocation': _selectedMarker!.position,
                      });
                    }
                  : null,
              child: const Text('Confirmar y Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}
