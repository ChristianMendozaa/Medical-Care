import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class AuthInitial extends AuthState {}

// Estado de carga
class AuthLoading extends AuthState {}

// Estado de autenticación exitosa
class AuthSuccess extends AuthState {
  final String userId;

  const AuthSuccess(this.userId);

  @override
  List<Object?> get props => [userId];

  AuthSuccess copyWith({String? userId}) {
    return AuthSuccess(userId ?? this.userId);
  }
}

// Estado de no autenticado
class AuthUnauthenticated extends AuthState {}

// Estado de error
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];

  AuthFailure copyWith({String? message}) {
    return AuthFailure(message ?? this.message);
  }
}
