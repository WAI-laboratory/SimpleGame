#!/usr/bin/env python3
import re

# Read the project file
project_path = "OpenGames.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Fix simple.plist path
content = re.sub(
    r'(A8CA8638704E495D8D1F1C66 /\* simple\.plist \*/ = {isa = PBXFileReference; lastKnownFileType = text\.plist\.xml; path = simple\.plist;)',
    r'A8CA8638704E495D8D1F1C66 /* simple.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; name = simple.plist; path = OpenGames/Resources/simple.plist;',
    content
)

# Fix hard.plist path
content = re.sub(
    r'(AC4A19A38DC54E7DBFECCB73 /\* hard\.plist \*/ = {isa = PBXFileReference; lastKnownFileType = text\.plist\.xml; path = hard\.plist;)',
    r'AC4A19A38DC54E7DBFECCB73 /* hard.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; name = hard.plist; path = OpenGames/Resources/hard.plist;',
    content
)

# Write the modified content back
with open(project_path, 'w') as f:
    f.write(content)

print("Fixed plist file paths in project")
