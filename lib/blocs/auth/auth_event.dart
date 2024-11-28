import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Evento para Login
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// Evento para SignUp (incluye imagen de perfil)
class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final File? profileImage; // Imagen opcional

  SignUpEvent(this.name, this.email, this.password, this.profileImage);

  @override
  List<Object?> get props => [name, email, password, profileImage];
}

// Evento para Logout
class LogoutEvent extends AuthEvent {}
