import 'package:flutter/material.dart';

import 'pet_state.dart';

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
  State<DigitalPetScreen> createState() =>
      _DigitalPetScreenState();
}

class _DigitalPetScreenState extends State<DigitalPetScreen> {
  late final PetState pet;

  @override
  void initState() {
    super.initState();

    pet = PetState();
    pet.addListener(_petChanged);
    pet.start();
  }

  void _petChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    pet.removeListener(_petChanged);
    pet.dispose();

    super.dispose();
  }

  Color get moodColor {
    if (pet.happiness > 70) {
      return Colors.green;
    }

    if (pet.happiness >= 30) {
      return Colors.amber;
    }

    return Colors.red;
  }

  String get petEmoji {
    if (pet.hasWon) {
      return '🏆';
    }

    if (pet.gameOver) {
      return '😴';
    }

    if (pet.happiness > 70) {
      return '🐶';
    }

    if (pet.happiness < 30) {
      return '🥺';
    }

    return '🐕';
  }

  Widget buildMeter({
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

  @override
  Widget build(BuildContext context) {
    final disabled = pet.gameOver || pet.hasWon;

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
              Text(
                pet.petName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                pet.hasWon
                    ? 'Best day ever!'
                    : pet.gameOver
                        ? 'I need a rest.'
                        : '${pet.mood} pet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: moodColor,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                petEmoji,
                style: const TextStyle(
                  fontSize: 100,
                ),
              ),

              const SizedBox(height: 24),

              buildMeter(
                label: 'Happiness',
                value: pet.happiness,
                icon: Icons.favorite,
              ),

              buildMeter(
                label: 'Hunger',
                value: pet.hunger,
                icon: Icons.restaurant,
              ),

              buildMeter(
                label: 'Energy',
                value: pet.energy,
                icon: Icons.bolt,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: disabled ? null : pet.feed,
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Feed'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: disabled ? null : pet.play,
                      icon: const Icon(
                        Icons.sports_tennis,
                      ),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: pet.reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),

              const SizedBox(height: 20),

              Text(
                pet.gameOver
                    ? 'Game over. Press Reset to play again.'
                    : pet.hasWon
                        ? 'Your pet stayed happy for three minutes!'
                        : 'Keep your pet happy and well fed.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}