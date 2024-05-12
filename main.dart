import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:personality_development/ForgotPassword.dart';
import 'package:personality_development/Signin.dart';
import 'package:personality_development/Signup.dart';
import 'package:personality_development/chart.dart';
import 'package:personality_development/firebase_options.dart';

import 'CallPage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(seconds: 3),
      () => runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Color.fromARGB(255, 181, 133, 226),
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(secondary: Color.fromARGB(255, 119, 53, 53)),
          ),
          home: UserTypeSelectionScreen(),
        ),
      ),
    );

    return MaterialApp(
      home: SplashScreen(),
      routes: {
        '/signup': (context) => SignUpScreen(
              isAdmin: false, // Set this to true if it's an admin signup
            ),
        '/signin': (context) => SignInScreen(
              isAdmin: false, // Set this to true if it's an admin signin
            ),
        '/forgot_password': (context) => ForgotPasswordScreen(
              isAdmin: false,
            ), // Add this line
        '/SignOut': (context) => SignUpScreen(
              isAdmin: false, // Set this to true if it's an admin signup
            ),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/Splash_screen.png', // Replace with the correct path to your image
          width: 1920,
          height: 1080,
        ),
      ),
    );
  }
}

class UserTypeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select User Type'),
        backgroundColor: Color.fromARGB(255, 190, 85, 85),
      ),
      backgroundColor: Color.fromARGB(255, 181, 133, 226),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(isAdmin: true),
                  ),
                );
              },
              child: Text('Admin'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(isAdmin: false),
                  ),
                );
              },
              child: Text('Signup'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(isAdmin: false),
                  ),
                );
              },
              child: Text('Already have an account?'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(isAdmin: false),
                  ),
                );
              },
              child: Text('Forgot Password?'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartScreen(),
                  ),
                );
              },
              child: Text('Chart'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallPage(),
                  ),
                );
              },
              child: Text('Start Video Call'),
            )
          ],
        ),
      ),
    );
  }
}
