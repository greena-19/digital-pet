import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:digital_pet/pet_state.dart';

void main() {
  group('PetState basic behavior', () {
    test('pet starts with correct values', () {
      final pet = PetState();

      expect(pet.happiness, 50);
      expect(pet.hunger, 50);
      expect(pet.energy, 70);
      expect(pet.gameOver, false);
      expect(pet.hasWon, false);

      pet.dispose();
    });

    test('feed changes happiness, hunger, and energy', () {
      final pet = PetState();

      pet.feed();

      expect(pet.happiness, 60);
      expect(pet.hunger, 40);
      expect(pet.energy, 75);

      pet.dispose();
    });

    test('play changes happiness, hunger, and energy', () {
      final pet = PetState();

      pet.play();

      expect(pet.happiness, 65);
      expect(pet.hunger, 55);
      expect(pet.energy, 60);

      pet.dispose();
    });

    test('reset restores the initial state', () {
      final pet = PetState();

      pet.play();
      pet.play();

      expect(pet.happiness, 80);
      expect(pet.hunger, 60);
      expect(pet.energy, 50);

      pet.reset();

      expect(pet.happiness, 50);
      expect(pet.hunger, 50);
      expect(pet.energy, 70);
      expect(pet.gameOver, false);
      expect(pet.hasWon, false);

      pet.dispose();
    });
  });

  group('Meter boundaries', () {
    test('clampMeter never goes below zero', () {
      final pet = PetState();

      expect(pet.clampMeter(-10), 0);
      expect(pet.clampMeter(-100), 0);

      pet.dispose();
    });

    test('clampMeter never goes above 100', () {
      final pet = PetState();

      expect(pet.clampMeter(110), 100);
      expect(pet.clampMeter(500), 100);

      pet.dispose();
    });

    test('clampMeter preserves values inside the valid range', () {
      final pet = PetState();

      expect(pet.clampMeter(0), 0);
      expect(pet.clampMeter(50), 50);
      expect(pet.clampMeter(100), 100);

      pet.dispose();
    });

    test('play cannot reduce energy below zero', () {
      final pet = PetState();

      for (var i = 0; i < 10; i++) {
        pet.play();
      }

      expect(pet.energy, 0);

      pet.dispose();
    });
  });

  group('Feed behavior', () {
    test('feeding when resulting hunger is below 30 reduces happiness', () {
      final pet = PetState();

      pet.hunger = 35;
      pet.happiness = 50;
      pet.energy = 70;

      pet.feed();

      // Hunger: 35 -> 25
      // Because resulting hunger is below 30,
      // happiness decreases by 20.
      expect(pet.hunger, 25);
      expect(pet.happiness, 30);
      expect(pet.energy, 75);

      pet.dispose();
    });
  });

  group('Hunger timer', () {
    test('hunger increases by 5 every 30 seconds', () {
      fakeAsync((async) {
        final pet = PetState();

        pet.start();

        expect(pet.hunger, 50);

        async.elapse(const Duration(seconds: 30));

        expect(pet.hunger, 55);

        async.elapse(const Duration(seconds: 30));

        expect(pet.hunger, 60);

        pet.dispose();
      });
    });

    test('hunger reaches 100 without penalty on the 95 to 100 tick', () {
      fakeAsync((async) {
        final pet = PetState();

        pet.hunger = 95;
        pet.happiness = 50;

        pet.start();

        async.elapse(const Duration(seconds: 30));

        expect(pet.hunger, 100);
        expect(pet.happiness, 50);

        pet.dispose();
      });
    });

    test('hunger overflow at 100 reduces happiness by 20', () {
      fakeAsync((async) {
        final pet = PetState();

        pet.hunger = 100;
        pet.happiness = 50;

        pet.start();

        async.elapse(const Duration(seconds: 30));

        expect(pet.hunger, 100);
        expect(pet.happiness, 30);

        pet.dispose();
      });
    });
  });

  group('Win condition', () {
    test('happiness of exactly 80 does not start a win', () {
      fakeAsync((async) {
        final pet = PetState();

        pet.happiness = 80;
        pet.updateOutcome();

        async.elapse(const Duration(minutes: 3));

        expect(pet.hasWon, false);

        pet.dispose();
      });
    });

    test('happiness above 80 for three minutes wins', () {
      fakeAsync((async) {
        final pet = PetState();

        pet.happiness = 85;
        pet.updateOutcome();

        expect(pet.hasWon, false);

        async.elapse(const Duration(minutes: 2, seconds: 59));

        expect(pet.hasWon, false);

        async.elapse(const Duration(seconds: 1));

        expect(pet.hasWon, true);

        pet.dispose();
      });
    });

    test('dropping to 80 cancels the win timer', () {
      fakeAsync((async) {
        final pet = PetState();

        pet.happiness = 85;
        pet.updateOutcome();

        async.elapse(const Duration(minutes: 1));

        expect(pet.hasWon, false);

        pet.happiness = 80;
        pet.updateOutcome();

        async.elapse(const Duration(minutes: 2));

        expect(pet.hasWon, false);

        pet.dispose();
      });
    });
  });

  group('Loss condition', () {
    test('hunger at 100 and happiness at 10 causes game over', () {
      final pet = PetState();

      pet.hunger = 100;
      pet.happiness = 10;

      pet.updateOutcome();

      expect(pet.gameOver, true);
      expect(pet.hasWon, false);

      pet.dispose();
    });

    test('happiness above 10 does not cause game over', () {
      final pet = PetState();

      pet.hunger = 100;
      pet.happiness = 11;

      pet.updateOutcome();

      expect(pet.gameOver, false);

      pet.dispose();
    });
  });

  group('Actions after game outcome', () {
    test('feed is ignored after game over', () {
      final pet = PetState();

      pet.hunger = 100;
      pet.happiness = 10;
      pet.updateOutcome();

      expect(pet.gameOver, true);

      pet.feed();

      expect(pet.hunger, 100);
      expect(pet.happiness, 10);

      pet.dispose();
    });

    test('play is ignored after game over', () {
      final pet = PetState();

      pet.hunger = 100;
      pet.happiness = 10;
      pet.updateOutcome();

      expect(pet.gameOver, true);

      pet.play();

      expect(pet.hunger, 100);
      expect(pet.happiness, 10);

      pet.dispose();
    });
  });
}