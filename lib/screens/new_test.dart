import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

void main() => runApp(MaterialApp(home: HomeScreen(), theme: appTheme));

// Define custom color theme
final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.brown,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Colors.green,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.green,
    textTheme: ButtonTextTheme.primary,
  ),
);

// Home Screen with custom theme
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Soil Classification App")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTestScreen()),
          ),
          child: Text("Start New Test"),
        ),
      ),
    );
  }
}

// New Test Screen for selecting and sending image for classification
class NewTestScreen extends StatefulWidget {
  @override
  _NewTestScreenState createState() => _NewTestScreenState();
}

class _NewTestScreenState extends State<NewTestScreen> {
  File? imageFile;
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter;
  bool isImageSelected = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v2_soil_classification.tflite');
  }

  Future<void> selectImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        imageFile = File(image.path);
        isImageSelected = true;
      });
    }
  }

  void classifyImage() async {
    if (imageFile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Classification Error"),
            content: Text("Please select an image to classify."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Load and preprocess the image
    img.Image image = img.decodeImage(await imageFile!.readAsBytes())!;
    img.Image resizedImg = img.copyResize(image, width: 224, height: 224);
    var input = imageToByteListFloat32(resizedImg, 224, 127.5, 127.5);

    // Run model on image
    var output = List.filled(1 * 5, 0).reshape([1, 5]); // Adjust based on your model's output
    _interpreter.run(input, output);

    // Handle the model's output
    final result = output[0].indexOf(output[0].reduce(max));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Classification Result"),
          content: Text("Your Soil Type is: ${result.toString()}."), // Map `result` to your classes
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Uint8List imageToByteListFloat32(img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Classify Soil"),
        leading: BackButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen())),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: isImageSelected
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (imageFile != null) Image.file(imageFile!),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: classifyImage,
                          child: Text("Classify Image"),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => selectImage(ImageSource.camera),
                          child: Text("Take Photo"),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => selectImage(ImageSource.gallery),
                          child: Text("Pick from Gallery"),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}
