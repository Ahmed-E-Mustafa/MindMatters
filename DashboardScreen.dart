import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

//import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:personality_development/Beck.dart';
import 'package:personality_development/BreathingGame.dart';
import 'package:personality_development/PuzzleGame.dart';
import 'package:personality_development/ReactionTime.dart';
import 'package:printing/printing.dart';

//List<CameraDescription>? camera;

class DashboardScreen extends StatefulWidget {
  final User? user; // User object received after successful sign-in

  DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<GameResult> gameResults = [];

  @override
  void initState() {
    super.initState();
    retrieveGameResults();
  }

  void retrieveGameResults() async {
    if (widget.user != null) {
      try {
        // Game Results Retrieval for Puzzle Game
        final QuerySnapshot puzzleResult = await FirebaseFirestore.instance
            .collection('game_results')
            .where('user_id', isEqualTo: widget.user!.uid) // Filter by user ID
            .where('game_id', isEqualTo: 'puzzle')
            .get();

        final QuerySnapshot reactionTimeResult = await FirebaseFirestore
            .instance
            .collection('game_results')
            .where('user_id', isEqualTo: widget.user!.uid) // Filter by user ID
            .where('game_id', isEqualTo: 'reaction_time')
            .get();

        // Handle the retrieved game results here
        // You can store them in variables or update the state as needed
      } catch (error) {
        print("Error retrieving game results: $error");
      }
    }
  }

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
              'Welcome ${widget.user?.displayName ?? widget.user?.email ?? ''}!',
              style: TextStyle(fontSize: 18),
            ),
            /*        SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MMSETestScreen(isAdmin: true),
                  ),
                );
              },
              child: Text('MMSE Test'),
            ), */
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Beck()),
                );
              },
              child: Text('Beck Anxiety Inventory Test'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReactionTimeGame(),
                  ),
                );
              },
              child: Text('Reaction Time Game'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PuzzleGame()),
                );
              },
              child: Text('Puzzle Game'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RelaxationBreathingGame(),
                  ),
                );
              },
              child: Text('Relaxation Breathing Game'),
            ),
            /*          SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ),
                );
              },
              
            ),child: Text('Emotion Detection'),*/
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameResultsScreen()),
                );
              },
              child: Text('View Game Results'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Add your logic to sign out
                await FirebaseAuth.instance.signOut();
                // Navigate back to the sign-in screen or any other screen as needed
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set button color to red
              ),
              child: Text(
                'Sign Out',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Results'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () async {
              final gameResults = await _fetchGameResults();
              final directory = await getExternalStorageDirectory();
              final file = File('${directory?.path}/game_results.txt');
              await file.writeAsString(_formatGameResults(gameResults));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Game results downloaded')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              final gameResults = await _fetchGameResults();
              await Printing.layoutPdf(
                onLayout: (_) => _generatePdf(gameResults),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('game_results')
              .where('user_id',
                  isEqualTo: FirebaseAuth
                      .instance.currentUser!.uid) // Filter by current user ID
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<GameResult> gameResults = snapshot.data!.docs
                  .map((doc) => GameResult.fromSnapshot(doc))
                  .toList();

              return ListView.builder(
                itemCount: gameResults.length,
                itemBuilder: (context, index) {
                  final result = gameResults[index];
                  return Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Game Type: ${result.gameId}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Moves: ${result.moves}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Score: ${result.score}',
                            style: TextStyle(color: Colors.green),
                          ),
                          if (result.gameType == GameType.ReactionTime) ...[
                            Text(
                              'Lowest Time Taken: ${result.lowest_time_taken} seconds',
                              style: TextStyle(color: Colors.blue),
                            ),
                            Text(
                              'Highest Time Taken: ${result.highest_time_taken} seconds',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ] else if (result.gameType == GameType.Puzzle) ...[
                            Text(
                              'Time Taken: ${result.time_taken} seconds',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

Future<List<GameResult>> _fetchGameResults() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('game_results').get();
  return snapshot.docs.map((doc) => GameResult.fromSnapshot(doc)).toList();
}

String _formatGameResults(List<GameResult> gameResults) {
  String formattedResults = '';
  for (final result in gameResults) {
    formattedResults += 'Game Type: ${result.gameId}\n';
    formattedResults += 'Moves: ${result.moves}\n';
    formattedResults += 'Score: ${result.score}\n';
    if (result.gameType == GameType.ReactionTime) {
      formattedResults +=
          'Lowest Time Taken: ${result.lowest_time_taken} seconds\n';
      formattedResults +=
          'Highest Time Taken: ${result.highest_time_taken} seconds\n';
    } else if (result.gameType == GameType.Puzzle) {
      formattedResults += 'Time Taken: ${result.time_taken} seconds\n';
    }
    formattedResults += '\n';
  }
  return formattedResults;
}

Future<Uint8List> _generatePdf(List<GameResult> gameResults) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.ListView(
          children: gameResults.map((result) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Game Type: ${result.gameId}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Moves: ${result.moves}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Score: ${result.score}',
                  style: pw.TextStyle(color: PdfColors.green),
                ),
                if (result.gameType == GameType.ReactionTime) ...[
                  pw.Text(
                    'Lowest Time Taken: ${result.lowest_time_taken} seconds',
                    style: pw.TextStyle(color: PdfColors.blue),
                  ),
                  pw.Text(
                    'Highest Time Taken: ${result.highest_time_taken} seconds',
                    style: pw.TextStyle(color: PdfColors.blue),
                  ),
                ] else if (result.gameType == GameType.Puzzle) ...[
                  pw.Text(
                    'Time Taken: ${result.time_taken} seconds',
                    style: pw.TextStyle(color: PdfColors.blue),
                  ),
                ],
                pw.SizedBox(height: 10),
              ],
            );
          }).toList(),
        );
      },
    ),
  );
  return pdf.save();
}

