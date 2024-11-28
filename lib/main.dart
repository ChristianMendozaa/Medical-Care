import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicre/Pages/Auth/login.dart';
import 'package:medicre/Pages/Auth/signup.dart';
import 'package:medicre/Pages/homepage.dart';
import 'package:medicre/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Care',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Determinar la pantalla inicial
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginView(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar si hay un usuario autenticado
    final user = FirebaseAuth.instance.currentUser;

    // Si el usuario está autenticado, redirigir a HomePage; de lo contrario, a LoginView
    if (user != null) {
      return const HomePage();
    } else {
      return const LoginView();
    }
  }
}
