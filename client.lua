local truckVehicles = {}
local truckBlips = {}
local isRobbing = false
local onCooldown = false
local ESX = nil
local QBCore = nil

-- Framework Detection
CreateThread(function()
    if Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    elseif Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

-- Spawn truck on client
RegisterNetEvent('truckheist:spawnTruck')
AddEventHandler('truckheist:spawnTruck', function(truckId, spawn)
    local hash = GetHashKey(Config.TruckModel)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(100)
    end
    
    local truck = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetEntityAsMissionEntity(truck, true, true)
    SetVehicleDoorsLocked(truck, 2)
    SetVehicleDoorShut(truck, 2, false)
    SetVehicleDoorShut(truck, 3, false)
    SetVehicleEngineOn(truck, false, false, true)
    
    truckVehicles[truckId] = truck
    
    -- Create blip
    local blip = AddBlipForEntity(truck)
    SetBlipSprite(blip, Config.TruckBlipSprite)
    SetBlipColour(blip, Config.TruckBlipColor)
    SetBlipScale(blip, Config.TruckBlipScale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Armored Truck")
    EndTextCommandSetBlipName(blip)
    
    truckBlips[truckId] = blip
    
    ShowNotification('~b~INFO~w~: An armored truck has been spotted on your GPS!')
end)

-- Remove truck
RegisterNetEvent('truckheist:removeTruck')
AddEventHandler('truckheist:removeTruck', function(truckId)
    if truckVehicles[truckId] then
        if DoesEntityExist(truckVehicles[truckId]) then
            DeleteEntity(truckVehicles[truckId])
        end
        truckVehicles[truckId] = nil
    end
    
    if truckBlips[truckId] then
        RemoveBlip(truckBlips[truckId])
        truckBlips[truckId] = nil
    end
end)

-- Check for nearby trucks
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local nearTruck = false
        
        for id, truck in pairs(truckVehicles) do
            if DoesEntityExist(truck) then
                local truckCoords = GetEntityCoords(truck)
                local backDoorCoords = GetOffsetFromEntityInWorldCoords(truck, 0.0, -3.5, 0.0)
                local dist = #(coords - backDoorCoords)
                
                if dist < 10.0 then
                    nearTruck = true
                    
                    if dist < 2.0 and not isRobbing then
                        DrawText3D(backDoorCoords.x, backDoorCoords.y, backDoorCoords.z + 0.5, '[~g~E~w~] Lockpick Truck')
                        
                        if IsControlJustPressed(0, 38) then -- E key
                            StartLockpick(id, truck)
                        end
                    end
                end
            end
        end
        
        if not nearTruck then
            Wait(500)
        end
    end
end)

function StartLockpick(truckId, truck)
    if onCooldown then
        ShowNotification('~r~You need to wait before robbing another truck!')
        return
    end
    
    if isRobbing then
        ShowNotification('~r~You are already robbing a truck!')
        return
    end
    
    TriggerServerEvent('truckheist:checkLockpick', truckId)
end

-- Start lockpick minigame
RegisterNetEvent('truckheist:startLockpick')
AddEventHandler('truckheist:startLockpick', function(truckId)
    local ped = PlayerPedId()
    
    -- Freeze player
    FreezeEntityPosition(ped, true)
    
    -- Play lockpick animation
    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
        Wait(100)
    end
    TaskPlayAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, 8.0, -1, 1, 0, false, false, false)
    
    -- Start ps-ui circle lockpick
    exports['ps-ui']:Circle(function(success)
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)
        
        if success then
            ShowNotification('~g~Lockpick successful!')
            TriggerServerEvent('truckheist:lockpickSuccess', truckId)
        else
            ShowNotification('~r~Lockpick failed!')
            TriggerServerEvent('truckheist:lockpickFailed', truckId)
        end
    end, Config.LockpickCircles, Config.LockpickDifficulty)
end)

-- Start robbery after successful lockpick
RegisterNetEvent('truckheist:robberyStarted')
AddEventHandler('truckheist:robberyStarted', function(truckId)
    local ped = PlayerPedId()
    isRobbing = true
    
    -- Open back doors
    if truckVehicles[truckId] then
        SetVehicleDoorOpen(truckVehicles[truckId], 2, false, false)
        SetVehicleDoorOpen(truckVehicles[truckId], 3, false, false)
    end
    
    -- Play animation
    RequestAnimDict("anim@gangops@facility@servers@")
    while not HasAnimDictLoaded("anim@gangops@facility@servers@") do
        Wait(100)
    end
    
    TaskPlayAnim(ped, "anim@gangops@facility@servers@", "hotwire", 8.0, 8.0, -1, 1, 0, false, false, false)
    
    ShowNotification('~y~Grabbing the loot...')
    
    -- Progress with ps-ui
    exports['ps-ui']:Circle(function(success)
        ClearPedTasks(ped)
        
        if success then
            TriggerServerEvent('truckheist:completeRobbery', truckId)
            isRobbing = false
            onCooldown = true
            
            -- Cooldown timer
            SetTimeout(Config.CooldownTime * 1000, function()
                onCooldown = false
                ShowNotification('~g~You can rob trucks again!')
            end)
        else
            CancelRobbery()
        end
    end, Config.LootCircles, Config.LootDifficulty)
end)

function CancelRobbery()
    isRobbing = false
    ClearPedTasksImmediately(PlayerPedId())
    ShowNotification('~r~Robbery cancelled!')
end

-- Check if player is police
function IsPolice()
    if Config.Framework == 'esx' and ESX then
        local playerData = ESX.GetPlayerData()
        if playerData.job then
            for _, job in pairs(Config.PoliceJobs) do
                if playerData.job.name == job then
                    return true
                end
            end
        end
    elseif Config.Framework == 'qbcore' and QBCore then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData.job then
            for _, job in pairs(Config.PoliceJobs) do
                if playerData.job.name == job and playerData.job.onduty then
                    return true
                end
            end
        end
    end
    return false
end

-- Police alert
RegisterNetEvent('truckheist:policeAlert')
AddEventHandler('truckheist:policeAlert', function(coords)
    if IsPolice() then
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 161)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 1.2)
        SetBlipAsShortRange(blip, false)
        SetBlipFlashes(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("10-90: Truck Robbery")
        EndTextCommandSetBlipName(blip)
        
        ShowNotification('~r~[DISPATCH]~w~: Armored truck robbery in progress!')
        PlaySoundFrontend(-1, "Lose_1st", "GTAO_FM_Events_Soundset", false)
        
        SetTimeout(Config.PoliceBlipDuration, function()
            RemoveBlip(blip)
        end)
    end
end)

-- Notification helper
RegisterNetEvent('truckheist:notify')
AddEventHandler('truckheist:notify', function(msg)
    ShowNotification(msg)
end)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
    end
end