class GameResult {
  final String gameId;
  final int moves;
  final int score;
  final double time_taken;
  final double highest_time_taken;
  final double lowest_time_taken;
  final GameType gameType; // Add gameType field

  GameResult({
    required this.gameId,
    required this.moves,
    required this.score,
    required this.time_taken,
    required this.lowest_time_taken,
    required this.highest_time_taken,
    required this.gameType, // Update constructor
  });

  static GameType _mapGameType(String gameId) {
    switch (gameId) {
      case 'puzzle':
        return GameType.Puzzle;
      case 'reaction_time':
        return GameType.ReactionTime;
      default:
        return GameType.Unknown;
    }
  }

  factory GameResult.fromSnapshot(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    GameType gameType = _mapGameType(data['game_id'] ?? '');

    switch (gameType) {
      case GameType.Puzzle:
        return GameResult(
          gameId: data['game_id'] ?? '',
          moves: data['moves'] ?? 0,
          score: data['score'] ?? 0,
          time_taken: data['timeTakenInSeconds'] ?? 0,
          highest_time_taken:
              0, // No need to display highest time for puzzle game
          lowest_time_taken:
              0, // No need to display lowest time for puzzle game
          gameType: GameType.Puzzle,
        );
      case GameType.ReactionTime:
        return GameResult(
          gameId: data['game_id'] ?? '',
          moves: data['moves'] ?? 0,
          score: data['score'] ?? 0,
          time_taken: 0, // No need to display time taken for reaction time game
          highest_time_taken: data['highest_time_taken'] ?? 0,
          lowest_time_taken: data['lowest_time_taken'] ?? 0,
          gameType: GameType.ReactionTime,
        );
      default:
        // Handle unknown game type
        return GameResult(
          gameId: data['game_id'] ?? '',
          moves: data['moves'] ?? 0,
          score: data['score'] ?? 0,
          time_taken: 0,
          highest_time_taken: 0,
          lowest_time_taken: 0,
          gameType: GameType.Unknown,
        );
    }
  }
}

enum GameType {
  ReactionTime,
  Puzzle,
  Unknown,
  // Add more game types as needed
}
