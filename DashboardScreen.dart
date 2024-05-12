import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatelessWidget {
  final User? user; // User object received after successful sign-in

  DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ${user?.displayName ?? user?.email ?? ''}!',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Add SfCartesianChart here
            Container(
              height: 300, // Adjust the height based on your layout
              child: SfCartesianChart(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your logic to navigate to other parts of the app or perform actions
              },
              child: Text('Explore'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Add your logic to sign out
                await FirebaseAuth.instance.signOut();
                // Navigate back to the sign-in screen or any other screen as needed
                Navigator.pop(context);
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
