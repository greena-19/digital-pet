class PetGame {
  String petName;

  int happiness;
  int hunger;
  int energy;

  bool gameOver;
  bool hasWon;

  PetGame({
    this.petName = 'Pip',
    this.happiness = 50,
    this.hunger = 50,
    this.energy = 70,
    this.gameOver = false,
    this.hasWon = false,
  });

  int _clamp(int value) {
    return value.clamp(0, 100).toInt();
  }

  String get moodLabel {
    if (happiness > 70) return 'Happy';
    if (happiness >= 30) return 'Neutral';
    return 'Unhappy';
  }

  double get petScale {
    if (happiness > 70) return 1.06;
    if (happiness < 30) return 0.94;
    return 1.0;
  }

  String get petMessage {
    if (gameOver) return 'I need a rest.';
    if (hasWon) return 'Best day ever!';
    if (hunger > 80) return "I'm starving!";
    if (happiness <= 30) return 'Play with me?';
    if (energy < 20) return 'So sleepy...';
    if (happiness > 70) return "I'm feeling great!";

    return "Hi, I'm $petName!";
  }

  void setName(String name) {
    if (name.trim().isNotEmpty) {
      petName = name.trim();
    }
  }

  void feed() {
    if (gameOver || hasWon) return;

    final nextHunger = _clamp(hunger - 10);

    final happinessChange =
        nextHunger < 30 ? -20 : 10;

    hunger = nextHunger;

    happiness = _clamp(
      happiness + happinessChange,
    );
  }

  bool play() {
    if (gameOver || hasWon) return false;

    if (energy < 10) {
      return false;
    }

    happiness = _clamp(happiness + 15);
    hunger = _clamp(hunger + 5);
    energy = _clamp(energy - 10);

    return true;
  }

  bool run() {
    if (gameOver || hasWon) return false;

    if (energy < 20) {
      return false;
    }

    happiness = _clamp(happiness + 10);
    hunger = _clamp(hunger + 10);
    energy = _clamp(energy - 20);

    return true;
  }

  void sleep() {
    if (gameOver || hasWon) return;

    energy = _clamp(energy + 30);
    hunger = _clamp(hunger + 5);
  }

  void hungerTick() {
    if (gameOver || hasWon) return;

    if (hunger + 5 > 100) {
      hunger = 100;
      happiness = _clamp(happiness - 20);
    } else {
      hunger = _clamp(hunger + 5);
    }

    checkLoss();
  }

  bool checkLoss() {
    if (hunger == 100 && happiness <= 10) {
      gameOver = true;
      return true;
    }

    return false;
  }

  void win() {
    if (!gameOver && happiness > 80) {
      hasWon = true;
    }
  }

  void reset() {
    happiness = 50;
    hunger = 50;
    energy = 70;

    gameOver = false;
    hasWon = false;
  }
}