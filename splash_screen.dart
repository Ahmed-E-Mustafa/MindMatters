import 'dart:async';

import 'package:flutter/material.dart';
import 'package:personality_development/user_type_selection.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/Splash_image.png', // Replace with the path to your image
          width: 25, // Set the desired width
          height: 25, // Set the desired height
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: SplashScreen(),
    ),
  );
  Timer(
    Duration(seconds: 3),
    () => runApp(
      MaterialApp(
        home: UserTypeSelectionScreen(),
      ),
    ),
  );
}
