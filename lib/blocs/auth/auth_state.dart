import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
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

  AuthSuccess(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Estado de no autenticado
class AuthUnauthenticated extends AuthState {}

// Estado de error
class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
