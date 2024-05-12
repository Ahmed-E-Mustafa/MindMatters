/*import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_v2/tflite_v2.dart';

class EmotionDetectionScreen extends StatefulWidget {
  @override
  _EmotionDetectionScreenState createState() => _EmotionDetectionScreenState();
}

class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isDetecting = false;
  late String _currentQuestion;
  String? _selectedAnswer;
  String? _currentEmotion;
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
    _askRandomQuestions();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
  }

  Future<void> _loadModel() async {
    try {
      String? res =
          await Tflite.loadModel(model: 'assets/model_unquant.tflite');
      print('Model Loaded: $res');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> _takePictureAndDetectEmotion() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }
    try {
      final XFile imageFile = await _cameraController.takePicture();
      // Preprocess the image and convert it to the required input format for the model
      Uint8List preprocessedImage = preprocessImage(imageFile);
      var recognitions = await Tflite.runModelOnBinary(
        binary: preprocessedImage,
        numResults: 2,
      );
      // Process the output
      _displayEmotion(recognitions!);
    } catch (e) {
      print(e);
    }
  }

  Uint8List preprocessImage(XFile imageFile) {
    // Load the image
    img.Image image = img.decodeImage(File(imageFile.path).readAsBytesSync())!;

    // Resize the image to fit the model input size if necessary
    // For example, if your model requires 224x224 input, resize the image to that size
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Convert the resized image to a ByteData object
    ByteData byteData = resizedImage.getBytes() as ByteData;

    // Convert the ByteData to a Uint8List
    Uint8List uint8List = byteData.buffer.asUint8List();

    // Return the preprocessed image data
    return uint8List;
  }

  void _displayEmotion(List<dynamic> recognitions) {
    if (recognitions.isNotEmpty) {
      Map<String, dynamic> topResult = recognitions[0];
      String label = topResult['label'];
      double confidence = topResult['confidence'];
      setState(() {
        _currentEmotion = label;
        _confidence = confidence;
      });
    }
  }

  void _askRandomQuestions() {
    _selectedAnswer = null;
    _currentQuestion = "null";
    // Add your questions here
    _currentQuestion = "How do you feel today?";
  }

  void _saveResponseToDatabase() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _currentEmotion != null && _selectedAnswer != null) {
      String uid = user.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore.collection('user_responses').add({
        'uid': uid,
        'emotion': _currentEmotion!,
        'question': _currentQuestion,
        'response': _selectedAnswer!,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Detection'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraPreviewWidget(),
          ),
          _currentQuestion != "null" ? _buildQuestionWidget() : SizedBox(),
          _buildCaptureButton(),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    if (_cameraController == null || !_cameraController.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return AspectRatio(
      aspectRatio: _cameraController.value.aspectRatio,
      child: CameraPreview(_cameraController),
    );
  }

  Widget _buildCaptureButton() {
    return IconButton(
      icon: Icon(Icons.camera),
      onPressed: () {
        if (!_isDetecting) {
          _takePictureAndDetectEmotion();
          _saveResponseToDatabase();
        }
      },
    );
  }

  Widget _buildQuestionWidget() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentQuestion,
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 8.0),
          _buildAnswerOptions(),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return Column(
      children: [
        // Add your answer options here
      ],
    );
  }
}
*/