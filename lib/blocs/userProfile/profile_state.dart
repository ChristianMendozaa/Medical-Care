import 'package:equatable/equatable.dart';
import 'package:medicre/Models/UserModel.dart';

class ProfileState extends Equatable {
  final UserModel user; // Información básica del usuario
  final String name; // Nombre del usuario
  final String? profileImageUrl; // URL de la imagen del perfil
  final bool isEditing; // Indica si está en modo edición
  final bool isSaving; // Indica si está guardando cambios
  final bool isLoading; // Indica si está cargando datos

  const ProfileState({
    required this.user,
    required this.name,
    this.profileImageUrl,
    this.isEditing = false,
    this.isSaving = false,
    this.isLoading = false,
  });

  ProfileState copyWith({
    UserModel? user,
    String? name,
    String? profileImageUrl,
    bool? isEditing,
    bool? isSaving,
    bool? isLoading,
  }) {
    return ProfileState(
      user: user ?? this.user,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [user, name, profileImageUrl, isEditing, isSaving, isLoading];
}
