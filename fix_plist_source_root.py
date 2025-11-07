#!/usr/bin/env python3
import re

# Read the project file
project_path = "OpenGames.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Fix simple.plist to use SOURCE_ROOT
content = re.sub(
    r'(C1B14C4B2056400AAFD17E31 /\* simple\.plist \*/ = {isa = PBXFileReference; lastKnownFileType = text\.plist\.xml;)[^}]+}',
    r'\1 path = OpenGames/Resources/simple.plist; sourceTree = SOURCE_ROOT; }',
    content
)

# Fix hard.plist to use SOURCE_ROOT
content = re.sub(
    r'(41CFCD30E07B4FEAB2E546D5 /\* hard\.plist \*/ = {isa = PBXFileReference; lastKnownFileType = text\.plist\.xml;)[^}]+}',
    r'\1 path = OpenGames/Resources/hard.plist; sourceTree = SOURCE_ROOT; }',
    content
)

# Write the modified content back
with open(project_path, 'w') as f:
    f.write(content)

print("Fixed plist file paths to use SOURCE_ROOT")
