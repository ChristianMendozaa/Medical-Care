import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class BrainPrediction {
  final List<String> labels = ["glioma", "meningioma", "notumor", "pituitary"];

  Future<Map<String, double>> predict(File imageFile) async {
    try {
      // Cargar el modelo TFLite
      final interpreter = await Interpreter.fromAsset('assets/models/brain_model.tflite');

      // Procesar la imagen
      final inputImage = await _processImage(imageFile);

      // Preparar tensores de entrada y salida
      final input = [inputImage];
      final output = List<double>.filled(labels.length, 0).reshape([1, labels.length]);

      // Realizar predicción
      interpreter.run(input, output);

      // Mapear predicciones con etiquetas
      final predictions = <String, double>{};
      for (int i = 0; i < labels.length; i++) {
        predictions[labels[i]] = output[0][i];
      }

      interpreter.close();
      return predictions;
    } catch (e) {
      throw Exception('Error al cargar el modelo o procesar la imagen: $e');
    }
  }

  Future<List<List<List<double>>>> _processImage(File imageFile) async {
    // Leer la imagen
    final image = img.decodeImage(imageFile.readAsBytesSync())!;

    // Redimensionar la imagen
    final resizedImage = img.copyResize(image, width: 299, height: 299);

    // Normalizar valores de píxeles
    final imageBytes = resizedImage.data;
    final inputImage = List.generate(299, (y) {
      return List.generate(299, (x) {
        final pixel = imageBytes[y * 299 + x];
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;
        return [r, g, b];
      });
    });

    return inputImage;
  }
}
