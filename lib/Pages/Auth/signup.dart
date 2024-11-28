import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicre/blocs/auth/auth_bloc.dart';
import 'package:medicre/blocs/auth/auth_event.dart';
import 'package:medicre/blocs/auth/auth_state.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool isPasswordVisible = false;
  File? profileImage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: BlocProvider(
        create: (_) => AuthBloc(),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              // Navegar a Login después de registro exitoso
              Navigator.pushReplacementNamed(context, '/login');
            } else if (state is AuthFailure) {
              // Mostrar mensaje de error si hay problemas
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen de perfil
                    Center(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : const AssetImage(
                                      'assets/images/default_profile.jpg')
                                  as ImageProvider,
                          child: profileImage == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Crear una cuenta",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Regístrate para comenzar",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    // Campo de nombre
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo de email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Botón de registro
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return Center(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final name = nameController.text;
                                    final email = emailController.text;
                                    final password = passwordController.text;

                                    if (name.isEmpty ||
                                        email.isEmpty ||
                                        password.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Por favor completa todos los campos'),
                                        ),
                                      );
                                    } else {
                                      BlocProvider.of<AuthBloc>(context).add(
                                        SignUpEvent(
                                          name,
                                          email,
                                          password,
                                          profileImage
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 198, 12, 12),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Registrarse',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Enlace para iniciar sesión
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "¿Ya tienes una cuenta? ",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Inicia sesión',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 198, 12, 12),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pop(context);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
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
