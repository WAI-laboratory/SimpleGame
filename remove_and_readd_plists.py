#!/usr/bin/env python3
import re

# Read the project file
project_path = "OpenGames.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Remove existing plist references
content = re.sub(r'\s*EE6C64939C7C4A0E8034FE32 /\* simple\.plist in Resources \*/ = {isa = PBXBuildFile; fileRef = A8CA8638704E495D8D1F1C66 /\* simple\.plist \*/; };\n', '', content)
content = re.sub(r'\s*81217A0040484D8DB29212AC /\* hard\.plist in Resources \*/ = {isa = PBXBuildFile; fileRef = AC4A19A38DC54E7DBFECCB73 /\* hard\.plist \*/; };\n', '', content)
content = re.sub(r'\s*A8CA8638704E495D8D1F1C66 /\* simple\.plist \*/ = {isa = PBXFileReference; lastKnownFileType = text\.plist\.xml;[^}]*};\n', '', content)
content = re.sub(r'\s*AC4A19A38DC54E7DBFECCB73 /\* hard\.plist \*/ = {isa = PBXFileReference; lastKnownFileType = text\.plist\.xml;[^}]*};\n', '', content)
content = re.sub(r'\s*A8CA8638704E495D8D1F1C66 /\* simple\.plist \*/,\n', '', content)
content = re.sub(r'\s*AC4A19A38DC54E7DBFECCB73 /\* hard\.plist \*/,\n', '', content)
content = re.sub(r'\s*81217A0040484D8DB29212AC /\* hard\.plist in Resources \*/,\n', '', content)
content = re.sub(r'\s*EE6C64939C7C4A0E8034FE32 /\* simple\.plist in Resources \*/,\n', '', content)

# Write the modified content back
with open(project_path, 'w') as f:
    f.write(content)

print("Removed plist references from project")
