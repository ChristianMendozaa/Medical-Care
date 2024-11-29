import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'diagnostic_event.dart';
import 'diagnostic_state.dart';

class DiagnosticBloc extends Bloc<DiagnosticEvent, DiagnosticState> {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DiagnosticBloc({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        super(DiagnosticInitial()) {
    on<AddDiagnosticEvent>(_onAddDiagnostic);
    on<LoadDiagnosticsEvent>(_onLoadDiagnostics);
  }

  Future<void> _onAddDiagnostic(
      AddDiagnosticEvent event, Emitter<DiagnosticState> emit) async {
    emit(DiagnosticLoading());
    try {
      String? imageUrl;

      // Subir imagen a Firebase Storage
      if (event.image != null) {
        final ref = _storage
            .ref()
            .child('diagnostics/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = await ref.putFile(event.image!);
        imageUrl = await uploadTask.ref.getDownloadURL();
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
