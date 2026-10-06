# Digital Pet

A Flutter-based Digital Pet application created for Mobile Application Development – In-Class Activity 07.

## Setup, Build, and Test

Install dependencies:

flutter pub get

Run the application:

flutter run

Run tests:

flutter test

Check the project:

flutter analyze

Build the release APK:

flutter build apk --release

The APK is generated at:

build/app/outputs/flutter-apk/app-release.apk


## Team Roles

### Team 1 – Care Systems
Team 1 worked on the main pet care system and core game state.

Main responsibilities:
- Happiness and hunger state
- Feed and Play actions
- 30-second hunger timer
- Win and loss conditions
- Reset behavior
- State bounds from 0–100

### Team 2 – Pet Personality and Visual Polish
Team 2 worked on the pet's personality, interaction feedback, visual effects, and additional testing.

Main responsibilities:
- Pet mood and personality
- Mood-based ColorFiltered effect
- Pet reaction messages
- Animated pet interactions
- Animated meters
- Pet name editing
- Energy system
- Additional Run and Sleep interactions
- PetGame model
- Automated game-state tests


## Pathway

Graduate Pathway


## Features

### Core Features
- Editable pet name
- Happiness meter
- Hunger meter
- Energy meter
- Mood indicator
- Feed action
- Play action
- Reset option
- Hunger increases every 30 seconds
- Win and loss conditions
- Values remain between 0 and 100

### Advanced Features
- Animated pet reaction feedback
- Animated status meters
- Mood-based pet tint and size
- Reduced-motion support
- Additional Run and Sleep actions
- Separate PetGame model for game logic
- Automated state and boundary tests


## Feature-to-Outcome Rubric Map

| Feature | Learning Outcome / Evidence |
|---|---|
| Pet state | Demonstrates Flutter state management |
| Feed and Play | Demonstrates interactive state changes |
| Hunger timer | Demonstrates timer and lifecycle management |
| Mood tint | Demonstrates ColorFiltered and BlendMode.modulate |
| Mood icon/text | Provides a non-color mood indicator |
| Animated pet | Demonstrates Flutter animation widgets |
| Animated meters | Provides visual feedback when state changes |
| PetGame model | Separates game logic from UI rendering |
| Automated tests | Tests state changes, boundaries, win/loss, and reset |
| GitHub branches and PRs | Demonstrates team collaboration and version control |


## Test Evidence

The PetGame model includes automated tests for:

- Initial pet state
- Pet name changes
- Feed behavior
- Play behavior
- Run behavior
- Sleep behavior
- Hunger timer state changes
- State clamping between 0 and 100
- Loss condition
- Win threshold
- Mood boundaries at 29, 30, 70, and 71
- Reset behavior

Tests can be run with:

flutter test

The project can also be checked with:

flutter analyze




## Asset License

The pet image used in this project was generated specifically for the Digital Pet application using OpenAI/ChatGPT image generation.

Asset location:

assets/pet.png


## GitHub Collaboration

Team 1 Branch:

team-1/care-systems

Team 2 Branch:

team-2/pet-personality

Integration Branch:

team-2/integration

Both teams worked through separate branches and reviewed team contributions before integrating the application.


## Release APK

The final release APK can be generated using:

flutter build apk --release

Output:

build/app/outputs/flutter-apk/app-release.apk
