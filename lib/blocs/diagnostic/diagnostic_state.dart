import 'package:equatable/equatable.dart';

abstract class DiagnosticState extends Equatable {
  const DiagnosticState();

  @override
  List<Object?> get props => [];
}

class DiagnosticInitial extends DiagnosticState {}

class DiagnosticLoading extends DiagnosticState {}

class DiagnosticSuccess extends DiagnosticState {}

class DiagnosticFailure extends DiagnosticState {
  final String message;

  const DiagnosticFailure(this.message);

  @override
  List<Object?> get props => [message];

  DiagnosticFailure copyWith({
    String? message,
  }) {
    return DiagnosticFailure(
      message ?? this.message,
    );
  }
}

class DiagnosticsLoaded extends DiagnosticState {
  final List<Map<String, dynamic>> diagnostics;

  const DiagnosticsLoaded(this.diagnostics);

  @override
  List<Object?> get props => [diagnostics];

  DiagnosticsLoaded copyWith({
    List<Map<String, dynamic>>? diagnostics,
  }) {
    return DiagnosticsLoaded(
      diagnostics ?? this.diagnostics,
    );
  }
}
