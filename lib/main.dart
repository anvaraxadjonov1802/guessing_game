import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

void main() {
  runApp(GuessingGameApp());
}

class GuessingGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guessing Game',
      debugShowCheckedModeBanner : false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image1.png'), // Make sure the image is placed in the assets folder and update the pubspec.yaml accordingly
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 24, fontFamily: 'Roboto', letterSpacing: 2.0),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InitiatePage()),
                    );
                  },
                  child: Text('Start the Game'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 20, fontFamily: 'Roboto', letterSpacing: 2.0),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GuidePage()),
                    );
                  },
                  child: Text('How to Play'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GuidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How to Play'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Guessing Game Rules:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. Two players take turns to guess a number between a given range.',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '2. After each guess, the range is adjusted based on whether the guess was too high or too low.',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '3. The player who guesses the number correctly wins the round.',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '4. The game keeps track of each player\'s score.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 24),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Got it!'),
            ),
          ],
        ),
      ),
    );
  }
}

class InitiatePage extends StatefulWidget {
  @override
  _InitiatePageState createState() => _InitiatePageState();
}

class _InitiatePageState extends State<InitiatePage> {
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Player Names'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: player1Controller,
              decoration: InputDecoration(labelText: 'Player 1 Name'),
            ),
            TextField(
              controller: player2Controller,
              decoration: InputDecoration(labelText: 'Player 2 Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 24),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePage(
                      player1Name: player1Controller.text,
                      player2Name: player2Controller.text,
                    ),
                  ),
                );
              },
              child: Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final String player1Name;
  final String player2Name;

  GamePage({required this.player1Name, required this.player2Name});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final TextEditingController guessController = TextEditingController();
  int minRange = 1;
  int maxRange = 100;
  int randomNumber = Random().nextInt(100) + 1;
  bool isPlayer1Turn = true;
  int player1Score = 0;
  int player2Score = 0;
  int incorrectGuesses = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void checkGuess() {
    int guess = int.parse(guessController.text);
    setState(() {
      incorrectGuesses++;
      if (guess < randomNumber) {
        minRange = guess + 1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Too low! Try again.')),
        );
      } else if (guess > randomNumber) {
        maxRange = guess - 1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Too high! Try again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${isPlayer1Turn ? widget.player1Name : widget.player2Name} wins!'),
          ),
        );
        if (isPlayer1Turn) {
          player1Score++;
        } else {
          player2Score++;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              player1Name: widget.player1Name,
              player2Name: widget.player2Name,
              player1Score: player1Score,
              player2Score: player2Score,
            ),
          ),
        );
      }
      isPlayer1Turn = !isPlayer1Turn;
      guessController.clear();
    });
  }

  void provideHint() {
    if (incorrectGuesses >= 3) {
      int midPoint = (minRange + maxRange) ~/ 2;
      String hint = randomNumber < midPoint
          ? 'Try a number higher than $midPoint'
          : 'Try a number lower than $midPoint';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hint)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Make more guesses to get a hint!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guess the Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LinearProgressIndicator(
              value: (maxRange - minRange) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            ScaleTransition(
              scale: _animation,
              child: Text(
                'Range: $minRange - $maxRange',
                style: TextStyle(fontSize: 24),
              ),
            ),
            TextField(
              controller: guessController,
              decoration: InputDecoration(labelText: 'Enter your guess'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 24),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: checkGuess,
              child: Text('Submit Guess'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 24),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: provideHint,
              child: Text('Get Hint'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String player1Name;
  final String player2Name;
  final int player1Score;
  final int player2Score;

  ResultPage(
      {required this.player1Name,
      required this.player2Name,
      required this.player1Score,
      required this.player2Score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Scores:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '$player1Name: $player1Score',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '$player2Name: $player2Score',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 24),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
