#!/usr/bin/env python3
import re

# Read the project file
project_path = "OpenGames.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Find and replace simple.plist  FileReference to use correct path
content = re.sub(
    r'(\w+ /\* simple\.plist \*/ = {isa = PBXFileReference; lastKnownFileType = text\.plist\.xml;) path = [^;]+;',
    r'\1 name = simple.plist; path = Resources/simple.plist;',
    content
)

# Find and replace hard.plist FileReference to use correct path
content = re.sub(
    r'(\w+ /\* hard\.plist \*/ = {isa = PBXFileReference; lastKnownFileType = text\.plist\.xml;) path = [^;]+;',
    r'\1 name = hard.plist; path = Resources/hard.plist;',
    content
)

# Write the modified content back
with open(project_path, 'w') as f:
    f.write(content)

print("Fixed plist file paths - using Resources/filename.plist")
