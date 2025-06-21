import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  // Ajusta a tu endpoint real. Ej: 'http://www.chbackend.somee.com/api/usuarios'
  final UserService _userService =
      UserService(baseUrl: 'http://www.chbackend.somee.com/api/usuarios');

  User? _user;
  User? get user => _user;

  // Campo para almacenar el ID de usuario devuelto por tu backend
  int? _loggedUserId;
  int? get loggedUserId => _loggedUserId;

  AuthProvider() {
    // Escucha cambios en el estado de FirebaseAuth
    _authService.firebaseAuth.authStateChanges().listen(
      (User? firebaseUser) async {
        _user = firebaseUser;

        // CAMBIO: si el usuario NO es null, pero _loggedUserId es null,
        // volvemos a hacer sync con el backend para obtener su ID.
        if (firebaseUser != null) {
          // Sólo sincronizamos si no tenemos ya un loggedUserId.
          if (_loggedUserId == null) {
            // Contraseña ficticia, igual que con Google.
            // (Si tu backend requiere la contraseña real, habría que guardarla)
            await _syncUserWithBackend(
              firebaseUser,
              password: 'autoPass123',
              phone: null,
              displayName: firebaseUser.displayName,
            );
          }
        } else {
          _loggedUserId = null;
        }

        notifyListeners();
      },
    );
  }

  /// -----------------------------
  /// Login normal con Email/Password
  /// -----------------------------
  Future<bool> signInWithEmail(
    String email,
    String password, {
    String? phone,
    String? displayName,
  }) async {
    // Normalizamos el email
    final normalizedEmail = email.trim().toLowerCase();

    print(
        '[signInWithEmail] email=$normalizedEmail, phone=$phone, displayName=$displayName');

    final success = await _authService.signInWithEmailAndPassword(
        normalizedEmail, password);

    if (success) {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        // Sincronizamos con el backend y almacenamos el id de usuario
        await _syncUserWithBackend(
          firebaseUser,
          password: password,
          phone: phone,
          displayName: displayName,
        );
      }
    }
    return success;
  }

  /// -----------------------------
  /// Login con Google
  /// -----------------------------
  Future<bool> signInWithGoogle() async {
    final success = await _authService.signInWithGoogle();
    if (success) {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        // Contraseña ficticia para usuarios de Google
        final randomPass = 'googlePass123';
        await _syncUserWithBackend(
          firebaseUser,
          password: randomPass,
          phone: null,
          displayName: firebaseUser.displayName,
        );
      }
    }
    return success;
  }

  /// -----------------------------
  /// Cerrar sesión
  /// -----------------------------
  Future<void> signOut() async {
    _loggedUserId = null; // Limpiamos el ID
    await _authService.signOut();
    notifyListeners();
  }

  /// -----------------------------
  /// Sólo sincroniza el perfil en el backend (sin login Firebase)
  /// -----------------------------
  Future<void> syncProfileOnly({
    required String phone,
    required String displayName,
  }) async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      print('[syncProfileOnly] No user logged in with Firebase');
      return;
    }
    const randomPass = 'googlePass123';
    print(
        '[syncProfileOnly] Llamando _syncUserWithBackend con displayName=$displayName, phone=$phone');
    await _syncUserWithBackend(
      firebaseUser,
      password: randomPass,
      phone: phone,
      displayName: displayName,
    );
  }

  /// -----------------------------
  /// Sincroniza con el backend y almacena el idUsuario
  /// -----------------------------
  Future<void> _syncUserWithBackend(
    User firebaseUser, {
    required String password,
    String? phone,
    String? displayName,
  }) async {
    final usedPhone = phone?.trim() ?? 'No registrado';
    final usedName = displayName?.trim() ??
        firebaseUser.displayName ??
        (firebaseUser.email?.split('@').first ?? 'Usuario');
    final normalizedEmail = (firebaseUser.email ?? '').trim().toLowerCase();

    print('[_syncUserWithBackend] Sincronizando:');
    print('  username/email: $normalizedEmail');
    print('  password: $password');
    print('  nombreCompleto: $usedName');
    print('  telefono: $usedPhone');

    try {
      // Suponemos que _userService.syncUser devuelve un objeto con campo idUsuario.
      final userResponse = await _userService.syncUser(
        username: normalizedEmail,
        password: password,
        nombreCompleto: usedName,
        email: normalizedEmail,
        telefono: usedPhone,
      );
      _loggedUserId = userResponse.idUsuario;
      print('ID de usuario obtenido: $_loggedUserId');
      notifyListeners();
    } catch (e) {
      print('Error al sincronizar usuario en backend: $e');
    }
  }
}
