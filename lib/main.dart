import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const DigitalPetScreen(),
    );
  }
}

class DigitalPetScreen extends StatefulWidget {
  const DigitalPetScreen({super.key});

  @override
  State<DigitalPetScreen> createState() => _DigitalPetScreenState();
}

class _DigitalPetScreenState extends State<DigitalPetScreen> {
  // ------------------------------------------------------------
  // PET STATE
  // ------------------------------------------------------------

  String _petName = 'Pip';

  int _happiness = 50;
  int _hunger = 50;
  int _energy = 70;

  bool _gameOver = false;
  bool _hasWon = false;

  // ------------------------------------------------------------
  // TIMERS
  // ------------------------------------------------------------

  Timer? _hungerTimer;
  Timer? _winTimer;

  // ------------------------------------------------------------
  // HELPER
  // ------------------------------------------------------------

  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  // ------------------------------------------------------------
  // DERIVED STATE
  // ------------------------------------------------------------

  String get _mood {
    if (_happiness > 70) {
      return 'Happy';
    }

    if (_happiness >= 30) {
      return 'Neutral';
    }

    return 'Unhappy';
  }

  Color get _moodColor {
    if (_happiness > 70) {
      return Colors.green;
    }

    if (_happiness >= 30) {
      return Colors.amber;
    }

    return Colors.red;
  }

  String get _petEmoji {
    if (_hasWon) {
      return '🏆';
    }

    if (_gameOver) {
      return '😴';
    }

    if (_happiness > 70) {
      return '🐶';
    }

    if (_happiness < 30) {
      return '🥺';
    }

    return '🐕';
  }

  // ------------------------------------------------------------
  // FEED
  // ------------------------------------------------------------

  void _feedPet() {
    if (_gameOver || _hasWon) {
      return;
    }

    setState(() {
      // Feeding reduces hunger.
      _hunger = _clampMeter(_hunger - 10);

      // If the resulting hunger is below 30,
      // feeding decreases happiness by 20.
      //
      // Otherwise, feeding increases happiness by 10.
      if (_hunger < 30) {
        _happiness = _clampMeter(_happiness - 20);
      } else {
        _happiness = _clampMeter(_happiness + 10);
      }

      // Feeding gives a small amount of energy.
      _energy = _clampMeter(_energy + 5);
    });

    _updateOutcome();
  }

  // ------------------------------------------------------------
  // PLAY
  // ------------------------------------------------------------

  void _playWithPet() {
    if (_gameOver || _hasWon) {
      return;
    }

    setState(() {
      // Playing increases happiness.
      _happiness = _clampMeter(_happiness + 15);

      // Playing makes the pet a little more hungry.
      _hunger = _clampMeter(_hunger + 5);

      // Playing uses energy.
      _energy = _clampMeter(_energy - 10);
    });

    _updateOutcome();
  }

  // ------------------------------------------------------------
  // RESET
  // ------------------------------------------------------------

  void _resetPet() {
    // Cancel any existing win timer.
    _winTimer?.cancel();
    _winTimer = null;

    setState(() {
      _petName = 'Pip';

      _happiness = 50;
      _hunger = 50;
      _energy = 70;

      _gameOver = false;
      _hasWon = false;
    });

    // Make sure exactly one hunger timer is active.
    _startHungerTimer();
  }

  // ------------------------------------------------------------
  // OUTCOME LOGIC
  // ------------------------------------------------------------

