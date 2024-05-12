import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

late int? lastClickTime;
late int highestTimeAfterClick = 0;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reaction Time Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReactionTimeGame(),
    );
  }
}

class ReactionTimeGame extends StatefulWidget {
  @override
  _ReactionTimeGameState createState() => _ReactionTimeGameState();
}

class _ReactionTimeGameState extends State<ReactionTimeGame> {
  bool gameStarted = false;
  late int startTime = DateTime.now().millisecondsSinceEpoch;
  late int highestTime = 0; // Initialized with default value
  late int lowestTime = 0; // Initialized with default value
  bool gameOver = false;
  int objectsClicked = 0;
  Offset objectPosition = Offset.zero;
  late Timer timer;
  Color timerColor = Colors.black;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reaction Time Game'),
      ),
      body: Stack(
        children: [
          buildGameArea(),
          buildTimer(),
        ],
      ),
      floatingActionButton: !gameStarted && !gameOver
          ? FloatingActionButton(
              onPressed: startGame,
              child: Icon(Icons.play_arrow),
            )
          : null,
    );
  }

  Widget buildTimer() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Timer: ${30 - (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000}',
          style: TextStyle(
            fontSize: 20,
            color: timerColor,
          ),
        ),
      ),
    );
  }

  void onTapDown(TapDownDetails details) {
    // Check if the tap falls within the bounds of the object
    double objectSize = 100; // Assuming object size is 100x100

    if (details.localPosition.dx >= objectPosition.dx &&
        details.localPosition.dx <= objectPosition.dx + objectSize &&
        details.localPosition.dy >= objectPosition.dy &&
        details.localPosition.dy <= objectPosition.dy + objectSize) {
      // If tap falls within the object bounds, increment click count and generate new position
      if (gameStarted && !gameOver) {
        setState(() {
          int currentTime = DateTime.now().millisecondsSinceEpoch;
          int reactionTime = currentTime - startTime;
          if (reactionTime > highestTime) {
            highestTime = reactionTime;
          }
          if (lowestTime == 0 || reactionTime < lowestTime) {
            lowestTime = reactionTime;
          }
          if (lastClickTime != null) {
            // Calculate time interval since last click
            int interval = currentTime - lastClickTime!;
            if (interval > highestTimeAfterClick) {
              highestTimeAfterClick = interval;
            }
          }
          lastClickTime = currentTime;
          objectsClicked++;
          generateNewPosition();
        });
      }
    }
  }

  Widget buildGameArea() {
    return GestureDetector(
      onTapDown: onTapDown, // Use onTapDown instead of onTap
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: objectPosition.dx,
              top: objectPosition.dy,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: Center(
                  child: Text(
                    'Tap!',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startGame() {
    gameStarted = true;
    objectsClicked = 0;
    highestTime = 0;
    lowestTime = 0;
    startTime = DateTime.now().millisecondsSinceEpoch;
    generateNewPosition(); // Call generateNewPosition here
    startTimer();
    lastClickTime = null;
    highestTimeAfterClick = 0;
  }

  void resetGame() {
    setState(() {
      gameStarted = false;
      gameOver = false;
      timer.cancel();
      timerColor = Colors.black;
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        int remainingTime = 30 -
            ((DateTime.now().millisecondsSinceEpoch - startTime) ~/
                1000); // Convert milliseconds to seconds
        if (remainingTime <= 3) {
          timerColor = Colors.red;
          // Flash timer
          if (timer.tick % 2 == 0) {
            timerColor = Colors.white;
          }
        }
        if (remainingTime <= 0) {
          timer.cancel();
          gameOver = true;
          saveGameResult(); // Save game result to Firestore
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Game Over'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Score: $objectsClicked clicks'),
                  SizedBox(height: 10),
                  Text(
                      'Lowest Reaction Time: ${lowestTime == 0 ? "N/A" : "${lowestTime} seconds"}'), // Convert milliseconds to seconds
                  Text(
                      'Highest Reaction Time: ${highestTime == 0 ? "N/A" : "${highestTime} seconds"}'), // Convert milliseconds to seconds
                  Text('${getSummary(objectsClicked)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetGame();
                  },
                  child: Text('Play Again'),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  void generateNewPosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final random = Random();
    final newX = random.nextDouble() * (screenWidth - 100);
    final newY = random.nextDouble() * (screenHeight - 200);

    setState(() {
      objectPosition = Offset(newX, newY);
    });
  }

  String getSummary(int clicks) {
    if (clicks <= 15) {
      return 'Your reaction time seems to be low. Consider consulting a professional for further evaluation.';
    } else if (clicks <= 20) {
      return 'Your reaction time is moderate. You might benefit from practicing mindfulness techniques.';
    } else if (clicks <= 30) {
      return 'Your reaction time is high. You probably dont have any issues.';
    } else {
      return 'Your reaction time is very high. Keep up the good work!';
    }
  }

  void saveGameResult() async {
    // Get the required data from the state of the widget
    int objectsClicked = this.objectsClicked;

    // Convert highest and
    // lowest time from milliseconds to seconds with milliseconds
    double highestTimeInSeconds = highestTime / 1000;
    double lowestTimeInSeconds = lowestTime / 1000;

    // Access Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Check if the user is authenticated
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Query the database to find if the user has previous game results
      QuerySnapshot querySnapshot = await firestore
          .collection('game_results')
          .where('user_id', isEqualTo: user.uid)
          .where('game_id', isEqualTo: 'Reaction Time')
          .get();

      // Check if the user has existing game results
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID of the first result (assuming there's only one)
        String documentID = querySnapshot.docs.first.id;

        // Update the existing document with the new game result
        await firestore.doc('game_results/$documentID').update({
          'moves': objectsClicked,
          'score': objectsClicked, // Example: Use the same score as clicks
          'highest_time_taken':
              highestTimeInSeconds, // Store highest time taken in seconds with milliseconds
          'lowest_time_taken':
              lowestTimeInSeconds, // Store lowest time taken in seconds with milliseconds
        }).then((value) {
          // Print a success message if the game result is saved successfully
          print('Game result updated successfully');
        }).catchError((error) {
          // Print an error message if there's an issue saving the game result
          print('Failed to update game result: $error');
        });
      } else {
        // If the user does not have existing game results, add a new document
        await firestore.collection('game_results').add({
          'user_id': user.uid, // Assuming user is not null here
          'game_id': 'Reaction Time', // Set game_id for reaction time game
          'moves': objectsClicked,
          'score': objectsClicked, // Example: Use the same score as clicks
          'highest_time_taken': highestTimeInSeconds,
          'lowest_time_taken': lowestTimeInSeconds,
          'timestamp': DateTime.now(),
        }).then((value) {
          // Print a success message if the game result is saved successfully
          print('Game result saved successfully');
        }).catchError((error) {
          // Print an error message if there's an issue saving the game result
          print('Failed to save game result: $error');
        });
      }
    }
  }
}
