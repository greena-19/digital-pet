import 'dart:async';

import 'package:flutter/foundation.dart';

class PetState extends ChangeNotifier {
  String petName = 'Pip';

  int happiness = 50;
  int hunger = 50;
  int energy = 70;

  bool gameOver = false;
  bool hasWon = false;

  Timer? _hungerTimer;
  Timer? _winTimer;

  int clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  String get mood {
    if (happiness > 70) {
      return 'Happy';
    }

    if (happiness >= 30) {
      return 'Neutral';
    }

    return 'Unhappy';
  }

  void feed() {
    if (gameOver || hasWon) {
      return;
    }

    final nextHunger = clampMeter(hunger - 10);

    final happinessChange = nextHunger < 30 ? -20 : 10;

    final nextHappiness =
        clampMeter(happiness + happinessChange);

    final nextEnergy = clampMeter(energy + 5);

    hunger = nextHunger;
    happiness = nextHappiness;
    energy = nextEnergy;

    notifyListeners();

    updateOutcome();
  }

  void play() {
    if (gameOver || hasWon) {
      return;
    }

    happiness = clampMeter(happiness + 15);
    hunger = clampMeter(hunger + 5);
    energy = clampMeter(energy - 10);

    notifyListeners();

    updateOutcome();
  }

  void reset() {
    _winTimer?.cancel();
    _winTimer = null;

    hunger = 50;
    happiness = 50;
    energy = 70;

    gameOver = false;
    hasWon = false;

    notifyListeners();

    startHungerTimer();
  }

  void updateOutcome() {
    if (gameOver || hasWon) {
      return;
    }

    // Loss condition.
    if (hunger == 100 && happiness <= 10) {
      _winTimer?.cancel();
      _winTimer = null;

      _hungerTimer?.cancel();

      gameOver = true;

      notifyListeners();

      return;
    }

    // Happiness must be strictly greater than 80.
    if (happiness <= 80) {
      _winTimer?.cancel();
      _winTimer = null;

      return;
    }

    // Start the three-minute timer only once.
    _winTimer ??= Timer(
      const Duration(minutes: 3),
      () {
        _winTimer = null;

        if (gameOver || happiness <= 80) {
          return;
        }

        hasWon = true;

        _hungerTimer?.cancel();

        notifyListeners();
      },
    );
  }

  void startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (gameOver || hasWon) {
          timer.cancel();
          return;
        }

        if (hunger + 5 > 100) {
          hunger = 100;
          happiness = clampMeter(happiness - 20);
        } else {
          hunger += 5;
        }

        notifyListeners();

        updateOutcome();
      },
    );
  }

  void start() {
    startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();

    super.dispose();
  }
}