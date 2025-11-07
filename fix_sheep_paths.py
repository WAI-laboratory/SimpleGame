#!/usr/bin/env python3
import re

# Read the project file
project_path = "OpenGames.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Files to fix with their proper paths
files_to_fix = {
    "Tile.swift": "OpenGames/SheepAndSheep/Model/Tile.swift",
    "LevelGenerator.swift": "OpenGames/SheepAndSheep/Model/LevelGenerator.swift",
    "TileView.swift": "OpenGames/SheepAndSheep/View/TileView.swift",
    "GameBoardView.swift": "OpenGames/SheepAndSheep/View/GameBoardView.swift",
    "CollectionSlotView.swift": "OpenGames/SheepAndSheep/View/CollectionSlotView.swift",
    "SheepGameViewController.swift": "OpenGames/SheepAndSheep/Controller/SheepGameViewController.swift"
}

for filename, filepath in files_to_fix.items():
    # Fix PBXFileReference
    pattern = f'(\\w+ /\\* {re.escape(filename)} \\*/ = {{isa = PBXFileReference; lastKnownFileType = sourcecode\\.swift;) path = {re.escape(filename)};'
    replacement = f'\\1 path = {filepath}; sourceTree = SOURCE_ROOT;'
    content = re.sub(pattern, replacement, content)
    print(f"Fixed path for {filename}")

# Write the modified content back
with open(project_path, 'w') as f:
    f.write(content)

print("\nFixed all file paths to use SOURCE_ROOT")
