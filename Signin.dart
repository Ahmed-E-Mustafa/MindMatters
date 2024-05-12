/*import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:personality_development/DashboardScreen.dart';
import 'package:personality_development/UserService.dart';
import 'package:personality_development/firebase_options.dart';
import 'package:personality_development/google_sign_in.dart';
import 'package:personality_development/signOut.dart';

Future<void> main() async {
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
    return MaterialApp(
      home: SignInScreen(
        isAdmin: true,
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        final User? user = userCredential.user;

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
        title: const Center(
          child: Text('Sign In'),
        ),
        backgroundColor: Color.fromARGB(255, 162, 149, 175),
      ),
      backgroundColor: Color.fromARGB(255, 153, 194, 212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                child: const Text('Sign In'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Trigger Google Sign-In
                  User? user = await signInWithGoogle(context);

                  // Handle the user state or navigate to the appropriate screen
                  if (user != null) {
                    // User signed in successfully, navigate to the next screen or perform other actions
                  } else {
                    // Handle sign-in failure
                  }
                },
                child: Text('Sign In with Google'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  signOutScreen();
                  // Navigate to the login screen or home screen after sign out
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/