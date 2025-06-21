import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';

import 'screens/welcome_screen.dart';
import 'screens/about_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/register_screen.dart';
import 'screens/search_screen.dart';

import 'screens/shipping_screen.dart';
import 'screens/new_address_screen.dart';
import 'screens/payment_screen.dart';       // +++++ IMPORT +++++
import 'screens/order_status_controller.dart';
import 'screens/pendiente_screen.dart';
import 'screens/aprobado_screen.dart';
import 'screens/rechazado_screen.dart';

import 'screens/profile_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/delivery_map_screen.dart';
import 'screens/editprofilescreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(create: (_) {
          final c = CartProvider();
          c.loadCartFromLocal();
          return c;
        }),
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calzados',
        theme: ThemeData(
          primaryColor: Colors.red,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 5,
          ),
        ),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/about': (context) => const AboutScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/auth': (context) => const AuthScreen(),
          '/register': (context) => const RegisterScreen(),
          '/search': (context) => SearchScreen(),
          '/shipping': (context) => const ShippingScreen(),
          '/new-address': (context) => const NewAddressScreen(),
          '/pago': (context) {
            final ventaId =
                ModalRoute.of(context)!.settings.arguments as int;
            return PaymentScreen(
              ventaId: ventaId,
              montoTotal: 0.0, // <-- valor por defecto
            );
          },
          '/order-status': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as int;
            return OrderStatusController(idVenta: args);
          },
          '/pendiente': (context) => const PendienteScreen(),
          '/aprobado': (context) => const AprobadoScreen(),
          '/rechazado': (context) => const RechazadoScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/complete-profile': (context) =>
              const CompleteProfileScreen(),
          '/edit-profile': (context) => EditProfileScreen(),
          '/delivery-map': (context) => const DeliveryMapScreen(),
          '/favorites': (context) => const FavoritesScreen(),
        },
      ),
    );
  }
}
