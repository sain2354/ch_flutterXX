// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/local_cart_service.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final LocalCartService _localCartService = LocalCartService();
  final CartService _cartService = CartService();

  // El usuario actual (null para invitado)
  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  List<CartItem> get items => _items;

  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  /// Establece el usuario actual.
  /// - Si userId es null (logout): se limpia la lista en memoria y se borra solo el carrito del invitado,
  ///   de modo que la información local asociada al usuario no se pierda.
  /// - Si userId no es null (login): se crea el carrito en el servidor para ese usuario (solo si no existe);
  ///   si hay ítems en el carrito de invitado, se agregan al carrito del usuario y se limpia la llave de invitado;
  ///   luego se carga el carrito local del usuario.
  Future<void> setUser(int? userId) async {
    if (userId == null) {
      // --- CERRAR SESIÓN ---
      print(
          "CartProvider.setUser: Logout. Clearing in-memory cart and guest cart.");
      // Guardar carrito actual en la base de datos antes de cerrar sesión
      if (_currentUserId != null) {
        await syncLocalCartToServer(_currentUserId!);
      }

      // Limpiar carrito en memoria
      _items.clear();
      // Borrar el carrito de invitado
      await _localCartService.clearCartItems(userId: null);
      _currentUserId = null;
      notifyListeners();
    } else {
      // --- INICIAR SESIÓN ---
      print("CartProvider.setUser: Login with userId: $userId");

      // 1. Verificar si ya existe un carrito para este usuario; si no existe, crearlo.
      try {
        final existingCart = await _cartService.getCartForUser(userId);
        if (existingCart == null) {
          await _cartService.createCartForUser(userId);
        } else {
          print("CartProvider.setUser: Cart already exists for user $userId");
        }
      } catch (e) {
        print("CartProvider.setUser: Error creating cart for user $userId: $e");
      }

      // 2. Si hay ítems en el carrito de invitado, agregarlos al carrito del usuario
      final guestItems = await _localCartService.getCartItems(userId: null);
      if (guestItems.isNotEmpty) {
        print(
            "CartProvider.setUser: Found ${guestItems.length} guest items, syncing to user $userId");
        for (var item in guestItems) {
          try {
            await _cartService.addItemToCartDetail(userId, item);
          } catch (e) {
            print(
                "CartProvider.setUser: Error adding guest item ${item.id} for user $userId: $e");
          }
        }
        // Limpiar carrito de invitado
        await _localCartService.clearCartItems(userId: null);
      }

      _currentUserId = userId;
      await loadCartFromLocal();
      print(
          "CartProvider.setUser: Loaded ${_items.length} items for user $userId");
      notifyListeners();
    }
  }

  /// Método para sincronizar el carrito cuando se inicia sesión.
  /// Este método encapsula la lógica de setUser para facilitar su uso.
  Future<void> syncCartWithUser(int userId) async {
    await setUser(userId);
  }

  /// Carga el carrito local según _currentUserId (si es null, usa la llave del invitado)
  Future<void> loadCartFromLocal() async {
    final localItems =
        await _localCartService.getCartItems(userId: _currentUserId);
    _items.clear();
    _items.addAll(localItems);
    notifyListeners();
  }

  /// Guarda el carrito actual en local según _currentUserId
  Future<void> _saveCartLocal() async {
    await _localCartService.saveCartItems(_items, userId: _currentUserId);
  }

  /// Agrega un producto al carrito (en memoria) y lo guarda localmente
  Future<void> addToCart(CartItem item) async {
    _items.add(item);
    await _saveCartLocal();
    notifyListeners();
  }

  /// Remueve un producto del carrito (en memoria) y actualiza el almacenamiento local
  Future<void> removeFromCart(CartItem item) async {
    _items.removeWhere((cartItem) => cartItem.id == item.id);
    await _saveCartLocal();
    notifyListeners();
  }

  /// Limpia el carrito en memoria y en local (según _currentUserId)
  Future<void> clearCart() async {
    _items.clear();
    await _localCartService.clearCartItems(userId: _currentUserId);
    notifyListeners();
  }

  /// Sincroniza los ítems del carrito local al servidor para el usuario [userId].
  Future<void> syncLocalCartToServer(int userId) async {
    for (var item in List<CartItem>.from(_items)) {
      try {
        await _cartService.addItemToCartDetail(userId, item);
      } catch (e) {
        print(
            "syncLocalCartToServer: Error adding product ${item.id} to server cart: $e");
      }
    }
  }
}
