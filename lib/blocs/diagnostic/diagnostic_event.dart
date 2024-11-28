import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class DiagnosticEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddDiagnosticEvent extends DiagnosticEvent {
  final String diagnosticName;
  final String patientName;
  final String observations;
  final File? image;
  final String diagnosticType; // Nuevo: Tipo de diagnóstico
  final String selectedPrediction; // Nuevo: Predicción seleccionada

  AddDiagnosticEvent({
    required this.diagnosticName,
    required this.patientName,
    required this.observations,
    this.image,
    required this.diagnosticType,
    required this.selectedPrediction,
  });

  @override
  List<Object?> get props =>
      [diagnosticName, patientName, observations, image, diagnosticType, selectedPrediction];
}

class LoadDiagnosticsEvent extends DiagnosticEvent {}
