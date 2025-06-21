// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    final authService = AuthService();
    // 1. Crear cuenta en Firebase
    final success =
        await authService.signUpWithEmailAndPassword(email, password);

    if (!success) {
      setState(() {
        _errorMessage = 'Error al crear cuenta. Intenta con otro correo.';
        _isLoading = false;
      });
      return;
    }

    // 2. Actualizar displayName en Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final fullName = '$name $lastName';
      await user.updateDisplayName(fullName);
    }

    // 3. Forzamos el login para sincronizar en backend
    final authProvider = context.read<AuthProvider>();
    final fullName = '$name $lastName';
    final loginOk = await authProvider.signInWithEmail(
      email,
      password,
      phone: phone,
      displayName: fullName,
    );

    setState(() {
      _isLoading = false;
    });

    if (!loginOk) {
      setState(() {
        _errorMessage = 'Se creó la cuenta en Firebase, pero falló el login.';
      });
      return;
    }

    // 4. Navegar a /shipping
    Navigator.pushReplacementNamed(context, '/shipping');
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
                // Flecha de retroceso
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: textColor),
                ),
                const SizedBox(height: 20),
                // Título centrado
                const Center(
                  child: Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Campo Nombre
                const Text('Nombre', style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Nombre',
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
                      return 'Por favor ingrese su nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Apellido
                const Text('Apellido', style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Apellido',
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
                      return 'Por favor ingrese su apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Teléfono
                const Text('Número de celular',
                    style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Número de celular',
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
                      return 'Por favor ingrese su número de celular';
                    }
                    // Puedes agregar una validación extra para números si lo deseas
                    final numericRegex = RegExp(r'^[0-9]+$');
                    if (!numericRegex.hasMatch(value.trim())) {
                      return 'Ingrese solo números';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Correo
                const Text('Correo electrónico',
                    style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
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
                      return 'Por favor ingrese su correo electrónico';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Contraseña
                const Text('Contraseña', style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
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
                      return 'Por favor ingrese su contraseña';
                    }
                    if (value.trim().length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Mensaje de error
                if (_errorMessage != null)
                  Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),

                // Botón "CREAR CUENTA"
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
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'CREAR CUENTA',
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
