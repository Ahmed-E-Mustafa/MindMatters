/*import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MMSETestScreen extends StatefulWidget {
  const MMSETestScreen({Key? key, required bool isAdmin}) : super(key: key);

  @override
  _MMSETestScreenState createState() => _MMSETestScreenState();
}

class _MMSETestScreenState extends State<MMSETestScreen> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
  }

  Future<void> _initializeSpeechToText() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        print("Speech recognition status: $status");
      },
      onError: (errorNotification) {
        print("Speech recognition error: $errorNotification");
      },
    );

    if (!available) {
      print('Speech recognition not available');
    }
  }

  Future<void> _askQuestion(String question, int maxPoints) async {
    await Future.delayed(Duration(seconds: 3)); // Add delay for demo purposes
    await _speak(question);

    // Wait for user response
    await Future.delayed(Duration(seconds: 5));
    await _speechToText.listen(
      onResult: (result) async {
        print('Recognized Words: ${result.recognizedWords}');
        bool deservesPoint =
            await _evaluateAnswer(question, result.recognizedWords);
        if (deservesPoint) {
          setState(() {
            totalScore += 1;
          });
          print('Score: $totalScore');
        }
      },
      listenFor: Duration(seconds: 2),
    );
  }

  Future<void> _speak(String message) async {
    await _flutterTts.speak(message);
  }

  Future<bool> _evaluateAnswer(String question, String answer) async {
    switch (question) {
      case "What is the day today?":
        return await _evaluateDayAnswer(answer);
      case "What is the month today?":
        return await _evaluateMonthAnswer(answer);
      case "What is the year today?":
        return await _evaluateYearAnswer(answer);
      default:
        return answer.trim().isNotEmpty;
    }
  }

  Future<bool> _evaluateDayAnswer(String answer) async {
    String currentDay = DateFormat("dd").format(DateTime.now());
    return answer.trim() == currentDay;
  }

  Future<bool> _evaluateMonthAnswer(String answer) async {
    String currentMonth = DateFormat("MM").format(DateTime.now());
    return answer.trim() == currentMonth;
  }

  Future<bool> _evaluateYearAnswer(String answer) async {
    String currentYear = DateFormat("yyyy").format(DateTime.now());
    return answer.trim() == currentYear;
  }

  Future<void> _startMMSETest() async {
    setState(() {
      totalScore = 0;
    });

    List<String> questions = [
      "What is the day today?",
      "What is the month today?",
      "What is the year today?",
    ];

    for (String question in questions) {
      await _askQuestion(question, 4);
    }

    // Add a delay to ensure all questions are answered before navigating
    await Future.delayed(Duration(seconds: 4));

    // Navigate to the ScoreDisplayScreen to show the total score
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreDisplayScreen(totalScore: totalScore),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MMSE Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _startMMSETest();
          },
          child: Text('Start MMSE Test'),
        ),
      ),
    );
  }
}

class ScoreDisplayScreen extends StatelessWidget {
  final int totalScore;

  ScoreDisplayScreen({required this.totalScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Score:',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              '$totalScore',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MMSETestScreen(isAdmin: false)));
}
*/