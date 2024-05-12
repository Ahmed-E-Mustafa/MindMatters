import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PuzzleGame(),
    );
  }
}

class PuzzleGame extends StatefulWidget {
  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<String> images = [
    'image1.png',
    'image2.png',
    'image3.png'
  ]; // Add your image paths here
  late List<String> shuffledImages;
  late List<bool> revealed;
  late int firstIndex;
  late int moves;
  late int score;
  late bool gameOver;
  late int startTime;
  bool canTap = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User? _user;

  @override
  void initState() {
    super.initState();
    shuffledImages = List.from(images)..addAll(images);
    shuffledImages.shuffle();
    revealed = List.filled(shuffledImages.length, false);
    moves = 0;
    score = 0;
    gameOver = false;
    startTime = 0;
    firstIndex = -1;

    _initUser();
  }

  Future<void> _initUser() async {
    _user = _auth.currentUser;
    if (_user == null) {
      // Handle case where user is not signed in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Game'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              itemCount: shuffledImages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (canTap) {
                      if (!gameOver) {
                        setState(() {
                          revealCard(index);
                        });
                      }
                    }
                  },
                  child: buildCard(index),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildCard(int index) {
    if (revealed[index]) {
      return Image.asset(
        'assets/images/${shuffledImages[index]}',
        width: 120,
        height: 120,
      );
    } else {
      return Container(
        color: Colors.blue,
        width: 75,
        height: 75,
      );
    }
  }

  void revealCard(int index) {
    if (!revealed[index]) {
      revealed[index] = true;
      moves++;

      if (moves % 2 == 1) {
        if (moves == 1) {
          startTime = DateTime.now().millisecondsSinceEpoch;
        }
        firstIndex = index;
      } else {
        int secondIndex = index;
        if (shuffledImages[firstIndex] == shuffledImages[secondIndex]) {
          score++;
          if (score == shuffledImages.length ~/ 2) {
            gameOver = true;
            showGameOverDialog();
          }
        } else {
          canTap = false; // Prevent tapping while showing cards
          Future.delayed(Duration(milliseconds: 50), () {
            setState(() {
              revealed[firstIndex] = false;
              revealed[secondIndex] = false;
              canTap = true; // Allow tapping after hiding cards
            });
          });
        }
      }

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          if (moves % 2 == 0) {
            firstIndex = -1;
          }
        });
      });
    }
  }

  void showGameOverDialog() async {
    int endTime = DateTime.now().millisecondsSinceEpoch;
    int timeTaken = (endTime - startTime) ~/ 1000;
    if (_user != null) {
      // Check if the user already has a game result document
      final gameResultQuery = await _firestore
          .collection('game_results')
          .where('user_id', isEqualTo: _user!.uid)
          .get();

      // If the user has an existing game result document, update it
      if (gameResultQuery.docs.isNotEmpty) {
        final existingGameResult = gameResultQuery.docs.first;
        final existingScore = existingGameResult['score'] ?? 0;
        final newScore = score + existingScore;

        await existingGameResult.reference.update({
          'moves': moves,
          'score': newScore,
          'time_taken': timeTaken,
        });
      } else {
        // If the user doesn't have an existing game result document, create a new one
        if (_user != null) {
          // If the user doesn't have an existing game result document, create a new one
          await _firestore.collection('game_results').add({
            'user_id': _user!.uid,
            'game_id': 'Puzzle Game', // Set game_id for puzzle game
            'moves': moves,
            'score': score,
            'time_taken': timeTaken,
          });
        }
      }
    }

    // Show the game over dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Moves: $moves'),
              Text('Score: $score'),
              Text('Time Taken: $timeTaken seconds'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                restartGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void restartGame() {
    setState(() {
      shuffledImages.shuffle();
      revealed = List.filled(shuffledImages.length, false);
      moves = 0;
      score = 0;
      gameOver = false;
      startTime = 0;
      firstIndex = -1;
      canTap = true;
    });
  }
}
