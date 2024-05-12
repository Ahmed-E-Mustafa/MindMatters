import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relaxation Breathing Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RelaxationBreathingGame(),
    );
  }
}

class RelaxationBreathingGame extends StatefulWidget {
  @override
  _RelaxationBreathingGameState createState() =>
      _RelaxationBreathingGameState();
}

class _RelaxationBreathingGameState extends State<RelaxationBreathingGame> {
  bool breathingIn = false;
  int score = 0;
  BreathingDifficulty difficulty = BreathingDifficulty.Easy;
  AchievementManager achievementManager = AchievementManager();
  Timer? breathingTimer;

  @override
  void dispose() {
    breathingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relaxation Breathing Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              width: breathingIn ? 200 : 100,
              height: breathingIn ? 200 : 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Text(
              breathingIn ? 'Breathe In' : 'Breathe Out',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: breathingTimer != null ? null : startBreathing,
                  child: Text('Start Breathing'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: stopBreathing,
                  child: Text('Stop'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            DropdownButton<BreathingDifficulty>(
              value: difficulty,
              onChanged: (value) {
                setState(() {
                  difficulty = value!;
                });
              },
              items: BreathingDifficulty.values
                  .map((difficulty) => DropdownMenuItem<BreathingDifficulty>(
                        value: difficulty,
                        child: Text(difficulty.toString().split('.').last),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: achievementManager.unlockedAchievements.length,
                itemBuilder: (context, index) {
                  var achievement =
                      achievementManager.unlockedAchievements[index];
                  return ListTile(
                    title: Text(achievement.name),
                    subtitle: Text(achievement.description),
                    leading: Icon(Icons.star),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startBreathing() {
    setState(() {
      breathingIn = true;
      breathingTimer =
          Timer(Duration(milliseconds: inhaleDuration(difficulty)), () {
        setState(() {
          breathingIn = false;
          score++;
          achievementManager.updateAchievements(score);
          breathingTimer = Timer(
              Duration(milliseconds: exhaleDuration(difficulty)),
              startBreathing);
        });
      });
    });
  }

  void stopBreathing() {
    setState(() {
      breathingIn = false;
      breathingTimer?.cancel();
      breathingTimer = null;
      score = 0; // Reset score to 0 after stopping breathing
    });
  }
}

enum BreathingDifficulty {
  Easy,
  Medium,
  Hard,
}

int inhaleDuration(BreathingDifficulty difficulty) {
  switch (difficulty) {
    case BreathingDifficulty.Easy:
      return 4000; // 4 seconds
    case BreathingDifficulty.Medium:
      return 3000; // 3 seconds
    case BreathingDifficulty.Hard:
      return 2000; // 2 seconds
  }
}

int exhaleDuration(BreathingDifficulty difficulty) {
  switch (difficulty) {
    case BreathingDifficulty.Easy:
      return 4000; // 4 seconds
    case BreathingDifficulty.Medium:
      return 3000; // 3 seconds
    case BreathingDifficulty.Hard:
      return 2000; // 2 seconds
  }
}

class Achievement {
  final String name;
  final String description;
  final int requiredScore;

  Achievement({
    required this.name,
    required this.description,
    required this.requiredScore,
  });
}

class AchievementManager {
  List<Achievement> achievements = [
    Achievement(
      name: 'Breathing Novice',
      description: 'Complete 10 breathing sessions',
      requiredScore: 10,
    ),
    Achievement(
      name: 'Breathing Master',
      description: 'Achieve a streak of 30 breathing sessions',
      requiredScore: 30,
    ),
    Achievement(
      name: 'Breathing Guru',
      description: 'Achieve a streak of 50 breathing sessions',
      requiredScore: 50,
    ),
  ];

  List<Achievement> unlockedAchievements = [];

  void updateAchievements(int score) {
    for (var achievement in achievements) {
      if (score >= achievement.requiredScore &&
          !unlockedAchievements.contains(achievement)) {
        unlockedAchievements.add(achievement);
// Show achievement notification
// You can add additional logic here for rewarding the user
      }
    }
  }
}
