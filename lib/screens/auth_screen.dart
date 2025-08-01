import 'package:flutter/material.dart';
import 'package:app_contabilizar_ponto/services/auth_service.dart'; // Ajuste o caminho conforme necessário

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool showSignIn = true; // Para alternar entre login e registro

  void toggleView() {
    setState(() {
      _formKey.currentState?.reset(); // Limpa os campos ao alternar
      error = ''; // Limpa mensagens de erro
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showSignIn ? 'Login' : 'Registrar'),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person, color: Colors.white),
            label: Text(showSignIn ? 'Registrar' : 'Login', style: const TextStyle(color: Colors.white)),
            onPressed: () => toggleView(),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Digite um email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Senha'),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'A senha deve ter 6+ caracteres' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                child: Text(showSignIn ? 'Entrar' : 'Registrar'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result;
                    if (showSignIn) {
                      result = await _auth.signInWithEmailAndPassword(email, password);
                    } else {
                      result = await _auth.registerWithEmailAndPassword(email, password);
                    }
                    if (result == null) {
                      setState(() {
                        error = 'Por favor, verifique suas credenciais ou tente novamente.';
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 12.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}