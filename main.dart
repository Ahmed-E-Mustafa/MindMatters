import 'dart:async';

//import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personality_development/DashboardScreen.dart';
import 'package:personality_development/ForgotPassword.dart';
// import 'package:personality_development/MMSE_Test.dart';
import 'package:personality_development/Signup.dart';
import 'package:personality_development/UserService.dart';
import 'package:personality_development/firebase_options.dart';
import 'package:personality_development/google_sign_in.dart';

//List<CameraDescription>? cameras;
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // late CameraController _cameraController;
  // cameras = availableCameras() as List<CameraDescription>?;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(seconds: 3),
      () => runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Color.fromARGB(255, 162, 149, 175),
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(secondary: Color.fromARGB(255, 153, 194, 212)),
          ),
          home: SignInScreen(isAdmin: true),
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
              isAdmin: true, // Set this to false if it's not an admin signin
            ),
        '/forgot_password': (context) => ForgotPasswordScreen(
              isAdmin: false,
            ), // Add this line
        '/SignOut': (context) => SignUpScreen(
              isAdmin: false, // Set this to true if it's an admin signup
            ),
        /*  '/MMSE_Test': (context) => MMSETestScreen(
              isAdmin: false, // Set this to true if it's an admin signup
            ), */
      },
    );
  }
}

@override
void initState() {
  initState();
  // Add this line to register the onBackPressed callback
  SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
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

class SignInScreen extends StatelessWidget {
  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final bool isAdmin;

  SignInScreen({required this.isAdmin, Key? key}) : super(key: key);

  Future<void> _signin(BuildContext context) async {
    try {
      // Admin sign-in logic
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email == "ahmedszabist@gmail.com" && password == "ahmedszabist") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin signed in successfully"),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPanelScreen(),
          ),
        );
      } else {
        // Handle regular user sign-in logic
        final FirebaseAuth.UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        final FirebaseAuth.User? user = userCredential.user;

        if (user != null) {
          // Fetch additional user information from Firestore
          final CollectionReference users =
              FirebaseFirestore.instance.collection('users');
          DocumentSnapshot snapshot = await users.doc(user.uid).get();

          Map<String, dynamic>? userData =
              snapshot.data() as Map<String, dynamic>?;
          if (snapshot.exists) {
            if (userData != null) {
              String firstName = userData['firstName'] ?? '';
              String lastName = userData['lastName'] ?? '';
              String actualName = '$firstName $lastName';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Welcome, $actualName!"),
                ),
              );
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(user: user),
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in to Your Account'), // Center the title text
        backgroundColor: Color.fromARGB(255, 135, 194, 241),
      ),
      backgroundColor: Color.fromARGB(255, 192, 228, 248),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  await _signin(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  backgroundColor: Colors.blue, // Set button color to blue
                ),
                child: Text(
                  'Log in',
                  style:
                      TextStyle(color: Colors.white), // Set text color to white
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Trigger Google Sign-In
                  FirebaseAuth.User? user = await signInWithGoogle(context);

                  // Handle the user state or navigate to the appropriate screen
                  if (user != null) {
                    // User signed in successfully, navigate to the next screen or perform other actions
                  } else {
                    // Handle sign-in failure
                  }
                },
                child: Text(
                  'Sign In with Google',
                  style: TextStyle(color: Colors.red), // Set text color to red
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ForgotPasswordScreen(isAdmin: false),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Don't have an account yet?",
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(isAdmin: false),
                    ),
                  );
                },
                child: Text(
                  'Create an Account',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
