import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicre/Models/UserModel.dart';
import 'package:medicre/blocs/userProfile/profile_event.dart';
import 'package:medicre/blocs/userProfile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc()
      : super(
          ProfileState(
            user: UserModel(uid: '', email: ''),
            name: '',
          ),
        ) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateName>(_onUpdateName);
    on<UpdateProfileImage>(_onUpdateProfileImage);
    on<SaveChanges>(_onSaveChanges);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final userData = UserModel(
            uid: user.uid,
            email: user.email ?? '',
          );
          emit(state.copyWith(
            user: userData,
            name: doc['name'] ?? '',
            profileImageUrl: doc['profileImageUrl'],
            isLoading: false,
          ));
        }
      } catch (e) {
        print('Error loading profile: $e');
        emit(state.copyWith(isLoading: false));
      }
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onUpdateName(UpdateName event, Emitter<ProfileState> emit) {
    emit(state.copyWith(name: event.name, isEditing: true));
  }

  Future<void> _onUpdateProfileImage(UpdateProfileImage event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isSaving: true));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('userImages/${user.uid}/profile.jpg');
        await ref.putFile(event.imageFile);
        final profileImageUrl = await ref.getDownloadURL();
        emit(state.copyWith(profileImageUrl: profileImageUrl, isSaving: false));
      } catch (e) {
        print('Error updating profile image: $e');
        emit(state.copyWith(isSaving: false));
      }
    } else {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> _onSaveChanges(SaveChanges event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isSaving: true));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': state.name,
          'profileImageUrl': state.profileImageUrl,
        });
        emit(state.copyWith(isEditing: false, isSaving: false));
      } catch (e) {
        print('Error saving profile changes: $e');
        emit(state.copyWith(isSaving: false));
      }
    } else {
      emit(state.copyWith(isSaving: false));
    }
  }
}
