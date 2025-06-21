import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class LocalCartService {
  String getCartKey({int? userId}) {
    if (userId != null) {
      return 'local_cart_user_$userId';
    }
    return 'local_cart_guest';
  }

  Future<List<CartItem>> getCartItems({int? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getCartKey(userId: userId);
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((item) => CartItem.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> saveCartItems(List<CartItem> items, {int? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getCartKey(userId: userId);
    final jsonString = json.encode(items.map((item) => item.toJson()).toList());
    await prefs.setString(key, jsonString);
  }

  Future<void> clearCartItems({int? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = getCartKey(userId: userId);
    print("LocalCartService.clearCartItems: Clearing key '$key'");
    await prefs.remove(key);
  }
}
