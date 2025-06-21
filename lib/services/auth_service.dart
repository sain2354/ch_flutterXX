import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseAuth get firebaseAuth => _firebaseAuth;

  /// Iniciar sesión con Email/Password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print('Error al iniciar sesión con email/password: $e');
      return false;
    }
  }

  /// Registrar usuario nuevo con Email/Password
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print('Error al crear usuario con email/password: $e');
      return false;
    }
  }

  /// Iniciar sesión con Google (forzando a mostrar selector cada vez)
  Future<bool> signInWithGoogle() async {
    try {
      // Forzar la selección de cuenta de Google
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el login
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      print('Error al iniciar sesión con Google: $e');
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  /// Retorna el usuario actual (si está logueado)
  User? get currentUser => _firebaseAuth.currentUser;
}
