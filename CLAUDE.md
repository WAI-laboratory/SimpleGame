# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenGames is an iOS application that contains three classic games: Tetris, MineSweeper, and Sudoku. The app uses a tab-based architecture where each game is presented in its own tab.

## Building and Running

### Build Commands
```bash
# Build the project
xcodebuild -project OpenGames.xcodeproj -scheme OpenGames -configuration Debug build

# Build for release
xcodebuild -project OpenGames.xcodeproj -scheme OpenGames -configuration Release build

# Clean build
xcodebuild -project OpenGames.xcodeproj -scheme OpenGames clean
```

### Running the App
Open `OpenGames.xcodeproj` in Xcode and run using Cmd+R. The app requires an iOS simulator or device.

## Dependencies

The project uses Swift Package Manager with two dependencies:
- **SnapKit** (develop branch): Auto Layout DSL - https://github.com/SnapKit/SnapKit.git
- **AddThen** (main branch): Declarative initialization helper - https://github.com/stareta1202/addthen

## Architecture

### App Entry Point
- **SceneDelegate.swift**: Sets up the tab bar controller with three games (Tetris, MineSweeper, Sudoku) as tabs. This is the primary app initialization point where the game views are instantiated and configured.
- **AppDelegate.swift**: Contains shared game state (sudoku instance) and puzzle loading logic via `getPuzzles()` method

### Game Modules

#### Tetris (`OpenGames/Tetris/`)
- **Swiftris.swift**: Main game controller managing game state (play/pause/stop), game loop via GameTimer, and user interactions (touch/rotate/long-press). Uses NotificationCenter for state changes.
- **TetrisViewController.swift**: UIKit view controller wrapper
- **Model/**: Contains `Brick.swift` (tetromino pieces with 7 types: I, J, L, T, Z, S, O) and `GamerTimer.swift` (game loop timer)
- **View/**: Custom UIView components (`GameBoard`, `GameView`, `GameButton`, `GameScore`, `NextBrick`)
- **SoundManager/**: Audio playback for game sounds

Key patterns:
- Notification-based game state management (`GameStateChangeNotification`, `NewBrickDidGenerateNotification`, `LineClearNotification`)
- Static brick generation queue system (`Brick.nextBricks`)
- Game loop updates every 10 timer cycles
- Long press gesture for dropping bricks, tap for moving left/right

#### MineSweeper (`OpenGames/MineSweeper/`)
- **MineModel/Minegame.swift**: Core game logic using SwiftUI's ObservableObject. Handles click/flag interactions, recursive reveal for empty cells, and win/loss detection.
- **MineModel/MineCell.swift**: Cell model with status (normal/exposed/bomb) and flag state
- **MineModel/MineGameSettings.swift**: Board configuration (rows, columns, bombs)
- **MineView/**: SwiftUI views (`MineBoardView`, `MineCellView`)

Note: MineSweeper uses SwiftUI while other games use UIKit. Instantiated as `UIHostingController` in SceneDelegate.

#### Sudoku (`OpenGames/Sudoku/`)
- **SudokuClass.swift**: Core puzzle logic with three grids:
  - `plistPuzzle`: Initial fixed puzzle from plist file
  - `userPuzzle`: User-entered values
  - `pencilPuzzle`: 3D boolean array for pencil marks (row × col × digit)
- **sudokuData**: Codable struct for game state persistence
- **SudokuViewController.swift**: UIKit controller for UI
- **SudokuView.swift**: Custom view rendering

Key methods:
- `numberAt(row:column:)`: Gets current cell value
- `numberIsFixedAt(row:column:)`: Checks if cell is part of original puzzle
- `isConflictingEntryAt(row:column:)`: Validates against Sudoku rules
- `plistToPuzzle(plist:toughness:)`: Converts string puzzles to 9×9 grid

Sudoku puzzles are loaded from plist files via `AppDelegate.getPuzzles()`.

## Game Assets

- **Assets.xcassets/gameImages/**: MineSweeper cell images (numbered 1-8, bomb, flag, empty, normal)
- **Assets.xcassets/MineAsset/**: Additional MineSweeper assets
- Sound files for Tetris (location in OpenGames directory)

## Code Style Notes

- Game state enums use lowercase (e.g., `GameState.play`, `GameState.pause`, `GameState.stop`)
- Heavy use of custom UIView subclasses for Tetris UI components
- SwiftUI/UIKit hybrid: MineSweeper is pure SwiftUI, others are UIKit
- Korean language used for tab bar titles in SceneDelegate
