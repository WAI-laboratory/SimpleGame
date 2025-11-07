#!/usr/bin/env python3
import re

# Read the project file
project_path = "OpenGames.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Find and update the SheepAndSheep GameBoard.swift reference
# We need to find the PBXFileReference that has the path to SheepAndSheep/Model/GameBoard.swift
# and change both the filename comment and the path

# Pattern to find the SheepAndSheep GameBoard.swift entry
old_pattern = r'(\w+ /\* GameBoard\.swift \*/ = {isa = PBXFileReference; lastKnownFileType = sourcecode\.swift; path = OpenGames/SheepAndSheep/Model/GameBoard\.swift; sourceTree = SOURCE_ROOT; };)'
new_replacement = r'\g<1>'  # Keep UUID, but we'll do a more specific replacement

# Let's find the line with SheepAndSheep/Model/GameBoard.swift and replace it
content = content.replace(
    'path = OpenGames/SheepAndSheep/Model/GameBoard.swift',
    'path = OpenGames/SheepAndSheep/Model/SheepGameBoard.swift'
)

# Also update the comment for this file reference if it exists
# Search for the UUID that has this path and update its comment
lines = content.split('\n')
for i, line in enumerate(lines):
    if 'OpenGames/SheepAndSheep/Model/SheepGameBoard.swift' in line and '/* GameBoard.swift */' in line:
        lines[i] = line.replace('/* GameBoard.swift */', '/* SheepGameBoard.swift */')
    # Also update the PBXBuildFile reference
    if '/* GameBoard.swift in Sources */' in line:
        # Check if next few lines contain the SheepGameBoard path
        # We need to be more careful here - let's update based on context
        pass

content = '\n'.join(lines)

# Update BuildFile comments - find the UUID that references our file
# This is tricky, so let's just update all references in one go
import re

# Find the fileRef UUID for our SheepGameBoard.swift
match = re.search(r'(\w+) /\* SheepGameBoard\.swift \*/ = \{isa = PBXFileReference.*?path = OpenGames/SheepAndSheep/Model/SheepGameBoard\.swift', content)
if match:
    file_ref_uuid = match.group(1)
    print(f"Found file reference UUID: {file_ref_uuid}")

    # Find and update the corresponding BuildFile entry
    build_file_pattern = r'(\w+) /\* GameBoard\.swift in Sources \*/ = \{isa = PBXBuildFile; fileRef = ' + file_ref_uuid
    content = re.sub(build_file_pattern, r'\1 /* SheepGameBoard.swift in Sources */ = {isa = PBXBuildFile; fileRef = ' + file_ref_uuid, content)

    # Also update the Sources reference
    sources_pattern = r'(\w+) /\* GameBoard\.swift in Sources \*/,'
    # We need to match only the one with our UUID
    content = re.sub(file_ref_uuid + r' /\* GameBoard\.swift in Sources \*/', file_ref_uuid + ' /* SheepGameBoard.swift in Sources */', content)

# Write the modified content back
with open(project_path, 'w') as f:
    f.write(content)

print("Successfully updated project file references from GameBoard.swift to SheepGameBoard.swift")
