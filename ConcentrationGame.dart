import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Concentration Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConcentrationGame(),
    );
  }
}

class ConcentrationGame extends StatefulWidget {
  @override
  _ConcentrationGameState createState() => _ConcentrationGameState();
}

class _ConcentrationGameState extends State<ConcentrationGame> {
  final List<String> symbols = ['🍎', '🍌', '🍉', '🍇', '🍓', '🍒', '🥑', '🥥'];
  late List<String> cards;
  late List<bool> revealed;
  int? previousIndex;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    cards = List<String>.generate(16, (index) => '');
    revealed = List<bool>.filled(16, false);
    List<String> symbolsCopy = List.from(symbols)..addAll(symbols);
    symbolsCopy.shuffle();
    for (int i = 0; i < cards.length; i++) {
      cards[i] = symbolsCopy[i];
    }
    previousIndex = null;
  }

  void checkMatch(int index) {
    if (previousIndex == null) {
      // First card selection
      previousIndex = index;
    } else {
      // Second card selection
      if (cards[previousIndex!] == cards[index]) {
        // Match found
        revealed[previousIndex!] = true;
        revealed[index] = true;
      }
      previousIndex = null; // Reset previousIndex
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Concentration Game'),
      ),
      body: Center(
        child: GridView.builder(
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (!revealed[index]) {
                    checkMatch(index);
                  }
                });
              },
              child: Card(
                color: revealed[index] ? Colors.white : Colors.blue,
                child: Center(
                  child: Text(
                    revealed[index] ? cards[index] : '',
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
