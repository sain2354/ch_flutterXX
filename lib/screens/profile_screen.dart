// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart' as local_auth;
import '../providers/cart_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<local_auth.AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta'),
      ),
      body: user == null
          ? buildLoggedOutView(context)
          : buildLoggedInView(context, user),
    );
  }

  Widget buildLoggedOutView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No has iniciado sesión',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Navega a la pantalla de autenticación.
              await Navigator.pushNamed(context, '/auth');
              // Al retornar, si el usuario ya inició sesión, se redirige a Home.
              final authProvider =
                  Provider.of<local_auth.AuthProvider>(context, listen: false);
              if (authProvider.user != null) {
                Navigator.pushReplacementNamed(context, '/profile');
              }
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  Widget buildLoggedInView(BuildContext context, User user) {
    final displayName = user.displayName ?? 'Sin nombre';
    final email = user.email ?? 'Sin correo';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 40),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(email),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),
        ListTile(
          leading: const Icon(Icons.shopping_bag),
          title: const Text('Órdenes'),
          onTap: () {
            Navigator.pushNamed(context, '/orders');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Perfil'),
          onTap: () {
            Navigator.pushNamed(context, '/edit-profile');
          },
        ),
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('Favoritos'),
          onTap: () {
            Navigator.pushNamed(context, '/favorites');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Cerrar sesión'),
          onTap: () async {
            final cartProvider =
                Provider.of<CartProvider>(context, listen: false);
            if (cartProvider.currentUserId != null) {
              await cartProvider
                  .syncLocalCartToServer(cartProvider.currentUserId!);
            } else {
              debugPrint("No user logged in, can't sync cart.");
            }
            if (!mounted) return;
            final authProvider =
                Provider.of<local_auth.AuthProvider>(context, listen: false);
            await authProvider.signOut();
            if (!mounted) return;
            await cartProvider.setUser(null);
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ],
    );
  }
}
