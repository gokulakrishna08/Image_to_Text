import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image to Text Extractor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageToTextScreen(),
      debugShowCheckedModeBanner: false, // Remove debug label
    );
  }
}

class ImageToTextScreen extends StatefulWidget {
  @override
  _ImageToTextScreenState createState() => _ImageToTextScreenState();
}

class _ImageToTextScreenState extends State<ImageToTextScreen> {
  String _extractedText = '';
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndExtractImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
      await _extractTextFromImage(File(image.path));
    }
  }

  Future<void> _extractTextFromImage(File imageFile) async {
    final InputImage inputImage = InputImage.fromFile(imageFile);

    final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        _extractedText = recognizedText.text.isNotEmpty ? recognizedText.text : 'No text found in the image.';
      });
    } catch (e) {
      print('Error extracting text: $e');
      setState(() {
        _extractedText = 'Error extracting text. Please try again.';
      });
    } finally {
      textRecognizer.close();
    }
  }

  void _resetText() {
    setState(() {
      _extractedText = '';
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image to Text Extractor'),
        centerTitle: true, // Center align the title
        backgroundColor: Colors.grey[350], // Set app bar background color
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.grey[200], // Background color
              child: Stack(
                children: [
                  if (_extractedText.isEmpty) // Only show icons if text is not detected
                    ...[
                      _buildIcon(Icons.image, 30, Colors.grey),
                      _buildIcon(Icons.text_fields, 30, Colors.grey),
                      _buildIcon(Icons.picture_as_pdf, 30, Colors.grey),
                      _buildIcon(Icons.camera_alt, 30, Colors.grey),
                    ],
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Instructions:\n1. Tap the button below to pick an image.\n2. After selecting an image, the extracted text will be displayed.\n3. To reset, tap the "Reset" button.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_pickedImage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          _pickedImage!,
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (_extractedText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                _extractedText,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 8),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _extractedText));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Text copied to clipboard'),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.content_copy),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    if (_pickedImage == null)
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: Icon(Icons.image, size: 200),
                      ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickAndExtractImage,
                      child: Text('Pick Image'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetText,
                      child: Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, double size, Color color) {
    return Positioned(
      left: Random().nextDouble() * (MediaQuery.of(context).size.width - 60), // 60 is the size of the icon
      top: Random().nextDouble() * (MediaQuery.of(context).size.height - 60), // 60 is the size of the icon
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}