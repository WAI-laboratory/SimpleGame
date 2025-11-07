#!/usr/bin/env python3
"""
Fix Xcode project by removing references to missing files
"""

import os
import sys

PROJECT_FILE = 'OpenGames.xcodeproj/project.pbxproj'
BACKUP_FILE = 'OpenGames.xcodeproj/project.pbxproj.backup'

# Files to remove
FILES_TO_REMOVE = [
    'fall.mp3',
    'gameover.mp3',
    'harddrop.mp3',
    'tetris_original.mp3',
    'simple.plist',
    'hard.plist'
]

def main():
    # Check if project file exists
    if not os.path.exists(PROJECT_FILE):
        print(f"❌ Error: {PROJECT_FILE} not found")
        print("   Make sure you're running this from the SimpleGame directory")
        sys.exit(1)

    # Create backup
    print(f"📦 Creating backup: {BACKUP_FILE}")
    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    with open(BACKUP_FILE, 'w') as f:
        f.write(content)

    # Remove lines containing the problematic files
    print(f"🔧 Removing references to missing files...")
    lines = content.split('\n')
    original_count = len(lines)

    filtered_lines = []
    removed_count = 0

    for line in lines:
        # Check if line contains any of the files to remove
        should_remove = False
        for file in FILES_TO_REMOVE:
            if file in line:
                should_remove = True
                removed_count += 1
                print(f"   - Removing line with: {file}")
                break

        if not should_remove:
            filtered_lines.append(line)

    # Write back
    with open(PROJECT_FILE, 'w') as f:
        f.write('\n'.join(filtered_lines))

    print(f"\n✅ Done!")
    print(f"   Removed {removed_count} lines")
    print(f"   Original: {original_count} lines")
    print(f"   New: {len(filtered_lines)} lines")
    print(f"\n💾 Backup saved to: {BACKUP_FILE}")
    print(f"\n🚀 Next steps:")
    print(f"   1. Open OpenGames.xcodeproj in Xcode")
    print(f"   2. Clean Build Folder (Shift+Cmd+K)")
    print(f"   3. Build (Cmd+B)")

if __name__ == '__main__':
    main()
