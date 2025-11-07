#!/usr/bin/env python3
"""
Add new Tetris UI Swift files to Xcode project
"""

import os
import uuid
import re

PROJECT_FILE = 'OpenGames.xcodeproj/project.pbxproj'
BACKUP_FILE = 'OpenGames.xcodeproj/project.pbxproj.backup2'

# Files to add
NEW_FILES = [
    ('DPadControl.swift', 'OpenGames/Tetris/View/DPadControl.swift'),
    ('ActionButtons.swift', 'OpenGames/Tetris/View/ActionButtons.swift'),
    ('HoldPiece.swift', 'OpenGames/Tetris/View/HoldPiece.swift'),
]

def generate_uuid():
    """Generate a unique ID in Xcode format"""
    return uuid.uuid4().hex[:24].upper()

def main():
    print("🔧 Adding new Swift files to Xcode project...\n")

    # Check if project file exists
    if not os.path.exists(PROJECT_FILE):
        print(f"❌ Error: {PROJECT_FILE} not found")
        return 1

    # Check if new files exist
    print("📁 Checking if files exist...")
    for name, path in NEW_FILES:
        full_path = path
        if os.path.exists(full_path):
            print(f"   ✅ {name}")
        else:
            print(f"   ❌ {name} NOT FOUND at {full_path}")
            print(f"\n💡 Make sure the files are in the correct location")
            return 1

    # Create backup
    print(f"\n📦 Creating backup: {BACKUP_FILE}")
    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    with open(BACKUP_FILE, 'w') as f:
        f.write(content)

    print("🔨 Modifying project file...\n")

    # Generate UUIDs for each file
    file_refs = []
    build_files = []

    for name, path in NEW_FILES:
        file_ref_id = generate_uuid()
        build_file_id = generate_uuid()

        file_refs.append({
            'id': file_ref_id,
            'name': name,
            'path': path.split('/')[-1],  # just filename
            'full_path': path
        })

        build_files.append({
            'id': build_file_id,
            'file_ref_id': file_ref_id,
            'name': name
        })

    # Add PBXBuildFile entries
    build_file_section = "/* Begin PBXBuildFile section */"
    build_file_idx = content.find(build_file_section)

    if build_file_idx == -1:
        print("❌ Could not find PBXBuildFile section")
        return 1

    # Find the end of the first line
    insert_idx = content.find('\n', build_file_idx) + 1

    build_file_entries = ""
    for bf in build_files:
        build_file_entries += f"\t\t{bf['id']} /* {bf['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {bf['file_ref_id']} /* {bf['name']} */; }};\n"

    content = content[:insert_idx] + build_file_entries + content[insert_idx:]

    # Add PBXFileReference entries
    file_ref_section = "/* Begin PBXFileReference section */"
    file_ref_idx = content.find(file_ref_section)

    if file_ref_idx == -1:
        print("❌ Could not find PBXFileReference section")
        return 1

    insert_idx = content.find('\n', file_ref_idx) + 1

    file_ref_entries = ""
    for fr in file_refs:
        file_ref_entries += f"\t\t{fr['id']} /* {fr['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {fr['path']}; sourceTree = \"<group>\"; }};\n"

    content = content[:insert_idx] + file_ref_entries + content[insert_idx:]

    # Add to Sources build phase
    # Find PBXSourcesBuildPhase
    sources_phase_pattern = r'(\/\* Sources \*\/ = \{[^}]+files = \([^)]+)'
    match = re.search(sources_phase_pattern, content, re.DOTALL)

    if match:
        insert_pos = match.end()
        sources_entries = ""
        for bf in build_files:
            sources_entries += f"\n\t\t\t\t{bf['id']} /* {bf['name']} in Sources */,"
        content = content[:insert_pos] + sources_entries + content[insert_pos:]
    else:
        print("⚠️  Warning: Could not find Sources build phase")

    # Add to View group
    # Find the View group (children section)
    view_group_pattern = r'(\/\* View \*\/ = \{[^}]+children = \([^)]+)'
    match = re.search(view_group_pattern, content, re.DOTALL)

    if match:
        insert_pos = match.end()
        view_entries = ""
        for fr in file_refs:
            view_entries += f"\n\t\t\t\t{fr['id']} /* {fr['name']} */,"
        content = content[:insert_pos] + view_entries + content[insert_pos:]
    else:
        print("⚠️  Warning: Could not find View group")

    # Write the modified content
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)

    print("✅ Successfully added files to project!\n")
    print("📝 Added:")
    for name, _ in NEW_FILES:
        print(f"   ✅ {name}")

    print(f"\n💾 Backup saved to: {BACKUP_FILE}")
    print("\n🚀 Next steps:")
    print("   1. Open OpenGames.xcodeproj in Xcode")
    print("   2. Clean Build Folder (Shift+Cmd+K)")
    print("   3. Build (Cmd+B)")
    print("\n✨ Your Tetris improvements are ready!")

    return 0

if __name__ == '__main__':
    exit(main())
