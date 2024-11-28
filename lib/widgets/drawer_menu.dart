import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicre/Pages/user/userAccountPage.dart';
import 'package:palette_generator/palette_generator.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  Color _dominantColor = Colors.blueAccent; // Color default

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data();
            isLoading = false;
          });
          // Si hay una URL de imagen, obtener el color dominante
          if (userData?['profileImageUrl'] != null) {
            _extractDominantColor(userData!['profileImageUrl']);
          }
        }
      }
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _extractDominantColor(String imageUrl) async {
    try {
      final imageProvider = NetworkImage(imageUrl);
      final PaletteGenerator palette =
          await PaletteGenerator.fromImageProvider(imageProvider);

      setState(() {
        // Usamos el color dominante de la imagen si está disponible
        _dominantColor = palette.dominantColor?.color ?? Colors.blueAccent;
      });
    } catch (e) {
      print('Error al obtener color dominante de la imagen: $e');
      setState(() {
        _dominantColor = Colors.blueAccent; // Default fallback color
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: _dominantColor, // Usamos el color dominante en el fondo
            ),
            accountName: Text(
              userData?['name'] ?? 'Nombre no disponible',
              style: TextStyle(
                  color: Colors.white), // Texto blanco para visibilidad
            ),
            accountEmail: Text(
              userData?['email'] ?? 'Correo no disponible',
              style: TextStyle(
                  color: Colors.white), // Texto blanco para visibilidad
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: userData?['profileImageUrl'] != null
                  ? NetworkImage(userData!['profileImageUrl'])
                  : const AssetImage('assets/images/default_profile.jpg')
                      as ImageProvider,
              child: userData?['profileImageUrl'] == null
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Mi Cuenta'),
            onTap: () {
              // Navegar a la nueva página de detalles del usuario
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserAccountPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