  void _updateOutcome() {
    if (_gameOver || _hasWon) {
      return;
    }

    // ----------------------------------------------------------
    // LOSS CONDITION
    //
    // Game over when:
    // hunger == 100
    // AND
    // happiness <= 10
    // ----------------------------------------------------------

    if (_hunger == 100 && _happiness <= 10) {
      _winTimer?.cancel();
      _winTimer = null;

      _hungerTimer?.cancel();

      setState(() {
        _gameOver = true;
      });

      return;
    }

    // ----------------------------------------------------------
    // WIN TIMER CANCELLATION
    //
    // Happiness must be STRICTLY greater than 80.
    //
    // If happiness becomes 80 or lower,
    // cancel the pending win timer.
    // ----------------------------------------------------------

    if (_happiness <= 80) {
      _winTimer?.cancel();
      _winTimer = null;
      return;
    }

    // ----------------------------------------------------------
    // START WIN TIMER
    //
    // Happiness is now > 80.
    //
    // Start the three-minute timer only if one
    // is not already running.
    // ----------------------------------------------------------

    _winTimer ??= Timer(
      const Duration(minutes: 3),
      () {
        _winTimer = null;

        if (!mounted || _gameOver || _happiness <= 80) {
          return;
        }

        setState(() {
          _hasWon = true;
        });

        // Stop hunger timer after winning.
        _hungerTimer?.cancel();
      },
    );
  }

  // ------------------------------------------------------------
  // HUNGER TIMER
  // ------------------------------------------------------------

  void _startHungerTimer() {
    // Cancel an existing timer first.
    _hungerTimer?.cancel();

    // Create exactly one hunger timer.
    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!mounted || _gameOver || _hasWon) {
          timer.cancel();
          return;
        }

        setState(() {
          // Normal hunger increase.
          if (_hunger < 100) {
            _hunger = _clampMeter(_hunger + 5);
          } else {
            // If hunger is already 100,
            // another tick keeps hunger at 100
            // and reduces happiness by 20.
            _hunger = 100;
            _happiness = _clampMeter(_happiness - 20);
          }
        });

        _updateOutcome();
      },
    );
  }

  // ------------------------------------------------------------
  // LIFECYCLE
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Start the hunger timer once.
    _startHungerTimer();
  }

  @override
  void dispose() {
    // Cancel timers when leaving the screen.
    _hungerTimer?.cancel();
    _winTimer?.cancel();

    super.dispose();
  }

  // ------------------------------------------------------------
  // METER WIDGET
  // ------------------------------------------------------------

  Widget _buildMeter({
    required String label,
    required int value,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$value / 100',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: value / 100,
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final actionsDisabled = _gameOver || _hasWon;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              // ------------------------------------------------
              // PET NAME
              // ------------------------------------------------

              Text(
                _petName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // ------------------------------------------------
              // MOOD
              // ------------------------------------------------

              Text(
                _hasWon
                    ? 'Best day ever!'
                    : _gameOver
                        ? 'I need a rest.'
                        : '$_mood pet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _moodColor,
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // TEMPORARY PET DISPLAY
              //
              // Team 2 can replace this with the actual
              // ColorFiltered pet asset later.
              // ------------------------------------------------

              Text(
                _petEmoji,
                style: const TextStyle(
                  fontSize: 100,
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // HAPPINESS
              // ------------------------------------------------

              _buildMeter(
                label: 'Happiness',
                value: _happiness,
                icon: Icons.favorite,
              ),

              // ------------------------------------------------
              // HUNGER
              // ------------------------------------------------

              _buildMeter(
                label: 'Hunger',
                value: _hunger,
                icon: Icons.restaurant,
              ),

              // ------------------------------------------------
              // ENERGY
              // ------------------------------------------------

              _buildMeter(
                label: 'Energy',
                value: _energy,
                icon: Icons.bolt,
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // FEED + PLAY
              // ------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: actionsDisabled
                          ? null
                          : _feedPet,
                      icon: const Icon(
                        Icons.restaurant,
                      ),
                      label: const Text('Feed'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: actionsDisabled
                          ? null
                          : _playWithPet,
                      icon: const Icon(
                        Icons.sports_tennis,
                      ),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // RESET
              // ------------------------------------------------

              OutlinedButton.icon(
                onPressed: _resetPet,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // STATUS MESSAGE
              // ------------------------------------------------

              Text(
                _gameOver
                    ? 'Game over. Press Reset to care for your pet again.'
                    : _hasWon
                        ? 'Your pet stayed happy for three continuous minutes!'
                        : 'Keep your pet happy and well fed.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}