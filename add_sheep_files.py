#!/usr/bin/env python3
import re
import uuid

# Read the project file
project_path = "OpenGames.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Files to add
files_to_add = [
    ("Tile.swift", "OpenGames/SheepAndSheep/Model/Tile.swift"),
    ("GameBoard.swift", "OpenGames/SheepAndSheep/Model/GameBoard.swift"),
    ("LevelGenerator.swift", "OpenGames/SheepAndSheep/Model/LevelGenerator.swift"),
    ("TileView.swift", "OpenGames/SheepAndSheep/View/TileView.swift"),
    ("GameBoardView.swift", "OpenGames/SheepAndSheep/View/GameBoardView.swift"),
    ("CollectionSlotView.swift", "OpenGames/SheepAndSheep/View/CollectionSlotView.swift"),
    ("SheepGameViewController.swift", "OpenGames/SheepAndSheep/Controller/SheepGameViewController.swift")
]

added_files = []

for filename, filepath in files_to_add:
    # Check if file is already in project
    if filename in content:
        print(f"File {filename} already in project, skipping")
        continue

    # Generate UUIDs
    fileref_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    buildfile_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]

    # Add PBXFileReference
    fileref_section = f"\t\t{fileref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};\n"

    # Find the end of PBXFileReference section
    fileref_insert_pos = content.find("/* End PBXFileReference section */")
    content = content[:fileref_insert_pos] + fileref_section + content[fileref_insert_pos:]

    # Add PBXBuildFile
    buildfile_section = f"\t\t{buildfile_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {fileref_uuid} /* {filename} */; }};\n"

    # Find the end of PBXBuildFile section
    buildfile_insert_pos = content.find("/* End PBXBuildFile section */")
    content = content[:buildfile_insert_pos] + buildfile_section + content[buildfile_insert_pos:]

    # Add to PBXSourcesBuildPhase
    sources_phase_match = re.search(r'(isa = PBXSourcesBuildPhase;.*?files = \()(.*?)(\);)', content, re.DOTALL)
    if sources_phase_match:
        files_section = sources_phase_match.group(2)
        new_files_entry = f"\n\t\t\t\t{buildfile_uuid} /* {filename} in Sources */,"

        new_files_section = new_files_entry + files_section
        content = content.replace(
            sources_phase_match.group(0),
            sources_phase_match.group(1) + new_files_section + sources_phase_match.group(3)
        )

    added_files.append(filename)
    print(f"Added {filename} to project")

# Write the modified content back
with open(project_path, 'w') as f:
    f.write(content)

print(f"\nSuccessfully added {len(added_files)} files to the Xcode project")
print("Files added:", ", ".join(added_files))
