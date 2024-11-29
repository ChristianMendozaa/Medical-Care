// Eventos del perfil
import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateName extends ProfileEvent {
  final String name;

  UpdateName(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateProfileImage extends ProfileEvent {
  final File imageFile;

  UpdateProfileImage(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class SaveChanges extends ProfileEvent {}