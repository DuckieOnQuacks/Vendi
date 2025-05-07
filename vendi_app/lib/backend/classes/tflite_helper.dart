import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class TFLiteHelper {
  static const String modelPath = 'assets/models/epoch50.tflite';
  Interpreter? _interpreter;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load model
      final modelFile = await _getModelFile();
      _interpreter = await Interpreter.fromFile(modelFile);
      _isInitialized = true;
      print('TFLite model initialized successfully');
    } catch (e) {
      print('Error initializing TFLite: $e');
    }
  }

  Future<File> _getModelFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelFile = File('${appDir.path}/epoch50.tflite');

    if (!await modelFile.exists()) {
      final ByteData data = await rootBundle.load(modelPath);
      final bytes = data.buffer.asUint8List();
      await modelFile.writeAsBytes(bytes);
    }

    return modelFile;
  }

  Future<bool> isVendingMachine(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    // If we still couldn't initialize, return false
    if (_interpreter == null) {
      print('TFLite interpreter is null, returning false');
      return false;
    }

    try {
      // Load and preprocess image
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image to model input size (224x224)
      final resizedImage = img.copyResize(
        image,
        width: 224,
        height: 224,
      );

      // Convert to input tensor format (normalize to [0,1])
      final inputBuffer = Float32List(1 * 224 * 224 * 3);
      var index = 0;
      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          inputBuffer[index++] = (pixel.r / 255.0);
          inputBuffer[index++] = (pixel.g / 255.0);
          inputBuffer[index++] = (pixel.b / 255.0);
        }
      }

      // Prepare output tensor (single value for binary classification)
      final outputBuffer = Float32List(1);

      // Run inference
      _interpreter!.run(inputBuffer.buffer, outputBuffer.buffer);

      // Get prediction - FLIPPED LOGIC: lower values (< 0.3) indicate vending machines
      final prediction = outputBuffer[0];
      final isVendingMachine = prediction < 0.3; // Flipped logic

      print('Model prediction: $prediction');
      print('Is vending machine: $isVendingMachine');

      return isVendingMachine;
    } catch (e) {
      print('Error running inference: $e');
      return false;
    }
  }

  void dispose() {
    if (_interpreter != null) {
      _interpreter!.close();
      _interpreter = null;
    }
    _isInitialized = false;
    print('TFLite helper disposed');
  }
}
