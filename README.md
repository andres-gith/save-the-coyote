# Save the Coyote

## Functionality

"Save the Coyote" is a Flutter application where the main goal is to prevent the Coyote character from falling off a cliff. 

## Architecture

This project utilizes the **BLoC (Business Logic Component)** architecture pattern. This pattern helps in separating the presentation layer from the business logic, making the application more scalable, testable, and maintainable.

Key components of this architecture in the project include:
*   **Events**: Represent user actions or other inputs.
*   **States**: Represent the UI's condition at a given moment.
*   **Blocs**: Receive events, process them (often involving asynchronous operations), and emit new states.
*   **UI Layer**: Listens to state changes from Blocs and rebuilds itself accordingly.

Dependencies like `flutter_bloc` and `bloc_test` are used to implement and test this pattern effectively.

## BLoC Flows

### EngineBloc

The `EngineBloc` manages the core gameplay mechanics related to the coyote's state (falling, saved, etc.).

**Events:**
*   `OnLoadEvent`: Triggered to initialize the game engine. Sets up a listener for the coyote's falling position and transitions to `ShowIntroEvent`.
*   `ShowIntroEvent`: Leads to the `IntroScreen` state.
*   `ShowInstructions`: Leads to the `Instructions` state.
*   `StartFallEvent`: Initiates the coyote's descent, transitioning the state to `CoyoteFalling`.
*   `StopFallEvent`: Halts the coyote's fall.
    *   If the coyote is successfully stopped before hitting the bottom (`position < 1.0`), it transitions to `CoyoteSaved`, including the calculated score.
    *   Otherwise, it transitions to `CoyoteNotSaved`.
*   `TapRegisteredEvent`: Handles user taps.
    *   If the state is `CoyoteFalling`, it dispatches a `StopFallEvent`.
    *   If the state is `CoyoteStopped` (e.g., `CoyoteSaved` or `CoyoteNotSaved`), it dispatches a `StartFallEvent` to restart the fall (likely for a new game or attempt).

**States:**
*   `EngineInitial`: The initial state of the bloc before loading.
*   `IntroScreen`: State indicating the introduction screen should be displayed.
*   `Instructions`: State indicating the instructions screen should be displayed.
*   `EngineRunning(double position)`: An abstract base state representing that the game engine is active. It holds the coyote's current `position`.
    *   `CoyoteFalling(double position)`: The coyote is currently falling.
    *   `CoyoteStopped(double position)`: The coyote's fall has been arrested.
        *   `CoyoteSaved(double position, int score)`: The coyote has been successfully saved. Includes the `score`.
        *   `CoyoteNotSaved(double position)`: The coyote was not saved before hitting the fail position.
    *   `CoyoteFell(double position)`: The coyote has fallen completely (`position >= 1.0`).

### ScoreBloc

The `ScoreBloc` manages player scores, records, and related UI states.

**Events:**
*   `OnLoadScoreEvent`: Initializes the scoring system (e.g., loading saved scores) and then triggers `ScoreReadyEvent`.
*   `ScoreReadyEvent`: Emits the `ScoreReady` state with the current game/fail counters and the last recorded player name.
*   `CountFailEvent`: Increments the fail counter and total attempts, then emits `ScoredFail` state.
*   `ScoredPointsEvent(int score)`: Increments the total attempts. If the `score` is a new record, it triggers `NewRecordEvent`. Otherwise, it saves the current score and emits `ScoredPoints`.
*   `NewRecordEvent(int score)`: Emits `NewRecord` state, usually to prompt the user to enter their name for the new high score.
*   `SaveRecordEvent(int score, String name)`: Saves the new high `score` with the player's `name` and then emits `ScoredPoints`.
*   `ShowScoresEvent`: Emits `ScoreResults` state to display a summary of scores (min, max, counters).
*   `DismissScoresEvent`: Triggers `ScoreReadyEvent` to return to the default score display.
*   `ChangeRecordedNameEvent`: Emits `ChangeRecordedName` state, allowing the user to update their last used name.
*   `SaveRecordNameEvent(String name)`: Saves the new player `name` and triggers `ScoreReadyEvent`.

**States:**
*   `ScoreInitial`: The initial state before the score system is loaded.
*   `ScoreReady({String? lastRecordedName, required int counter, required int failCounter})`: Base state showing current attempt/fail counters and the last recorded player name.
    *   `ScoredPoints`: A specialized `ScoreReady` state indicating points were just scored.
    *   `ScoredFail`: A specialized `ScoreReady` state indicating a fail was just registered.
*   `ScoreResults({String? lastRecordedName, int? minScore, required int counter, required int failCounter, required List<String> maxScores})`: Displays detailed score statistics.
*   `NewRecord({String? lastRecordedName, required int score})`: Indicates a new high score has been achieved and prompts for player input. Includes the `score`.
*   `ChangeRecordedName({String? lastRecordedName})`: State to allow modification of the last recorded player name.

## Disclaimer & Licensing

This application, "Save the Coyote," was developed primarily as a learning project. The main goals were to explore and implement software architecture patterns, specifically **BLoC (Business Logic Component)**, and to apply best practices in **Flutter** mobile application development.

**Licensing of Source Code:**

The original source code that comprises this application (including Flutter widgets, BLoC logic, and other Dart files written by the project author) is licensed under the **GNU General Public License, version 3 (GPLv3)**. A copy of the GPLv3 can be found in the `LICENSE` file in the root directory of this project.

Under the GPLv3, you are free to run, study, share, and modify this source code. If you distribute modified versions or works based on this source code, they must also be licensed under the GPLv3.

**Important Notice Regarding Third-Party Assets:**

The visual assets (such as character designs, images, icons), sound effects, and any other multimedia elements used within this application **are NOT covered by the GPLv3 license** applied to the source code.

These materials:
*   May be subject to copyright owned by third parties.
*   Have been incorporated for illustrative, educational, and demonstration purposes only, to provide a functional context for the technical aspects of the project.
*   **I do not claim ownership of any potentially copyrighted third-party material used herein, nor do I grant any rights to use these assets under the GPLv3 or any other license.**

This project is not intended for commercial use or public distribution in a way that would infringe upon the rights of any copyright holders of these third-party assets.

If you are a copyright holder and believe that any third-party material used in this project infringes upon your rights, please contact me so that the matter can be promptly addressed and the material removed or appropriately attributed if permitted.

