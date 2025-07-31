import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    const Color primaryColor = const Color(0xFF004D40);
    const Color secondaryColor = const Color(0xFF568F80);

    return MaterialApp(
      title: 'Contabilizar Ponto',
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // cor da seta de voltar
          ),
        ),
      ),
      home: const MyHomePage(title: 'Contabilizar Ponto'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = const Color(0xFF004D40);
    const Color secondaryColor = const Color(0xFF568F80);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contabilizar Ponto',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: const Text(
                'Menu',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: primaryColor),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: primaryColor),
              title: const Text('Calendário'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo-tce-rn.png',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Bem-vindo(a)!', style: TextStyle(fontSize: 18.0)),
            ],
          ),
        ),
      ),
    );
  }
}

