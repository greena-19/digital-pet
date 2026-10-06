import 'package:flutter_test/flutter_test.dart';
import 'package:digital_pet/models/pet_game.dart';

void main() {
  group('Digital Pet Game Tests', () {
    test('Initial pet values are correct', () {
      final pet = PetGame();

      expect(pet.petName, 'Pip');
      expect(pet.happiness, 50);
      expect(pet.hunger, 50);
      expect(pet.energy, 70);
      expect(pet.gameOver, false);
      expect(pet.hasWon, false);
    });

    test('Pet name can be changed', () {
      final pet = PetGame();

      pet.setName('Buddy');

      expect(pet.petName, 'Buddy');
    });

    test('Feed decreases hunger', () {
      final pet = PetGame(
        happiness: 50,
        hunger: 50,
      );

      pet.feed();

      expect(pet.hunger, 40);
      expect(pet.happiness, 60);
    });

    test('Meters remain within 0 to 100', () {
      final pet = PetGame(
        happiness: 95,
        hunger: 95,
        energy: 100,
      );

      pet.play();

      expect(pet.happiness, 100);
      expect(pet.hunger, 100);
      expect(pet.energy, 90);

      expect(pet.happiness, inInclusiveRange(0, 100));
      expect(pet.hunger, inInclusiveRange(0, 100));
      expect(pet.energy, inInclusiveRange(0, 100));
    });

    test('Play changes happiness, hunger and energy', () {
      final pet = PetGame(
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      final result = pet.play();

      expect(result, true);
      expect(pet.happiness, 65);
      expect(pet.hunger, 55);
      expect(pet.energy, 60);
    });

    test('Play fails when energy is too low', () {
      final pet = PetGame(
        happiness: 50,
        hunger: 50,
        energy: 5,
      );

      final result = pet.play();

      expect(result, false);
      expect(pet.happiness, 50);
      expect(pet.energy, 5);
    });

    test('Run changes happiness, hunger and energy', () {
      final pet = PetGame(
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      final result = pet.run();

      expect(result, true);
      expect(pet.happiness, 60);
      expect(pet.hunger, 60);
      expect(pet.energy, 50);
    });

    test('Sleep restores energy', () {
      final pet = PetGame(
        hunger: 50,
        energy: 60,
      );

      pet.sleep();

      expect(pet.energy, 90);
      expect(pet.hunger, 55);
    });

    test('Hunger timer increases hunger by 5', () {
      final pet = PetGame(
        hunger: 50,
      );

      pet.hungerTick();

      expect(pet.hunger, 55);
    });

    test('Hunger from 95 reaches 100 without happiness penalty', () {
      final pet = PetGame(
        happiness: 50,
        hunger: 95,
      );

      pet.hungerTick();

      expect(pet.hunger, 100);
      expect(pet.happiness, 50);
    });

    test('Hunger overflow reduces happiness by 20', () {
      final pet = PetGame(
        happiness: 50,
        hunger: 100,
      );

      pet.hungerTick();

      expect(pet.hunger, 100);
      expect(pet.happiness, 30);
    });

    test('Game over occurs at hunger 100 and happiness 10', () {
      final pet = PetGame(
        happiness: 10,
        hunger: 100,
      );

      final result = pet.checkLoss();

      expect(result, true);
      expect(pet.gameOver, true);
    });

    test('Game does not end when happiness is above 10', () {
      final pet = PetGame(
        happiness: 11,
        hunger: 100,
      );

      final result = pet.checkLoss();

      expect(result, false);
      expect(pet.gameOver, false);
    });

    test('Mood is unhappy below 30', () {
      final pet = PetGame(
        happiness: 29,
      );

      expect(pet.moodLabel, 'Unhappy');
    });

    test('Mood is neutral at 30', () {
      final pet = PetGame(
        happiness: 30,
      );

      expect(pet.moodLabel, 'Neutral');
    });

    test('Mood is neutral at 70', () {
      final pet = PetGame(
        happiness: 70,
      );

      expect(pet.moodLabel, 'Neutral');
    });

    test('Mood is happy at 71', () {
      final pet = PetGame(
        happiness: 71,
      );

      expect(pet.moodLabel, 'Happy');
    });

    test('Win only occurs when happiness is above 80', () {
      final pet = PetGame(
        happiness: 80,
      );

      pet.win();

      expect(pet.hasWon, false);

      pet.happiness = 81;

      pet.win();

      expect(pet.hasWon, true);
    });

    test('Reset restores initial values', () {
      final pet = PetGame(
        happiness: 90,
        hunger: 90,
        energy: 10,
        gameOver: true,
      );

      pet.reset();

      expect(pet.happiness, 50);
      expect(pet.hunger, 50);
      expect(pet.energy, 70);
      expect(pet.gameOver, false);
      expect(pet.hasWon, false);
    });
  });
}