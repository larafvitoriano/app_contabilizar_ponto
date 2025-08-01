import 'package:flutter/material.dart';
import 'package:app_contabilizar_ponto/services/auth_service.dart';

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
  bool showSignIn = true;
  bool isLoading = false;

  void toggleView() {
    setState(() {
      _formKey.currentState?.reset();
      email = '';
      password = '';
      showSignIn = !showSignIn;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    dynamic result;
    if (showSignIn) {
      result = await _auth.signInWithEmailAndPassword(email, password);
    } else {
      result = await _auth.registerWithEmailAndPassword(email, password);
    }

    setState(() => isLoading = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(showSignIn ? 'Login realizado com sucesso!' : 'Registro concluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: verifique seus dados e tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(showSignIn ? 'Login' : 'Registrar'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            label: Text(
              showSignIn ? 'Registrar' : 'Login',
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: toggleView,
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            color: Colors.grey[100],
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo-tce-rn.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val == null || val.isEmpty ? 'Digite um email' : null,
                      onChanged: (val) => setState(() => email = val),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: password,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (val) => val != null && val.length < 6 ? 'Senha com 6+ caracteres' : null,
                      onChanged: (val) => setState(() => password = val),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: Icon(showSignIn ? Icons.login : Icons.person_add),
                        label: Text(showSignIn ? 'Entrar' : 'Registrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _submit,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
