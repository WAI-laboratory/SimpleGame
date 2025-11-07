#!/bin/bash

# Script to find and copy resource files to OpenGames project

echo "🔍 Searching for audio and plist files..."
echo ""

# Create Resources directory
RESOURCES_DIR="/Users/sobabear/Desktop/iOS/SimpleGame/OpenGames/Resources"
mkdir -p "$RESOURCES_DIR"

# Search for audio files
echo "📁 Looking for audio files..."
TETRIS_MP3=$(find /Users/sobabear/Desktop/iOS -name "tetris_original.mp3" 2>/dev/null | head -1)
FALL_MP3=$(find /Users/sobabear/Desktop/iOS -name "fall.mp3" 2>/dev/null | head -1)
GAMEOVER_MP3=$(find /Users/sobabear/Desktop/iOS -name "gameover.mp3" 2>/dev/null | head -1)
HARDDROP_MP3=$(find /Users/sobabear/Desktop/iOS -name "harddrop.mp3" 2>/dev/null | head -1)

# Search for plist files
echo "📁 Looking for plist files..."
SIMPLE_PLIST=$(find /Users/sobabear/Desktop/iOS -name "simple.plist" 2>/dev/null | grep -i sudoku | head -1)
HARD_PLIST=$(find /Users/sobabear/Desktop/iOS -name "hard.plist" 2>/dev/null | grep -i sudoku | head -1)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SEARCH RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Display findings
if [ -n "$TETRIS_MP3" ]; then
    echo "✅ Found: tetris_original.mp3"
    echo "   📍 $TETRIS_MP3"
else
    echo "❌ Not found: tetris_original.mp3"
fi

if [ -n "$FALL_MP3" ]; then
    echo "✅ Found: fall.mp3"
    echo "   📍 $FALL_MP3"
else
    echo "❌ Not found: fall.mp3"
fi

if [ -n "$GAMEOVER_MP3" ]; then
    echo "✅ Found: gameover.mp3"
    echo "   📍 $GAMEOVER_MP3"
else
    echo "❌ Not found: gameover.mp3"
fi

if [ -n "$HARDDROP_MP3" ]; then
    echo "✅ Found: harddrop.mp3"
    echo "   📍 $HARDDROP_MP3"
else
    echo "❌ Not found: harddrop.mp3"
fi

if [ -n "$SIMPLE_PLIST" ]; then
    echo "✅ Found: simple.plist"
    echo "   📍 $SIMPLE_PLIST"
else
    echo "❌ Not found: simple.plist"
fi

if [ -n "$HARD_PLIST" ]; then
    echo "✅ Found: hard.plist"
    echo "   📍 $HARD_PLIST"
else
    echo "❌ Not found: hard.plist"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ask if user wants to copy
read -p "📋 Do you want to copy found files to $RESOURCES_DIR? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📦 Copying files..."

    [ -n "$TETRIS_MP3" ] && cp "$TETRIS_MP3" "$RESOURCES_DIR/" && echo "   ✅ Copied tetris_original.mp3"
    [ -n "$FALL_MP3" ] && cp "$FALL_MP3" "$RESOURCES_DIR/" && echo "   ✅ Copied fall.mp3"
    [ -n "$GAMEOVER_MP3" ] && cp "$GAMEOVER_MP3" "$RESOURCES_DIR/" && echo "   ✅ Copied gameover.mp3"
    [ -n "$HARDDROP_MP3" ] && cp "$HARDDROP_MP3" "$RESOURCES_DIR/" && echo "   ✅ Copied harddrop.mp3"
    [ -n "$SIMPLE_PLIST" ] && cp "$SIMPLE_PLIST" "$RESOURCES_DIR/" && echo "   ✅ Copied simple.plist"
    [ -n "$HARD_PLIST" ] && cp "$HARD_PLIST" "$RESOURCES_DIR/" && echo "   ✅ Copied hard.plist"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Files copied to: $RESOURCES_DIR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 Next steps:"
    echo "1. Open OpenGames.xcodeproj in Xcode"
    echo "2. Drag the Resources folder from Finder into Xcode"
    echo "3. Check 'Copy items if needed' and 'OpenGames' target"
    echo "4. Build and run!"
    echo ""
    echo "📂 Open Resources folder in Finder:"
    echo "   open '$RESOURCES_DIR'"
    echo ""
else
    echo ""
    echo "❌ Copy cancelled"
    echo ""
    echo "💡 You can manually copy files later:"
    echo "   cp /path/to/your/file.mp3 '$RESOURCES_DIR/'"
    echo ""
fi

# List what's in the Resources directory now
if [ -d "$RESOURCES_DIR" ]; then
    FILE_COUNT=$(ls -1 "$RESOURCES_DIR" 2>/dev/null | wc -l)
    if [ $FILE_COUNT -gt 0 ]; then
        echo "📁 Current files in Resources:"
        ls -lh "$RESOURCES_DIR"
    fi
fi
