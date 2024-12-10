import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Clave de API de ImgBB (para desarrollo local)
  static const String _imgbbApiKey = '2c68fb0d7ff2f04835d1da3cf672e0a3';

  AuthBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final userId = userCredential.user?.uid;
      if (userId != null) {
        emit(AuthSuccess(userId).copyWith(userId: userId));
      } else {
        emit(const AuthFailure('No se pudo obtener información del usuario.'));
      }
    } catch (e) {
      emit(AuthFailure('Error al iniciar sesión: ${e.toString()}')
          .copyWith(message: 'Error al iniciar sesión: ${e.toString()}'));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;

      if (user != null) {
        String? profileImageUrl;

        // Subir imagen a ImgBB (si está disponible)
        if (event.profileImage != null) {
          profileImageUrl = await _uploadToImgBB(event.profileImage!);
        }

        // Guardar datos en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': event.name,
          'email': event.email,
          'profileImageUrl': profileImageUrl, // Guardar URL de la imagen
          'createdAt': DateTime.now(),
        });

        emit(AuthSuccess(user.uid).copyWith(userId: user.uid));
      } else {
        emit(const AuthFailure('No se pudo crear el usuario.'));
      }
    } catch (e) {
      emit(AuthFailure('Error al registrarse: ${e.toString()}')
          .copyWith(message: 'Error al registrarse: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure('Error al cerrar sesión: ${e.toString()}')
          .copyWith(message: 'Error al cerrar sesión: ${e.toString()}'));
    }
  }

  Future<String> _uploadToImgBB(File imageFile) async {
    final url = Uri.parse('https://api.imgbb.com/1/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['key'] = _imgbbApiKey
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      return jsonResponse['data']['url'];
    } else {
      throw Exception('Error al subir imagen a ImgBB: ${response.statusCode}');
    }
  }
}
