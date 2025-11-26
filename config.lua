Config = {}

-- Truck Settings
Config.TruckModel = "stockade" -- Armored truck model
Config.MinPolice = 0 -- Minimum police required to start heist
Config.TruckSpawnChance = 30 -- % chance per minute for truck to spawn

-- Lockpick Settings
Config.RequireLockpick = true -- Require lockpick item
Config.LockpickItem = 'lockpick' -- Item name in inventory
Config.LockpickCircles = 5 -- Number of circles for lockpick (higher = harder)
Config.LockpickDifficulty = 10 -- Speed 1-20 (higher = faster/harder)
Config.LockpickBreakChance = 20 -- % chance to break lockpick on fail
Config.PoliceAlertOnFail = 30 -- % chance police are alerted on failed lockpick

-- Robbery Settings
Config.LootCircles = 3 -- Number of circles for grabbing loot
Config.LootDifficulty = 8 -- Difficulty for loot grab
Config.CooldownTime = 600 -- Cooldown in seconds (10 minutes)

-- Rewards
Config.RewardMin = 5000
Config.RewardMax = 15000
Config.RewardType = 'cash' -- 'cash' or 'bank' or 'black_money'

-- Blip Settings
Config.TruckBlipColor = 1 -- Red
Config.TruckBlipSprite = 67 -- Armored truck icon
Config.TruckBlipScale = 0.8

-- Police Alert Settings
Config.PoliceBlipDuration = 120000 -- 2 minutes
Config.PoliceJobs = { -- Jobs that receive alerts
    'police',
    'sheriff',
    'state'
}

-- Spawn Locations
Config.SpawnLocations = {
    vector4(120.98, -2203.31, 6.03, 267.85),
    vector4(-541.03, -213.48, 37.65, 210.24),
    vector4(1163.27, -330.17, 68.98, 98.23),
    vector4(-1074.39, -2714.03, 13.76, 240.45),
    vector4(257.89, -1210.39, 29.29, 180.76),
    vector4(-2956.85, 482.35, 15.47, 87.42),
    vector4(1731.37, 3310.37, 41.22, 195.89),
    vector4(-22.16, -1105.86, 26.67, 70.45)
}

-- Framework Settings
Config.Framework = 'auto' -- 'auto', 'esx', 'qbcore', or 'standalone'
