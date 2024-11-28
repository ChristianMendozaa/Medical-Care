import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuthBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
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
        emit(AuthSuccess(userId));
      } else {
        emit(AuthFailure('No se pudo obtener información del usuario.'));
      }
    } catch (e) {
      emit(AuthFailure('Error al iniciar sesión: ${e.toString()}'));
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

        // Subir imagen a Firebase Storage (si está disponible)
        if (event.profileImage != null) {
          final ref = _storage
              .ref()
              .child('userImages/${user.uid}/profile.jpg'); // Ruta en Storage
          final uploadTask = await ref.putFile(event.profileImage!);
          profileImageUrl = await uploadTask.ref.getDownloadURL();
        }

        // Guardar datos en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': event.name,
          'email': event.email,
          'profileImageUrl': profileImageUrl, // Guardar URL de la imagen
          'createdAt': DateTime.now(),
        });

        emit(AuthSuccess(user.uid));
      } else {
        emit(AuthFailure('No se pudo crear el usuario.'));
      }
    } catch (e) {
      emit(AuthFailure('Error al registrarse: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure('Error al cerrar sesión: ${e.toString()}'));
    }
  }
}
