import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicre/blocs/diagnostic/diagnostic_bloc.dart';
import 'package:medicre/blocs/diagnostic/diagnostic_event.dart';
import 'package:medicre/blocs/diagnostic/diagnostic_state.dart';
import 'package:medicre/Pages/predictions/brain_prediction.dart';
import 'package:medicre/Pages/predictions/pneumonia_prediction.dart';

class NewDiagnosticPage extends StatefulWidget {
  const NewDiagnosticPage({super.key});

  @override
  State<NewDiagnosticPage> createState() => _NewDiagnosticPageState();
}

class _NewDiagnosticPageState extends State<NewDiagnosticPage> {
  final TextEditingController diagnosticController = TextEditingController();
  final TextEditingController patientController = TextEditingController();
  final TextEditingController observationsController = TextEditingController();

  File? selectedImage;
  String? diagnosticType;
  Map<String, double>? predictionResults;
  String? selectedPrediction;

  @override
  void dispose() {
    diagnosticController.dispose();
    patientController.dispose();
    observationsController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    if (diagnosticType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un tipo de diagnóstico primero'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        predictionResults = null;
        selectedPrediction = null;
      });

      await _predictImage();
    }
  }

  Future<void> _predictImage() async {
    if (selectedImage == null) return;

    try {
      if (diagnosticType == "Tumor cerebral") {
        final brainPrediction = BrainPrediction();
        final result = await brainPrediction.predict(selectedImage!);

        setState(() {
          predictionResults = result;
          selectedPrediction = result.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
        });
      } else if (diagnosticType == "Neumonía") {
        final pneumoniaPrediction = PneumoniaPrediction();
        final result = await pneumoniaPrediction.predict(selectedImage!);

        setState(() {
          predictionResults = result;
          selectedPrediction = result.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
        });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la imagen: $e')),
      );
    }
  }

  void _saveDiagnostic(BuildContext context) {
    final diagnosticName = diagnosticController.text;
    final patientName = patientController.text;
    final observations = observationsController.text;

    if (diagnosticName.isEmpty ||
        patientName.isEmpty ||
        observations.isEmpty ||
        selectedPrediction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor completa todos los campos y selecciona una predicción'),
        ),
      );
      return;
    }

    BlocProvider.of<DiagnosticBloc>(context).add(
      AddDiagnosticEvent(
        diagnosticName: diagnosticName,
        patientName: patientName,
        observations: observations,
        image: selectedImage,
        diagnosticType: diagnosticType!, // Tipo de diagnóstico
        selectedPrediction: selectedPrediction!, // Predicción seleccionada
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Diagnóstico'),
        backgroundColor: Colors.blueAccent,  // Profesional y tranquilo
      ),
      body: BlocListener<DiagnosticBloc, DiagnosticState>(
        listener: (context, state) {
          if (state is DiagnosticLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Guardando diagnóstico...')),
            );
          } else if (state is DiagnosticSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diagnóstico guardado con éxito')),
            );
            _resetForm();
          } else if (state is DiagnosticFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona el tipo de diagnóstico:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text("Tumor cerebral"),
                      value: diagnosticType == "Tumor cerebral",
                      onChanged: (value) {
                        setState(() {
                          diagnosticType = value! ? "Tumor cerebral" : null;
                          selectedImage = null;
                          predictionResults = null;
                          selectedPrediction = null;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Neumonía"),
                      value: diagnosticType == "Neumonía",
                      onChanged: (value) {
                        setState(() {
                          diagnosticType = value! ? "Neumonía" : null;
                          selectedImage = null;
                          predictionResults = null;
                          selectedPrediction = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: selectedImage != null
                      ? Image.file(selectedImage!, fit: BoxFit.contain)
                      : const Icon(Icons.camera_alt, size: 50, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              if (predictionResults != null) ...[
                const Text(
                  'Resultados de la predicción:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: predictionResults!.entries.map((entry) {
                      return ListTile(
                        title: Text(
                            '${entry.key}: ${(entry.value * 100).toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 16)),
                        leading: Radio<String>(
                          value: entry.key,
                          groupValue: selectedPrediction,
                          onChanged: (value) {
                            setState(() {
                              selectedPrediction = value;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildTextField(diagnosticController, 'Nombre del Diagnóstico'),
              const SizedBox(height: 20),
              _buildTextField(patientController, 'Nombre del Paciente'),
              const SizedBox(height: 20),
              _buildTextField(observationsController, 'Observaciones', maxLines: 4),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _saveDiagnostic(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Colores acordes a la salud
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  ),
                  child: const Text('Guardar Diagnóstico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      maxLines: maxLines,
    );
  }

  void _resetForm() {
    setState(() {
      diagnosticController.clear();
      patientController.clear();
      observationsController.clear();
      selectedImage = null;
      predictionResults = null;
      selectedPrediction = null;
    });
  }
}
