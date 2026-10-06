import 'dart:async';
import 'package:flutter/material.dart';
import 'models/pet_game.dart';

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
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

class _DigitalPetScreenState
    extends State<DigitalPetScreen> {
  final PetGame pet = PetGame();

  late final TextEditingController _nameController;

  Timer? _hungerTimer;
  Timer? _winTimer;
  Timer? _bounceTimer;
  Timer? _reactionTimer;

  bool _actionBounce = false;
  String? _reaction;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: pet.petName,
    );

    _startHungerTimer();
  }

  // ----------------------------------------------------------
  // MOOD COLOR
  // ----------------------------------------------------------

  Color get moodColor {
    if (pet.happiness > 70) {
      return Colors.green;
    }

    if (pet.happiness >= 30) {
      return Colors.amber;
    }

    return Colors.red;
  }

  // ----------------------------------------------------------
  // MOOD ICON
  // ----------------------------------------------------------

  IconData get moodIcon {
    if (pet.happiness > 70) {
      return Icons.sentiment_very_satisfied;
    }

    if (pet.happiness >= 30) {
      return Icons.sentiment_neutral;
    }

    return Icons.sentiment_very_dissatisfied;
  }

  // ----------------------------------------------------------
  // HUNGER TIMER
  // ----------------------------------------------------------

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (!mounted || pet.gameOver || pet.hasWon) {
          return;
        }

        setState(() {
          pet.hungerTick();
        });

        _checkOutcome();
      },
    );
  }

  // ----------------------------------------------------------
  // WIN / LOSS
  // ----------------------------------------------------------

  void _checkOutcome() {
    if (pet.gameOver) {
      _winTimer?.cancel();
      _winTimer = null;
      _hungerTimer?.cancel();
      return;
    }

    // Happiness must remain strictly above 80.
    if (pet.happiness <= 80) {
      _winTimer?.cancel();
      _winTimer = null;
      return;
    }

    // Do not restart the timer if already running.
    if (_winTimer != null) {
      return;
    }

    _winTimer = Timer(
      const Duration(minutes: 3),
      () {
        _winTimer = null;

        if (!mounted ||
            pet.gameOver ||
            pet.happiness <= 80) {
          return;
        }

        setState(() {
          pet.win();
        });

        if (pet.hasWon) {
          _hungerTimer?.cancel();
        }
      },
    );
  }

  // ----------------------------------------------------------
  // SET PET NAME
  // ----------------------------------------------------------

  void _setPetName() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a pet name.',
          ),
        ),
      );
      return;
    }

    setState(() {
      pet.setName(name);
    });

    FocusScope.of(context).unfocus();
  }

  // ----------------------------------------------------------
  // FEED
  // ----------------------------------------------------------

  void _feed() {
    if (pet.gameOver || pet.hasWon) {
      return;
    }

    setState(() {
      pet.feed();
    });

    _showReaction('🍖');
    _bouncePet();
    _checkOutcome();
  }

  // ----------------------------------------------------------
  // PLAY
  // ----------------------------------------------------------

  void _play() {
    if (pet.gameOver || pet.hasWon) {
      return;
    }

    final success = pet.play();

    if (!success) {
      _showReaction('😴');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${pet.petName} needs more energy to play.',
          ),
        ),
      );

      return;
    }

    setState(() {});

    _showReaction('🎾');
    _bouncePet();
    _checkOutcome();
  }

  // ----------------------------------------------------------
  // RUN
  // ----------------------------------------------------------

  void _run() {
    if (pet.gameOver || pet.hasWon) {
      return;
    }

    final success = pet.run();

    if (!success) {
      _showReaction('😴');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${pet.petName} does not have enough energy to run.',
          ),
        ),
      );

      return;
    }

    setState(() {});

    _showReaction('🏃');
    _bouncePet();
    _checkOutcome();
  }

  // ----------------------------------------------------------
  // SLEEP
  // ----------------------------------------------------------

  void _sleep() {
    if (pet.gameOver || pet.hasWon) {
      return;
    }

    setState(() {
      pet.sleep();
    });

    _showReaction('💤');
    _checkOutcome();
  }

  // ----------------------------------------------------------
  // RESET
  // ----------------------------------------------------------

  void _reset() {
    _winTimer?.cancel();
    _winTimer = null;

    _bounceTimer?.cancel();
    _reactionTimer?.cancel();

    setState(() {
      pet.reset();

      _reaction = null;
      _actionBounce = false;
    });

    _startHungerTimer();
  }

  // ----------------------------------------------------------
  // BOUNCE ANIMATION
  // ----------------------------------------------------------

  void _bouncePet() {
    _bounceTimer?.cancel();

    setState(() {
      _actionBounce = true;
    });

    _bounceTimer = Timer(
      const Duration(milliseconds: 220),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _actionBounce = false;
        });
      },
    );
  }

  // ----------------------------------------------------------
  // REACTION EMOJI
  // ----------------------------------------------------------

  void _showReaction(String reaction) {
    _reactionTimer?.cancel();

    setState(() {
      _reaction = reaction;
    });

    _reactionTimer = Timer(
      const Duration(milliseconds: 900),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _reaction = null;
        });
      },
    );
  }

  // ----------------------------------------------------------
  // STATUS METER
  // ----------------------------------------------------------

  Widget _buildMeter({
    required String label,
    required int value,
    required bool reduceMotion,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$value / 100',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              end: value / 100,
            ),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(
                    milliseconds: 400,
                  ),
            curve: Curves.easeOut,
            builder: (
              context,
              animatedValue,
              child,
            ) {
              return LinearProgressIndicator(
                value: animatedValue,
                minHeight: 10,
                borderRadius:
                    BorderRadius.circular(10),
              );
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ACTION BUTTON
  // ----------------------------------------------------------

  Widget _actionButton({
    required String text,
    required IconData icon,
    required VoidCallback action,
  }) {
    return Expanded(
      child: FilledButton.icon(
        onPressed:
            pet.gameOver || pet.hasWon
                ? null
                : action,
        icon: Icon(icon),
        label: Text(text),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CLEAN UP
  // ----------------------------------------------------------

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _bounceTimer?.cancel();
    _reactionTimer?.cancel();

    _nameController.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    final displayScale =
        pet.petScale *
        (_actionBounce && !reduceMotion
            ? 1.10
            : 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Digital Pet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),

          child: Column(
            children: [
              // ============================================
              // PET PNG IMAGE
              // ============================================

              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      scale: displayScale,
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(
                              milliseconds: 180,
                            ),
                      curve: Curves.easeOutBack,

                      child: ColorFiltered(
                        colorFilter:
                            ColorFilter.mode(
                          moodColor,
                          BlendMode.modulate,
                        ),

                        child: Image.asset(
                          'assets/pet.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,

                          errorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) {
                            return const Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 80,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Pet image not found',
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // Reaction emoji
                    Positioned(
                      top: 5,
                      right: 55,

                      child: AnimatedSwitcher(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(
                                milliseconds: 200,
                              ),

                        child: _reaction == null
                            ? const SizedBox(
                                key: ValueKey(
                                  'empty',
                                ),
                              )
                            : Text(
                                _reaction!,
                                key: ValueKey(
                                  _reaction,
                                ),
                                style:
                                    const TextStyle(
                                  fontSize: 40,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // PET SPEECH
              // ============================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: AnimatedSwitcher(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(
                          milliseconds: 300,
                        ),

                  child: Text(
                    pet.petMessage,
                    key: ValueKey(
                      pet.petMessage,
                    ),
                    textAlign:
                        TextAlign.center,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ============================================
              // PET NAME
              // ============================================

              Text(
                pet.petName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _nameController,

                      textInputAction:
                          TextInputAction.done,

                      onSubmitted: (_) {
                        _setPetName();
                      },

                      decoration:
                          const InputDecoration(
                        labelText: 'Pet name',
                        hintText:
                            'Enter pet name',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  FilledButton(
                    onPressed:
                        _setPetName,
                    child:
                        const Text('Set'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ============================================
              // MOOD
              // ============================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    moodIcon,
                    color: moodColor,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Mood: ${pet.moodLabel}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: moodColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ============================================
              // METERS
              // ============================================

              _buildMeter(
                label: 'Happiness',
                value: pet.happiness,
                reduceMotion:
                    reduceMotion,
              ),

              _buildMeter(
                label: 'Hunger',
                value: pet.hunger,
                reduceMotion:
                    reduceMotion,
              ),

              _buildMeter(
                label: 'Energy',
                value: pet.energy,
                reduceMotion:
                    reduceMotion,
              ),

              const SizedBox(height: 22),

              // ============================================
              // FEED + PLAY
              // ============================================

              Row(
                children: [
                  _actionButton(
                    text: 'Feed',
                    icon:
                        Icons.restaurant,
                    action: _feed,
                  ),

                  const SizedBox(width: 12),

                  _actionButton(
                    text: 'Play',
                    icon: Icons
                        .sports_esports,
                    action: _play,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ============================================
              // RUN + SLEEP
              // ============================================

              Row(
                children: [
                  _actionButton(
                    text: 'Run',
                    icon: Icons
                        .directions_run,
                    action: _run,
                  ),

                  const SizedBox(width: 12),

                  _actionButton(
                    text: 'Sleep',
                    icon:
                        Icons.bedtime,
                    action: _sleep,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ============================================
              // RESET
              // ============================================

              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Reset Pet',
                ),
              ),

              const SizedBox(height: 18),

              // ============================================
              // WIN MESSAGE
              // ============================================

              if (pet.hasWon)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color:
                        Colors.green.shade100,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: const Text(
                    '🎉 YOU WIN!',
                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

              // ============================================
              // GAME OVER
              // ============================================

              if (pet.gameOver)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color:
                        Colors.red.shade100,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: const Text(
                    '💔 GAME OVER',
                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}