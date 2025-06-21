// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(email, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Sincronizar el carrito del usuario al iniciar sesión
      final newUserId = authProvider.loggedUserId;
      if (newUserId != null) {
        await Provider.of<CartProvider>(context, listen: false)
            .syncCartWithUser(newUserId);
      }
      // Redirigir a /shipping después de iniciar sesión
      Navigator.pushReplacementNamed(context, '/shipping');
    } else {
      setState(() {
        _errorMessage = 'Error al iniciar sesión con Email/Password.';
      });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Sincronizar el carrito del usuario al iniciar sesión con Google
      final newUserId = authProvider.loggedUserId;
      if (newUserId != null) {
        await Provider.of<CartProvider>(context, listen: false)
            .syncCartWithUser(newUserId);
      }
      // Redirigir a /complete-profile después de iniciar sesión con Google
      Navigator.pushReplacementNamed(context, '/complete-profile');
    } else {
      setState(() {
        _errorMessage = 'No se pudo iniciar sesión con Google.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.green;
    const backgroundColor = Colors.black;
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flecha de retroceso (opcional)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Título
                const Center(
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de Correo
                const Text('Correo electrónico',
                    style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      hintText: 'Correo electrónico',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de Contraseña
                const Text('Contraseña', style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.black),
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ¿Olvidaste tu contraseña?
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Recuperación (opcional)
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
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
                const SizedBox(height: 10),

                // Botón Iniciar Sesión
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'INICIAR SESIÓN',
                            style: TextStyle(color: textColor, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // Texto "También puedes acceder con:"
                const Center(
                  child: Text(
                    'También puedes acceder con:',
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón "Continuar con Google"
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: const FaIcon(FontAwesomeIcons.google,
                        color: Colors.red),
                    label: const Text(
                      'CONTINUAR CON GOOGLE',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // ¿Aún no tienes cuenta?
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Llamamos a la ruta '/register'
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      '¿Aún no tienes una cuenta?\nCREAR UNA CUENTA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
