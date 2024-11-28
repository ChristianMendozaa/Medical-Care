import 'package:flutter/material.dart';
import 'package:medicre/Pages/diagnostics/diagnostic_asistant.dart';

class DiagnosticDetailPage extends StatelessWidget {
  final Map<String, dynamic> diagnostic;

  const DiagnosticDetailPage({super.key, required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(diagnostic['patientName'] ?? 'Detalle del Diagnóstico'),
        backgroundColor: Colors.blueAccent, // Azul profesional
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del diagnóstico
            diagnostic['imageUrl'] != null
                ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        diagnostic['imageUrl'],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 100);
                        },
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
            const SizedBox(height: 20),

            // Sección de Diagnóstico
            _buildDetailSection(
              context,
              'Diagnóstico:',
              diagnostic['diagnosticName'] ?? 'No especificado',
            ),
            const SizedBox(height: 20),

            // Sección de Paciente
            _buildDetailSection(
              context,
              'Paciente:',
              diagnostic['patientName'] ?? 'No especificado',
            ),
            const SizedBox(height: 20),

            // Sección de Observaciones
            _buildDetailSection(
              context,
              'Observaciones:',
              diagnostic['observations'] ?? 'No especificadas',
            ),
            const SizedBox(height: 20),

            // Sección de Tipo de Diagnóstico
            _buildDetailSection(
              context,
              'Tipo de Diagnóstico:',
              diagnostic['diagnosticType'] ?? 'No especificado',
            ),
            const SizedBox(height: 20),

            // Sección de Predicción Seleccionada
            _buildDetailSection(
              context,
              'Predicción Seleccionada:',
              diagnostic['selectedPrediction'] ?? 'No especificada',
            ),
            const SizedBox(height: 20),

            // Sección de Fecha de Creación
            _buildDetailSection(
              context,
              'Fecha de Creación:',
              diagnostic['createdAt']?.toDate().toString() ?? 'No especificada',
            ),
            const SizedBox(height: 30),

            // Botón de acción
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DiagnosticChatAssistant(diagnostic: diagnostic),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Color del botón
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Hablar con Asistente",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear una sección de detalles de manera reutilizable
  Widget _buildDetailSection(
    BuildContext context,
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Color del título
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
