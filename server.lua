local activeTrucks = {}
local ESX = nil
local QBCore = nil

-- Framework Detection
CreateThread(function()
    if Config.Framework == 'auto' then
        if GetResourceState('es_extended') == 'started' then
            Config.Framework = 'esx'
        elseif GetResourceState('qb-core') == 'started' then
            Config.Framework = 'qbcore'
        else
            Config.Framework = 'standalone'
        end
    end
    
    if Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    elseif Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
    
    print('[Truck Heist] Loaded with framework: ' .. Config.Framework)
end)

-- Spawn random truck event
CreateThread(function()
    Wait(5000) -- Wait for server to fully load
    while true do
        Wait(60000) -- Check every minute
        if math.random(100) <= Config.TruckSpawnChance then
            SpawnTruck()
        end
    end
end)

function SpawnTruck()
    local spawn = Config.SpawnLocations[math.random(#Config.SpawnLocations)]
    local truckId = #activeTrucks + 1
    
    activeTrucks[truckId] = {
        coords = vector3(spawn.x, spawn.y, spawn.z),
        heading = spawn.w,
        robbed = false
    }
    
    TriggerClientEvent('truckheist:spawnTruck', -1, truckId, spawn)
    print('[Truck Heist] Armored truck #' .. truckId .. ' spawned')
end

-- Check if player has lockpick
function HasLockpick(src)
    if not Config.RequireLockpick then
        return true
    end
    
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local lockpick = xPlayer.getInventoryItem(Config.LockpickItem)
            return lockpick and lockpick.count > 0
        end
    elseif Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local lockpick = Player.Functions.GetItemByName(Config.LockpickItem)
            return lockpick ~= nil
        end
    else
        return true -- Standalone mode
    end
    
    return false
end

-- Remove lockpick item
function RemoveLockpick(src)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.removeInventoryItem(Config.LockpickItem, 1)
        end
    elseif Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.RemoveItem(Config.LockpickItem, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.LockpickItem], "remove")
        end
    end
end

-- Give money reward
function GiveMoney(src, amount)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            if Config.RewardType == 'black_money' then
                xPlayer.addAccountMoney('black_money', amount)
            elseif Config.RewardType == 'bank' then
                xPlayer.addAccountMoney('bank', amount)
            else
                xPlayer.addMoney(amount)
            end
        end
    elseif Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddMoney(Config.RewardType, amount)
        end
    end
end

-- Get police count
function GetPoliceCount()
    local count = 0
    
    if Config.Framework == 'esx' then
        local xPlayers = ESX.GetExtendedPlayers()
        for _, xPlayer in pairs(xPlayers) do
            for _, job in pairs(Config.PoliceJobs) do
                if xPlayer.job.name == job then
                    count = count + 1
                    break
                end
            end
        end
    elseif Config.Framework == 'qbcore' then
        local Players = QBCore.Functions.GetQBPlayers()
        for _, Player in pairs(Players) do
            for _, job in pairs(Config.PoliceJobs) do
                if Player.PlayerData.job.name == job and Player.PlayerData.job.onduty then
                    count = count + 1
                    break
                end
            end
        end
    end
    
    return count
end

RegisterNetEvent('truckheist:checkLockpick')
AddEventHandler('truckheist:checkLockpick', function(truckId)
    local src = source
    
    if not activeTrucks[truckId] then
        TriggerClientEvent('truckheist:notify', src, '~r~This truck no longer exists!')
        return
    end
    
    if activeTrucks[truckId].robbed then
        TriggerClientEvent('truckheist:notify', src, '~r~This truck has already been robbed!')
        return
    end
    
    local policeCount = GetPoliceCount()
    if policeCount < Config.MinPolice then
        TriggerClientEvent('truckheist:notify', src, '~r~Not enough police online! (' .. policeCount .. '/' .. Config.MinPolice .. ')')
        return
    end
    
    if HasLockpick(src) then
        TriggerClientEvent('truckheist:startLockpick', src, truckId)
    else
        TriggerClientEvent('truckheist:notify', src, '~r~You need a lockpick!')
    end
end)

RegisterNetEvent('truckheist:lockpickSuccess')
AddEventHandler('truckheist:lockpickSuccess', function(truckId)
    local src = source
    
    if activeTrucks[truckId] and not activeTrucks[truckId].robbed then
        TriggerClientEvent('truckheist:robberyStarted', src, truckId)
        TriggerClientEvent('truckheist:policeAlert', -1, activeTrucks[truckId].coords)
    end
end)

RegisterNetEvent('truckheist:lockpickFailed')
AddEventHandler('truckheist:lockpickFailed', function(truckId)
    local src = source
    
    -- Chance to break lockpick
    if math.random(100) <= Config.LockpickBreakChance then
        RemoveLockpick(src)
        TriggerClientEvent('truckheist:notify', src, '~r~Your lockpick broke!')
    else
        TriggerClientEvent('truckheist:notify', src, '~o~Lockpick failed! Try again.')
    end
    
    -- Chance to alert police on failed attempts
    if activeTrucks[truckId] and math.random(100) <= Config.PoliceAlertOnFail then
        TriggerClientEvent('truckheist:policeAlert', -1, activeTrucks[truckId].coords)
    end
end)

RegisterNetEvent('truckheist:completeRobbery')
AddEventHandler('truckheist:completeRobbery', function(truckId)
    local src = source
    
    if activeTrucks[truckId] and not activeTrucks[truckId].robbed then
        activeTrucks[truckId].robbed = true
        
        local reward = math.random(Config.RewardMin, Config.RewardMax)
        GiveMoney(src, reward)
        
        TriggerClientEvent('truckheist:notify', src, '~g~Robbery successful! You got $' .. reward)
        TriggerClientEvent('truckheist:removeTruck', -1, truckId)
        
        print('[Truck Heist] Player ' .. GetPlayerName(src) .. ' (' .. src .. ') robbed truck #' .. truckId .. ' for $' .. reward)
    end
end)

-- Admin command to spawn truck
RegisterCommand('spawntruck', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, 'truckheist.admin') then
        SpawnTruck()
        if source ~= 0 then
            TriggerClientEvent('truckheist:notify', source, '~g~Truck spawned!')
        end
    end
end, false)
