# Adding Sound Files to OpenGames Project

## 🔊 Sound Files Required

You need these 4 MP3 files:
1. **tetris_original.mp3** - Background music (loops continuously)
2. **fall.mp3** - Drop sound effect (when hard drop is used)
3. **gameover.mp3** - Game over sound
4. **harddrop.mp3** - Hard drop sound (alternative to fall.mp3)

## 📁 Step-by-Step: Add Audio Files to Xcode

### Step 1: Locate Your Audio Files
Find where you have the MP3 files on your Mac. Common locations:
- `/Users/sobabear/Desktop/iOS/test/Swiftris/Swiftris/Game/Resources/`
- Downloads folder
- Desktop
- Another project

### Step 2: Create Resources Folder in Project
1. Open `OpenGames.xcodeproj` in Xcode
2. In **Project Navigator**, right-click on `OpenGames` folder
3. Select **"New Group"**
4. Name it **"Resources"** or **"Sounds"**

### Step 3: Add Audio Files
1. **Drag** the 4 MP3 files from Finder into your new **Resources** group
2. In the dialog that appears:
   - ✅ Check **"Copy items if needed"** (IMPORTANT!)
   - ✅ Check **"OpenGames"** target
   - ✅ Select **"Create groups"** (not folder references)
   - Click **"Finish"**

### Step 4: Verify Files Are Added
In Project Navigator, you should see:
```
OpenGames/
├── Resources/  (or Sounds/)
│   ├── tetris_original.mp3
│   ├── fall.mp3
│   ├── gameover.mp3
│   └── harddrop.mp3
```

Files should appear in **black text** (not red).

### Step 5: Verify Target Membership
For each MP3 file:
1. Click on the file
2. Open **File Inspector** (right sidebar, first icon)
3. Under **"Target Membership"**, ensure **"OpenGames"** is checked

### Step 6: Build and Run
```
Product → Clean Build Folder (⇧⌘K)
Product → Build (⌘B)
Product → Run (⌘R)
```

🎵 **Sound will now work!**

---

## 🎮 Sound Behavior in Game

### Background Music (BGM)
- Starts when you press **"Play"**
- Pauses when you press **"Pause"**
- Stops when you press **"Stop"** or game ends
- Loops continuously at 10% volume

### Sound Effects
- **Hard Drop**: Plays when you press the **"Drop"** button (⬇)
- **Game Over**: Plays when your pieces reach the top

---

## 🔧 Alternative: If You Don't Have Some Files

If you're missing some files, you can use the same file for multiple purposes:

### Option 1: Use fall.mp3 for both drop sounds
The code uses `fall.mp3` for the drop effect. You don't need `harddrop.mp3`.

### Option 2: Disable Sound Temporarily
If you don't have any audio files, the game will work fine - it just won't play sounds. The `SoundManager` handles missing files gracefully.

### Option 3: Create Placeholder Files
You can use any MP3 files as placeholders:
```bash
cd /Users/sobabear/Desktop/iOS/SimpleGame/OpenGames
mkdir -p Resources
# Copy any MP3 as placeholders
cp ~/Music/song1.mp3 Resources/tetris_original.mp3
cp ~/Music/song2.mp3 Resources/fall.mp3
cp ~/Music/song3.mp3 Resources/gameover.mp3
```

Then add them to Xcode as described above.

---

## 🎵 Finding Free Tetris Music

If you need to download sound files:

1. **Background Music**: Search for "Tetris Theme" or "Tetris Music"
2. **Sound Effects**: Search for "game sound effects", "beep sound", "game over sound"

Make sure to use royalty-free or Creative Commons licensed audio.

---

## 📝 Current Code Setup

The SoundManager is already configured in the code:
- `Swiftris.swift` - Integrates sound with game state
- `SoundManager.swift` - Handles audio playback
- All sound methods are connected and ready to use

Once you add the files, sound will work automatically! 🎶
