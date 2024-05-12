import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MyApp());
}

class Answer {
  String question;
  int score;

  Answer({required this.question, required this.score});
}

class Questionnaire {
  List<String> anxietyQuestions;
  List<String> depressionQuestions;

  Questionnaire(
      {required this.anxietyQuestions, required this.depressionQuestions});
}

class UserData with ChangeNotifier {
  List<Answer> anxietyAnswers = [];
  List<Answer> depressionAnswers = [];

  void addAnswer(Answer answer, String category) {
    if (category == 'Anxiety') {
      anxietyAnswers.add(answer);
    } else if (category == 'Depression') {
      depressionAnswers.add(answer);
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserData()),
      ],
      child: MaterialApp(
        home: UserTypeSelectionScreen(),
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
        backgroundColor: Color.fromARGB(255, 162, 149, 175),
      ),
      backgroundColor: Color.fromARGB(255, 153, 194, 212),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Beck(),
              ),
            );
          },
          child: Text('Start Beck Questionnaire'),
        ),
      ),
    );
  }
}

class Beck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserData()),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'Beck Anxiety and Depression Questionnaire',
              style: TextStyle(fontSize: 18), // Adjust the font size as needed
            ),
            backgroundColor:
                Colors.lightBlue, // or use Color.fromARGB(255, 173, 216, 230)
          ),
          body: QuestionScreen(),
        ),
      ),
    );
  }
}

class QuestionScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int currentAnxietyIndex = 0;
  int currentDepressionIndex = 0;
  bool isAnxietyCompleted = false;
  bool isDepressionCompleted = false;
  int? selectedAnswer;
  final Questionnaire questionnaire = Questionnaire(
    anxietyQuestions: [
      " Numbness or tingling",
      " Feeling hot",
      " Wobbliness in legs",
      " Unable to relax",
      " Fear of worst happening",
      " Dizzy or lightheaded ",
      " Heart pounding/racing",
      " Unsteady ",
      " Terrified or afraid",
      " Nervous ",
      " Feeling of choking",
      " Hands trembling ",
      " Shaky / unsteady ",
      " Fear of losing control ",
      " Difficulty in breathing ",
      " Fear of dying",
      " Scared",
      " Indigestion ",
      " Faint / lightheaded",
      " Face flushed ",
      " Hot/cold sweats",
      // Add more anxiety questions as needed
    ],
    depressionQuestions: [
      " Feeling sad or down in the dumps",
      " Feeling guilty or unworthy",
      // Add more depression questions as needed
    ],
  );
  int? selectedAnswerAnxiety; // Separate state for anxiety
  int? selectedAnswerDepression; // Separate state for depression

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isAnxietyCompleted)
            _buildQuestion(
                'Anxiety', questionnaire.anxietyQuestions[currentAnxietyIndex]),
          if (!isAnxietyCompleted) _buildAnswerButtons('Anxiety'),
          SizedBox(height: 10),
          if (!isDepressionCompleted)
            _buildQuestion('Depression',
                questionnaire.depressionQuestions[currentDepressionIndex]),
          if (!isDepressionCompleted) _buildAnswerButtons('Depression'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (isAnxietyCompleted && isDepressionCompleted) {
                _calculateScoreAndShowSummary();
              } else {
                _confirmAndMoveToNextQuestion();
              }
            },
            child: Text(isAnxietyCompleted && isDepressionCompleted
                ? 'Finish'
                : 'Next Question'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(String category, String question) {
    return Column(
      children: [
        Text(
          '$category Question: $question',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAnswerButtons(String category) {
    int? selectedAnswer = category == 'Anxiety'
        ? selectedAnswerAnxiety
        : selectedAnswerDepression;

    return Column(
      children: [
        _buildRadioButton(0, 'Not at all', category, selectedAnswer),
        _buildRadioButton(1, 'Mildly', category, selectedAnswer),
        _buildRadioButton(2, 'Moderately', category, selectedAnswer),
        _buildRadioButton(3, 'Severely', category, selectedAnswer),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (selectedAnswer != null) {
              _answerQuestion(selectedAnswer, category);
            } else {
              // Show a message or alert indicating that the user needs to select an answer
            }
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildRadioButton(
      int value, String label, String category, int? selectedAnswer) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: selectedAnswer,
          onChanged: (int? value) {
            setState(() {
              if (category == 'Anxiety') {
                selectedAnswerAnxiety = value;
              } else if (category == 'Depression') {
                selectedAnswerDepression = value;
              }
            });
          },
        ),
        Text(label),
      ],
    );
  }

  void _confirmAndMoveToNextQuestion() {
    // Add a confirmation dialog or logic here
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content:
              Text('Are you sure you want to proceed to the next question?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _nextQuestion();
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  int? _getGroupValue(String category) {
    List<Answer> answers = category == 'Anxiety'
        ? Provider.of<UserData>(context).anxietyAnswers
        : Provider.of<UserData>(context).depressionAnswers;

    if (answers.isEmpty) {
      return null;
    }

    return answers.last.score;
  }

  void _answerQuestion(int score, String category) {
    int? selectedAnswer = category == 'Anxiety'
        ? selectedAnswerAnxiety
        : selectedAnswerDepression;

    Answer answer = Answer(
      question: category == 'Anxiety'
          ? questionnaire.anxietyQuestions[currentAnxietyIndex]
          : questionnaire.depressionQuestions[currentDepressionIndex],
      score: score,
    );

    Provider.of<UserData>(context, listen: false).addAnswer(answer, category);

    if (category == 'Anxiety') {
      if (currentAnxietyIndex < questionnaire.anxietyQuestions.length - 1) {
        setState(() {
          currentAnxietyIndex++;
          selectedAnswerAnxiety = null; // Reset selectedAnswer for anxiety
        });
      } else {
        setState(() {
          isAnxietyCompleted = true;
        });
      }
    } else if (category == 'Depression') {
      if (currentDepressionIndex <
          questionnaire.depressionQuestions.length - 1) {
        setState(() {
          currentDepressionIndex++;
          selectedAnswerDepression =
              null; // Reset selectedAnswer for depression
        });
      } else {
        setState(() {
          isDepressionCompleted = true;
        });
      }
    }
  }

  void _nextQuestion() {
    if (currentAnxietyIndex < questionnaire.anxietyQuestions.length - 1) {
      setState(() {
        currentAnxietyIndex++;
        selectedAnswerAnxiety = null; // Reset selectedAnswer for anxiety
      });
    } else {
      if (currentDepressionIndex <
          questionnaire.depressionQuestions.length - 1) {
        setState(() {
          currentDepressionIndex++;
          selectedAnswerDepression =
              null; // Reset selectedAnswer for depression
        });
      } else {
        setState(() {
          selectedAnswer = null;
        });
      }
    }
  }

  void _calculateScoreAndShowSummary() {
    List<Answer> anxietyAnswers =
        Provider.of<UserData>(context, listen: false).anxietyAnswers;
    List<Answer> depressionAnswers =
        Provider.of<UserData>(context, listen: false).depressionAnswers;

    int anxietyScore = _calculateCategoryScore(anxietyAnswers);
    int depressionScore = _calculateCategoryScore(depressionAnswers);

    String anxietyResult = _interpretScore(anxietyScore, 'Anxiety');
    String depressionResult = _interpretScore(depressionScore, 'Depression');

// Display the summary
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Summary'),
          content: Column(
            children: [
              Text('Anxiety Score: $anxietyScore - $anxietyResult'),
              Text('Depression Score: $depressionScore - $depressionResult'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(
                    context); // Navigate back to UserTypeSelectionScreen
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Summary'),
          content: Column(
            children: [
              Text('Anxiety Score: $anxietyScore - $anxietyResult'),
              Text('Depression Score: $depressionScore - $depressionResult'),
              SizedBox(height: 20),
              _buildScoreChart(anxietyScore, depressionScore),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

int _calculateCategoryScore(List<Answer> answers) {
  int score = 0;
  for (Answer answer in answers) {
    score += answer.score;
  }
  return score;
}

String _interpretScore(int score, String category) {
  String result = '';
  if (category == 'Anxiety') {
    if (score <= 7) {
      result = 'Normal';
    } else if (score <= 14) {
      result = 'Mild Anxiety';
    } else if (score <= 21) {
      result = 'Moderate Anxiety';
    } else {
      result = 'Severe Anxiety';
    }
  } else if (category == 'Depression') {
    if (score <= 9) {
      result = 'Normal';
    } else if (score <= 18) {
      result = 'Mild Depression';
    } else if (score <= 27) {
      result = 'Moderate Depression';
    } else {
      result = 'Severe Depression';
    }
  }
  return result;
}

Widget _buildScoreChart(int anxietyScore, int depressionScore) {
  return Container(
    height: 200,
    child: SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: [
        BarSeries<ChartData, String>(
          dataSource: [
            ChartData('Anxiety', anxietyScore),
            ChartData('Depression', depressionScore),
          ],
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.score,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    ),
  );
}

class ChartData {
  final String category;
  final int score;

  ChartData(this.category, this.score);
}
