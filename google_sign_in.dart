import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:personality_development/DashboardScreen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User?> signInWithGoogle(BuildContext context) async {
  try {
    // Sign out the user if already signed in
    await googleSignIn.signOut();

    // Trigger Google Sign-In
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User signed in successfully"),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(user: user),
        ),
      );
      return user;
    } else {
      // Handle Google Sign-In cancellation
      print("Google Sign-In cancelled by user");
      return null;
    }
  } catch (e) {
    print("Error during Google Sign-In: $e");
    return null;
  }
}
