import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicre/blocs/userProfile/profile_bloc.dart';
import 'package:medicre/blocs/userProfile/profile_event.dart';
import 'package:medicre/blocs/userProfile/profile_state.dart';

class UserAccountPage extends StatelessWidget {
  const UserAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de la Cuenta'),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final bloc = context.read<ProfileBloc>();
            return state.name.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        // Foto de perfil editable
                        Center(
                          child: GestureDetector(
                            onTap: state.isEditing
                                ? () async {
                                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      bloc.add(UpdateProfileImage(File(image.path)));
                                    }
                                  }
                                : null,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: state.profileImageUrl != null
                                  ? NetworkImage(state.profileImageUrl!)
                                  : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Nombre del usuario
                        TextField(
                          onChanged: (value) => bloc.add(UpdateName(value)),
                          enabled: state.isEditing,
                          decoration: const InputDecoration(hintText: 'Ingresa tu nombre'),
                          controller: TextEditingController(text: state.name),
                        ),
                        const SizedBox(height: 10),
                        // Botón para guardar o editar
                        ElevatedButton(
                          onPressed: state.isEditing
                              ? () => bloc.add(SaveChanges())
                              : () => bloc.add(UpdateName(state.name)),
                          child: Text(state.isEditing ? 'Guardar Cambios' : 'Editar Perfil'),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
