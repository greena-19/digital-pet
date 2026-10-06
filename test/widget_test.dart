import 'package:flutter_test/flutter_test.dart';
import 'package:digital_pet/main.dart';

void main() {
  testWidgets('Digital Pet app loads correctly', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());

    expect(find.text('Digital Pet'), findsOneWidget);
    expect(find.text('Pip'), findsOneWidget);
    expect(find.text('Happiness'), findsOneWidget);
    expect(find.text('Hunger'), findsOneWidget);
    expect(find.text('Energy'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('Pet starts with correct values', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());

    expect(find.text('50 / 100'), findsNWidgets(2));
    expect(find.text('70 / 100'), findsOneWidget);
  });

  testWidgets('Feed changes pet values correctly', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());

    await tester.ensureVisible(find.text('Feed'));
    await tester.tap(find.text('Feed'));
    await tester.pump();

    expect(find.text('60 / 100'), findsOneWidget);
    expect(find.text('40 / 100'), findsOneWidget);
    expect(find.text('75 / 100'), findsOneWidget);
  });

  testWidgets('Play changes pet values correctly', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());

    await tester.ensureVisible(find.text('Play'));
    await tester.tap(find.text('Play'));
    await tester.pump();

    expect(find.text('65 / 100'), findsOneWidget);
    expect(find.text('55 / 100'), findsOneWidget);
    expect(find.text('60 / 100'), findsOneWidget);
  });

  testWidgets('Reset restores initial values', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());

    await tester.ensureVisible(find.text('Play'));
    await tester.tap(find.text('Play'));
    await tester.pump();

    await tester.ensureVisible(find.text('Reset'));
    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(find.text('50 / 100'), findsNWidgets(2));
    expect(find.text('70 / 100'), findsOneWidget);
  });
}