import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final int ventaId;
  final double montoTotal;

  const PaymentScreen({
    Key? key,
    required this.ventaId,
    required this.montoTotal,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _txController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool isSubmitting = false;
  String _selectedMethod = 'yape';

  @override
  void dispose() {
    _txController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file != null && mounted) setState(() => _pickedImage = file);
  }

  Future<void> _submitComprobante() async {
    if (_pickedImage == null && _txController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen o ingresa el ID')),
      );
      return;
    }
    if (mounted) setState(() => isSubmitting = true);

    // Lee y codifica la imagen si existe
    String? base64Image;
    if (_pickedImage != null) {
      final bytes = await File(_pickedImage!.path).readAsBytes();
      base64Image = base64Encode(bytes);
    }

    // Construye el JSON
    final body = {
      'idVenta': widget.ventaId,
      'montoPagado': widget.montoTotal.toStringAsFixed(2),
      'idMedioPago': _selectedMethod == 'yape' ? 1 : 2,
      if (_txController.text.trim().isNotEmpty)
        'idTransaccionMP': _txController.text.trim(),
      if (base64Image != null) 'comprobanteManual': base64Image,
    };

    // Llámalo a tu endpoint JSON
    final uri = Uri.parse('http://www.chbackend.somee.com/api/Pago');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (res.statusCode == 200 || res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comprobante enviado correctamente')),
      );
      Navigator.pushReplacementNamed(
        context,
        '/order-status',
        arguments: widget.ventaId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ${res.statusCode}: ${res.body}')),
      );
    }
  }

  Widget _buildMethodTile(String method, String asset, String label) {
    final selected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.blueAccent : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(asset, width: 50, height: 50),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: selected
                    ? Colors.blueAccent.withAlpha(25)
                    : Colors.transparent,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: Center(child: Image.file(File(path))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final number =
        _selectedMethod == 'yape' ? '+51 987 654 321' : '+51 987 654 322';

    return Scaffold(
      appBar: AppBar(title: const Text('Pago Manual (Yape/Plin)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Método de pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(children: [
              _buildMethodTile('yape', 'assets/images/yape.png', 'Yape'),
              _buildMethodTile('plin', 'assets/images/plin.png', 'Plin'),
            ]),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Importe a transferir: S/ ${widget.montoTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text('Número: $number')),
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                _selectedMethod == 'yape'
                    ? 'assets/images/yape_qr.png'
                    : 'assets/images/plin_qr.png',
                width: 250,
                height: 250,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Sube tu comprobante de pago'),
            const SizedBox(height: 12),
            TextField(
              controller: _txController,
              decoration: const InputDecoration(
                labelText: 'ID de transferencia (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_camera),
              label: const Text('Seleccionar foto del comprobante'),
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            if (_pickedImage != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showFullImage(_pickedImage!.path),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_pickedImage!.path),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitComprobante,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar comprobante'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
