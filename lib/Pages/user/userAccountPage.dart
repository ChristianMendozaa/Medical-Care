import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Necesario para seleccionar imágenes
import 'package:firebase_storage/firebase_storage.dart'; // Para Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el usuario autenticado

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isEditing = false; // Controla si estamos en modo edición
  bool _isSaving = false; // Controla el estado de guardado (spinner)
  XFile? _newImage; // Variable para la nueva imagen seleccionada
  String? _profileImageUrl; // Para almacenar la URL de la imagen
  String _userName = ''; // Para almacenar el nombre de usuario

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Función para obtener los datos del usuario desde Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userName = doc['name'] ?? '';
            _profileImageUrl = doc['profileImageUrl'] ?? '';
            _nameController.text = _userName;
          });
        }
      } catch (e) {
        print('Error al cargar los datos del usuario: $e');
      }
    }
  }

  // Función para seleccionar la nueva imagen
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImage = pickedFile;
      });
    }
  }

  // Función para guardar los cambios en Firebase
  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _isSaving = true; // Mostrar spinner
      });

      try {
        // Si se ha seleccionado una nueva imagen
        String? profileImageUrl;
        if (_newImage != null) {
          // Subir la imagen al almacenamiento de Firebase
          final ref = FirebaseStorage.instance.ref().child('userImages/${user.uid}/profile.jpg');
          await ref.putFile(File(_newImage!.path)); // Subimos el archivo
          profileImageUrl = await ref.getDownloadURL(); // Obtenemos la URL de la imagen subida
        }

        // Actualizar los datos del usuario en Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'profileImageUrl': profileImageUrl ?? _profileImageUrl,
        });

        setState(() {
          _isEditing = false; // Salir del modo edición
          _userName = _nameController.text; // Actualizamos el nombre de usuario visualmente
        });
      } catch (e) {
        print('Error al guardar cambios: $e');
      } finally {
        setState(() {
          _isSaving = false; // Detener el spinner
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userName.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de la Cuenta'),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Cuenta'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); // Navegar al Home
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Foto de perfil editable
            Center(
              child: GestureDetector(
                onTap: _isEditing ? _pickImage : null, // Permite seleccionar imagen solo en modo edición
                child: ClipOval(
                  child: Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundImage: _newImage != null
                          ? FileImage(File(_newImage!.path))
                          : (_profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/images/default_profile.jpg')
                                  as ImageProvider),
                      child: _profileImageUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nombre del usuario (editable)
            TextField(
              controller: _nameController
                ..text = _userName,
              enabled: _isEditing,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Ingresa tu nombre',
                border: InputBorder.none,
                fillColor: _isEditing ? Colors.blue.shade50 : Colors.transparent,
                filled: _isEditing,
              ),
            ),
            const SizedBox(height: 10),

            // Correo del usuario (no editable)
            Text(
              FirebaseAuth.instance.currentUser?.email ?? 'Correo no disponible',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            // Botón para editar perfil
            const SizedBox(height: 30),
            _isEditing
                ? ElevatedButton(
                    onPressed: _saveChanges, // Guardar los cambios
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true; // Activar modo de edición
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Editar Perfil',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
