import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicre/Pages/diagnostics/diagnostic_details.dart';
import 'package:medicre/blocs/diagnostic/diagnostic_bloc.dart';
import 'package:medicre/blocs/diagnostic/diagnostic_event.dart';
import 'package:medicre/blocs/diagnostic/diagnostic_state.dart';

class MyDiagnosticsPage extends StatelessWidget {
  const MyDiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Diagnósticos'),
        backgroundColor: Colors.blueAccent, // Azul profesional
      ),
      body: BlocProvider(
        create: (context) => DiagnosticBloc()..add(LoadDiagnosticsEvent()),
        child: BlocBuilder<DiagnosticBloc, DiagnosticState>(
          builder: (context, state) {
            if (state is DiagnosticLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DiagnosticsLoaded) {
              if (state.diagnostics.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay diagnósticos disponibles.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.diagnostics.length,
                itemBuilder: (context, index) {
                  final diagnostic = state.diagnostics[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: diagnostic['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                diagnostic['imageUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.image,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                      title: Text(
                        diagnostic['patientName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        diagnostic['diagnosticName'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiagnosticDetailPage(
                              diagnostic: diagnostic,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is DiagnosticFailure) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'No hay diagnósticos disponibles.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
