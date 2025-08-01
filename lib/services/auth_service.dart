import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para observar o estado de autenticação do usuário
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Método para registrar um usuário com e-mail e senha
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      print('Erro ao registrar: ${e.message}');
      // Você pode querer lançar uma exceção ou retornar null/um código de erro
      return null;
    }
  }

  // Método para fazer login com e-mail e senha
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      print('Erro ao fazer login: ${e.message}');
      // Você pode querer lançar uma exceção ou retornar null/um código de erro
      return null;
    }
  }

  // Método para fazer logout
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Erro ao fazer logout: $e');
      return null;
    }
  }
}