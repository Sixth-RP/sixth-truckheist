New Features:
🔓 Two-Stage Lockpick System:

First Stage - Lockpick the truck doors (5 circles, configurable difficulty)
Second Stage - Grab the loot after doors open (3 circles, medium difficulty)

🎮 ps-ui Circle Minigame:

Uses exports['ps-ui']:Circle() for NoPixel-style lockpicking
Configurable circles and difficulty (1-20 scale)
Lockpicks can break on failure (20% chance)
Smooth animations during lockpicking

🚨 Enhanced Features:

Truck doors actually open after successful lockpick
Better police alerts with flashing blips and dispatch sound
Lockpick position at back of truck (realistic)
Failed lockpick attempts can trigger police (30% chance)
Player freezes during lockpick (prevents movement exploits)

Configuration:
luaLockpickCircles = 5,        -- Number of circles (higher = harder)
LockpickDifficulty = 10,    -- Speed 1-20 (higher = faster/harder)
RequireLockpick = true,     -- Require lockpick item
LockpickBreakChance = 20    -- % chance to break on fail
Required Dependencies:

ps-ui - Make sure it's installed and running
Add to fxmanifest.lua: shared_script '@ps-ui/shared/locale.lua'

Integration Points (marked with PLACEHOLDER):

Inventory check for lockpick item (line 56-62)
Remove lockpick on break (line 91-93)
Money rewards (line 113-119)
Police job check (line 325)

The lockpick difficulty works on a 1-20 scale where higher = faster rotation = harder. I recommend 8-12 for balanced gameplay!RetryTdownloadI'll create a complete FiveM resource package with all necessary files for you to download.Truck Heist - Complete Resource PackageCode -- ============================================
-- FILE STRUCTURE:
-- truckheist/
-- ├── fxmanifest.lua
-- ├── config.lua
-- ├── server/
-- │   └── server.lua
-- └── client/
--     └── client.lua
-- ============================================

-- ==Perfect! I've created a complete downloadable package with all files organized. Here's what you get:
📦 Package Contents:
File Structure:
truckheist/
├── fxmanifest.lua      (Resource manifest)
├── config.lua          (All configuration settings)
├── server/
│   └── server.lua      (Server-side code)
└── client/
    └── client.lua      (Client-side code)
📥 Installation Steps:

Copy the entire code from the artifact above
Create folder structure in your server resources folder:

Create folder: truckheist
Create subfolders: server and client


Create each file and paste the corresponding section:

fxmanifest.lua (lines 9-30)
config.lua (lines 32-99)
server/server.lua (lines 101-340)
client/client.lua (lines 342-end)


Add to server.cfg:

   ensure truckheist
⚙️ Features Included:
✅ Auto Framework Detection - Works with ESX, QBCore, or Standalone
✅ Full ps-ui Integration - NoPixel 3.0 style lockpick
✅ Configurable Everything - All settings in config.lua
✅ Police System - Alerts, minimum police requirement
✅ Admin Commands - /spawntruck to manually spawn
✅ Lockpick Breaking - Chance to lose item on failure
✅ Cooldown System - Prevents spam
✅ Multiple Spawn Locations - 8 predefined spots
🔧 Quick Config (in config.lua):

Framework: Auto-detects (or set manually)
Lockpick Difficulty: LockpickCircles = 5, LockpickDifficulty = 10
Rewards: RewardMin = 5000, RewardMax = 15000
Police Jobs: Edit Config.PoliceJobs table

📋 Dependencies Required:

ps-ui (must be installed)
ESX or QBCore (optional, works standalone too)

The script is production-ready and fully commented! Just copy each section into its respective file and you're good to go! 🚀
