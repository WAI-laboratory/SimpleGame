#!/usr/bin/env python3
import re
import uuid

# Read the project file
project_path = "OpenGames.xcodeproj/project.pbxproj"
with open(project_path, 'r') as f:
    content = f.read()

# Files to add
files_to_add = [
    ("simple.plist", "OpenGames/Resources/simple.plist"),
    ("hard.plist", "OpenGames/Resources/hard.plist")
]

# Find the OpenGames group (main group)
opengames_group_match = re.search(r'/\* OpenGames \*/.*?isa = PBXGroup;.*?children = \((.*?)\);', content, re.DOTALL)
if not opengames_group_match:
    print("Could not find OpenGames group")
    exit(1)

# Find the Resources group
resources_group_match = re.search(r'/\* Resources \*/.*?isa = PBXGroup;.*?children = \((.*?)\);', content, re.DOTALL)

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
    fileref_section = f"\t\t{fileref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = {filename}; sourceTree = \"<group>\"; }};\n"

    # Find the end of PBXFileReference section
    fileref_insert_pos = content.find("/* End PBXFileReference section */")
    content = content[:fileref_insert_pos] + fileref_section + content[fileref_insert_pos:]

    # Add to Resources group if it exists
    if resources_group_match:
        resources_children = resources_group_match.group(1)
        resources_group_full = resources_group_match.group(0)

        # Add file reference to Resources group
        new_child_entry = f"\n\t\t\t\t{fileref_uuid} /* {filename} */,"

        # Find the children section and add our file
        new_resources_group = resources_group_full.replace(
            "children = (",
            f"children = ({new_child_entry}"
        )
        content = content.replace(resources_group_full, new_resources_group)

    # Add PBXBuildFile (for resources that need to be copied)
    buildfile_section = f"\t\t{buildfile_uuid} /* {filename} in Resources */ = {{isa = PBXBuildFile; fileRef = {fileref_uuid} /* {filename} */; }};\n"

    # Find the end of PBXBuildFile section
    buildfile_insert_pos = content.find("/* End PBXBuildFile section */")
    content = content[:buildfile_insert_pos] + buildfile_section + content[buildfile_insert_pos:]

    # Add to PBXResourcesBuildPhase
    resources_phase_match = re.search(r'(isa = PBXResourcesBuildPhase;.*?files = \()(.*?)(\);)', content, re.DOTALL)
    if resources_phase_match:
        files_section = resources_phase_match.group(2)
        new_files_entry = f"\n\t\t\t\t{buildfile_uuid} /* {filename} in Resources */,"

        new_files_section = new_files_entry + files_section
        content = content.replace(
            resources_phase_match.group(0),
            resources_phase_match.group(1) + new_files_section + resources_phase_match.group(3)
        )

    added_files.append(filename)
    print(f"Added {filename} to project")

# Write the modified content back
with open(project_path, 'w') as f:
    f.write(content)

print(f"\nSuccessfully added {len(added_files)} files to the Xcode project")
print("Files added:", ", ".join(added_files))
