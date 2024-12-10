import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'diagnostic_event.dart';
import 'diagnostic_state.dart';

class DiagnosticBloc extends Bloc<DiagnosticEvent, DiagnosticState> {
  final FirebaseFirestore _firestore;

  DiagnosticBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(DiagnosticInitial()) {
    on<AddDiagnosticEvent>(_onAddDiagnostic);
    on<LoadDiagnosticsEvent>(_onLoadDiagnostics);
  }

  Future<void> _onAddDiagnostic(
      AddDiagnosticEvent event, Emitter<DiagnosticState> emit) async {
    emit(DiagnosticLoading());
    try {
      String? imageUrl;

      // Subir imagen a Imgbb
      if (event.image != null) {
        imageUrl = await _uploadImageToImgbb(event.image!);
      }

      // Guardar datos en Firestore
      await _firestore.collection('diagnostics').add({
        'diagnosticName': event.diagnosticName,
        'patientName': event.patientName,
        'observations': event.observations,
        'imageUrl': imageUrl,
        'createdAt': DateTime.now(),
        'diagnosticType': event.diagnosticType,
        'selectedPrediction': event.selectedPrediction,
      });

      emit(DiagnosticSuccess());
    } catch (e) {
      emit(
        DiagnosticFailure('Error al guardar diagnóstico: ${e.toString()}')
            .copyWith(message: 'Error al guardar diagnóstico: ${e.toString()}'),
      );
    }
  }

  Future<String> _uploadImageToImgbb(File image) async {
    const imgbbApiKey = '2c68fb0d7ff2f04835d1da3cf672e0a3';
    final url = Uri.parse('https://api.imgbb.com/1/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['key'] = imgbbApiKey
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = jsonDecode(await response.stream.bytesToString());
      return responseData['data']['url'];
    } else {
      throw Exception(
          'Error al subir imagen a Imgbb: ${response.reasonPhrase}');
    }
  }

  Future<void> _onLoadDiagnostics(
      LoadDiagnosticsEvent event, Emitter<DiagnosticState> emit) async {
    emit(DiagnosticLoading());
    try {
      final querySnapshot = await _firestore
          .collection('diagnostics')
          .orderBy('createdAt', descending: true)
          .get();

      final diagnostics = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      emit(
        DiagnosticsLoaded(diagnostics)
            .copyWith(diagnostics: diagnostics), // Uso de copyWith
      );
    } catch (e) {
      emit(
        DiagnosticFailure('Error al cargar diagnósticos: ${e.toString()}')
            .copyWith(message: 'Error al cargar diagnósticos: ${e.toString()}'),
      );
    }
  }
}
