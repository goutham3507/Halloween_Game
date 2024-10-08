import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(SpookyHalloweenGame());
}

class SpookyHalloweenGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spooky Halloween Game',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: SpookyHomePage(),
    );
  }
}

class SpookyHomePage extends StatefulWidget {
  @override
  _SpookyHomePageState createState() => _SpookyHomePageState();
}

class _SpookyHomePageState extends State<SpookyHomePage> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  bool _gameWon = false;
  bool _showJumpScare = false; // Flag to show/hide jump scare image
  int _correctIndex = Random().nextInt(6); // Randomly selects the correct item
  Timer? _timer;
  
  // List of spooky items (emojis can be placeholders for images)
  List<String> spookyItems = ['👻', '🎃', '🦇', '🕸️', '🕷️', '💀'];
  List<bool> traps = [false, true, false, true, false, true]; // Some items are traps

  @override
  void initState() {
    super.initState();
    _audioPlayer.setLoopMode(LoopMode.one); // Loop the background music
    _playBackgroundMusic();

    // Timer for random movement of items
    _timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {});
    });
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.setAsset('assets/background.mp3'); // Play the background music from local assets
      _audioPlayer.play();
    } catch (e) {
      print("Error playing background music: $e");
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath); // Play sound from local assets
      _audioPlayer.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _handleItemClick(int index) {
    if (index == _correctIndex) {
      // Correct item found
      setState(() {
        _gameWon = true;
      });
      _playSound('assets/success.mp3'); // Play success sound
    } else if (traps[index]) {
      // Trap sound
      _playSound('assets/jumpscare.mp3'); // Play jump scare sound
      _showJumpScareImage(); // Trigger jump scare image
    } else {
      // Wrong item sound
      _playSound('assets/wrong.mp3'); // Play wrong choice sound
    }
  }

  void _showJumpScareImage() {
    setState(() {
      _showJumpScare = true; // Show the jump scare image
    });
    // Hide the image after 2 seconds
    Timer(Duration(seconds: 2), () {
      setState(() {
        _showJumpScare = false; // Hide the jump scare image
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Clean up audio resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Spooky Halloween Game'),
        backgroundColor: Colors.orange[900],
      ),
      body: Stack(
        children: [
          // Game items
          Center(
            child: Stack(
              children: [
                for (int i = 0; i < spookyItems.length; i++)
                  AnimatedPositioned(
                    left: Random().nextDouble() * MediaQuery.of(context).size.width * 0.8, // Randomize left position
                    top: Random().nextDouble() * MediaQuery.of(context).size.height * 0.7, // Randomize top position
                    duration: Duration(seconds: 2),
                    child: GestureDetector(
                      onTap: () => _handleItemClick(i),
                      child: AnimatedOpacity(
                        opacity: traps[i] ? 0.8 : 1.0,
                        duration: Duration(seconds: 1),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: traps[i] ? Colors.red.withOpacity(0.7) : Colors.orange.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: traps[i] ? Colors.red : Colors.orangeAccent,
                                blurRadius: traps[i] ? 20 : 10,
                                spreadRadius: traps[i] ? 10 : 5,
                              ),
                            ],
                          ),
                          child: Text(
                            spookyItems[i],
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Visibility widget for the jump scare image
          Visibility(
            visible: _showJumpScare,
            child: Center(
              child: Image.asset(
                'assets/jumpscare_image.png', // Add your scary image here
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
              ),
            ),
          ),
          if (_gameWon)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🎉 You Found It! 🎉',
                    style: TextStyle(color: Colors.orange, fontSize: 40),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Happy Halloween! 👻',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
