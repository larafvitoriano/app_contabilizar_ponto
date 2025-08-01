import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../screens/auth_screen.dart';
import '../screens/calendar_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se ainda está carregando a autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário está autenticado
        if (snapshot.hasData) {
          return const MyHomePage(title: 'Menu'); // ou MyHomePage, se preferir
        }

        // Se o usuário não está autenticado
        return const AuthScreen();
      },
    );
  }
}
