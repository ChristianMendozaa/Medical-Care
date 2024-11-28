import 'package:equatable/equatable.dart';

abstract class DiagnosticState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DiagnosticInitial extends DiagnosticState {}

class DiagnosticLoading extends DiagnosticState {}

class DiagnosticSuccess extends DiagnosticState {}

class DiagnosticFailure extends DiagnosticState {
  final String message;

  DiagnosticFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class DiagnosticsLoaded extends DiagnosticState {
  final List<Map<String, dynamic>> diagnostics;

  DiagnosticsLoaded(this.diagnostics);

  @override
  List<Object?> get props => [diagnostics];
}
