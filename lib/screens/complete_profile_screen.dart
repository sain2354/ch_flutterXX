import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleCompleteProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    final fullName = '$firstName $lastName';

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() {
        _errorMessage = 'No se encontró un usuario logueado.';
        _isLoading = false;
      });
      return;
    }

    // Actualizamos el displayName en Firebase
    await firebaseUser.updateDisplayName(fullName);

    final authProvider = context.read<AuthProvider>();

    try {
      print(
          '[CompleteProfile] syncProfileOnly con fullName=$fullName phone=$phone');
      // En lugar de signInWithEmail, usamos syncProfileOnly
      await authProvider.syncProfileOnly(
        phone: phone,
        displayName: fullName,
      );

      setState(() {
        _isLoading = false;
      });

      // Ir a /shipping
      Navigator.pushReplacementNamed(context, '/shipping');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al completar perfil: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Colors.black;
    const textColor = Colors.white;
    const buttonColor = Colors.green;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: textColor),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Completar Perfil',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Campo para Nombre
                const Text('Nombre', style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Tu nombre',
                    hintStyle: const TextStyle(color: Colors.black54),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo para Apellido
                const Text('Apellido', style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Tu apellido',
                    hintStyle: const TextStyle(color: Colors.black54),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo para Número de celular
                const Text('Número de celular',
                    style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: '+51',
                    hintStyle: const TextStyle(color: Colors.black54),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu número de celular';
                    }
                    final numericRegex = RegExp(r'^[0-9]+$');
                    if (!numericRegex.hasMatch(value.trim())) {
                      return 'Ingresa solo números';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleCompleteProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'GUARDAR',
                            style: TextStyle(color: textColor, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
