-- ================================
-- 🚗 FL EMERGENCY - VEHICLE SYSTEM CLIENT
-- ================================

FL.Vehicles = {
    currentVehicle = nil,
    spawnedVehicles = {},
    vehicleData = {},
    lastSpawnTime = 0
}

-- ================================
-- 🚀 VEHICLE SPAWNING
-- ================================

-- Spawne Emergency Vehicle
function FL.SpawnVehicle(vehicleKey, vehicleData, spawnData)
    -- Cooldown Check
    if GetGameTimer() - FL.Vehicles.lastSpawnTime < 5000 then
        lib.notify({
            type = 'error',
            description = 'Bitte warte 5 Sekunden zwischen Spawns'
        })
        return false
    end

    local coords = spawnData.coords
    local heading = spawnData.heading or 0.0

    -- Spawn-Point Check
    if FL.IsSpawnPointOccupied(coords, 5.0) then
        lib.notify({
            type = 'error',
            description = 'Spawn-Punkt ist blockiert'
        })
        return false
    end

    -- Model Loading
    local model = GetHashKey(vehicleData.model)

    if not IsModelInCdimage(model) then
        lib.notify({
            type = 'error',
            description = 'Fahrzeug-Model nicht gefunden: ' .. vehicleData.model
        })
        return false
    end

    lib.requestModel(model, 10000)

    if not HasModelLoaded(model) then
        lib.notify({
            type = 'error',
            description = 'Fahrzeug konnte nicht geladen werden'
        })
        return false
    end

    -- Spawn Vehicle
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)

    if not vehicle or vehicle == 0 then
        lib.notify({
            type = 'error',
            description = 'Fahrzeug konnte nicht gespawnt werden'
        })
        SetModelAsNoLongerNeeded(model)
        return false
    end

    -- Vehicle Setup
    FL.Vehicles.SetupVehicle(vehicle, vehicleData, vehicleKey)

    -- Tracking
    FL.Vehicles.currentVehicle = vehicle
    FL.Vehicles.lastSpawnTime = GetGameTimer()

    -- Plate Generation
    local plate = FL.GeneratePlateName(FL.Player.service)
    SetVehicleNumberPlateText(vehicle, plate)

    -- Store Data
    FL.Vehicles.spawnedVehicles[vehicle] = {
        key = vehicleKey,
        data = vehicleData,
        plate = plate,
        spawnTime = GetGameTimer()
    }

    -- Keys (falls System vorhanden)
    if GetResourceState('qb-vehiclekeys') == 'started' then
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
    end

    -- Notification
    lib.notify({
        type = 'success',
        description = vehicleData.label .. ' gespawnt'
    })

    SetModelAsNoLongerNeeded(model)

    FL.Log('info', 'Vehicle spawned', {
        vehicle = vehicleKey,
        model = vehicleData.model,
        plate = plate
    })

    return true
end

-- ================================
-- 🔧 VEHICLE SETUP
-- ================================

-- Konfiguriere gespawntes Fahrzeug
function FL.Vehicles.SetupVehicle(vehicle, vehicleData, vehicleKey)
    -- Basis-Setup
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)

    -- Livery
    if vehicleData.livery then
        SetVehicleLivery(vehicle, vehicleData.livery)
    end

    -- Farben
    if vehicleData.colors then
        SetVehicleColors(vehicle, vehicleData.colors.primary, vehicleData.colors.secondary)
    end

    -- Extras
    if vehicleData.features and vehicleData.features.extras then
        for _, extraId in pairs(vehicleData.features.extras) do
            SetVehicleExtra(vehicle, extraId, false) -- false = aktiviert
        end
    end

    -- Sirene
    if vehicleData.features and vehicleData.features.siren then
        SetVehicleHasMutedSirens(vehicle, false)
    end

    -- Fuel System
    if Config.VehicleSettings.fuel.enabled then
        FL.Vehicles.SetupFuel(vehicle, vehicleData)
    end

    -- Damage System
    if Config.VehicleSettings.damage.realistic then
        FL.Vehicles.SetupDamage(vehicle, vehicleData)
    end

    -- Security
    if Config.VehicleSettings.security.lockOnSpawn then
        SetVehicleDoorsLocked(vehicle, 2) -- Locked
    end

    -- Equipment Loading
    FL.Vehicles.SetupEquipment(vehicle, vehicleData)

    -- Special Features
    FL.Vehicles.SetupSpecialFeatures(vehicle, vehicleData)
end

-- Setup Fuel System
function FL.Vehicles.SetupFuel(vehicle, vehicleData)
    local fuelLevel = vehicleData.fuel or 100

    -- Legacy Fuel Support
    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(vehicle, fuelLevel)
    end

    -- ox_fuel Support
    if GetResourceState('ox_fuel') == 'started' then
        Entity(vehicle).state.fuel = fuelLevel
    end

    -- ps-fuel Support
    if GetResourceState('ps-fuel') == 'started' then
        exports['ps-fuel']:SetFuel(vehicle, fuelLevel)
    end
end

-- Setup Damage System
function FL.Vehicles.SetupDamage(vehicle, vehicleData)
    -- Basis-Schäden deaktivieren falls konfiguriert
    if Config.VehicleSettings.damage.disableOnDuty then
        SetEntityCanBeDamaged(vehicle, false)
        SetVehicleCanBreak(vehicle, false)
    end

    -- Realistische Schäden aktivieren
    if Config.VehicleSettings.damage.realistic then
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
    end
end

-- Setup Equipment
function FL.Vehicles.SetupEquipment(vehicle, vehicleData)
    if not vehicleData.equipment then return end

    -- Erstelle Equipment-Interaction
    local coords = GetEntityCoords(vehicle)
    local backCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -3.0, 0.0)

    FL.AddSphereZone({
        coords = backCoords,
        radius = 2.0,
        options = {
            {
                name = 'vehicle_equipment_' .. tostring(vehicle),
                icon = 'fa-solid fa-toolbox',
                label = 'Fahrzeug-Equipment',
                canInteract = function()
                    return FL.Player.onDuty
                end,
                onSelect = function()
                    FL.Vehicles.OpenEquipmentMenu(vehicle, vehicleData)
                end,
                distance = 3.0
            }
        }
    })
end

-- Setup Special Features
function FL.Vehicles.SetupSpecialFeatures(vehicle, vehicleData)
    if not vehicleData.features then return end

    -- Wasserwerfer (Feuerwehr)
    if vehicleData.features.waterCannon then
        FL.Vehicles.SetupWaterCannon(vehicle)
    end

    -- Schaumwerfer (Feuerwehr)
    if vehicleData.features.foamCannon then
        FL.Vehicles.SetupFoamCannon(vehicle)
    end

    -- Leiter (Feuerwehr)
    if vehicleData.features.ladder then
        FL.Vehicles.SetupLadder(vehicle)
    end

    -- Suchscheinwerfer (Polizei/EMS)
    if vehicleData.features.searchlight then
        FL.Vehicles.SetupSearchlight(vehicle)
    end

    -- Winde (EMS Helicopter)
    if vehicleData.features.winch then
        FL.Vehicles.SetupWinch(vehicle)
    end
end

-- ================================
-- 🎛️ VEHICLE FEATURES
-- ================================

-- Wasserwerfer System
function FL.Vehicles.SetupWaterCannon(vehicle)
    CreateThread(function()
        while DoesEntityExist(vehicle) do
            Wait(0)

            local driver = GetPedInVehicleSeat(vehicle, -1)
            if driver == PlayerPedId() and IsControlPressed(0, 86) then -- E
                FL.Vehicles.FireWaterCannon(vehicle)
            end
        end
    end)
end

function FL.Vehicles.FireWaterCannon(vehicle)
    local coords = GetEntityCoords(vehicle)
    local forward = GetEntityForwardVector(vehicle)
    local targetCoords = coords + forward * 20.0

    -- Particle Effect
    UseParticleFxAssetNextCall("core")
    local particle = StartParticleFxLoopedAtCoord("water_cannon_jet", coords.x, coords.y, coords.z + 1.0, 0.0, 0.0,
        GetEntityHeading(vehicle), 2.0, false, false, false)

    -- Sound Effect
    PlaySoundFromEntity(-1, "FIRE_EXTINGUISHER_SPRAY", vehicle, "DLC_CHRISTMAS2017_SOUNDSET", 0, 0)

    -- Cleanup after 2 seconds
    SetTimeout(2000, function()
        StopParticleFxLooped(particle, false)
    end)
end

-- Suchscheinwerfer System
function FL.Vehicles.SetupSearchlight(vehicle)
    CreateThread(function()
        while DoesEntityExist(vehicle) do
            Wait(0)

            local driver = GetPedInVehicleSeat(vehicle, -1)
            if driver == PlayerPedId() and IsControlPressed(0, 74) then -- H
                FL.Vehicles.ToggleSearchlight(vehicle)
                Wait(500)                                               -- Cooldown
            end
        end
    end)
end

function FL.Vehicles.ToggleSearchlight(vehicle)
    local vehicleData = FL.Vehicles.spawnedVehicles[vehicle]
    if not vehicleData then return end

    vehicleData.searchlightOn = not vehicleData.searchlightOn

    if vehicleData.searchlightOn then
        -- Aktiviere Suchscheinwerfer
        SetVehicleSearchlight(vehicle, true, true)
        lib.notify({
            type = 'success',
            description = 'Suchscheinwerfer aktiviert'
        })
    else
        -- Deaktiviere Suchscheinwerfer
        SetVehicleSearchlight(vehicle, false, true)
        lib.notify({
            type = 'info',
            description = 'Suchscheinwerfer deaktiviert'
        })
    end
end

-- ================================
-- 📦 VEHICLE EQUIPMENT MENU
-- ================================

-- Equipment-Menü öffnen
function FL.Vehicles.OpenEquipmentMenu(vehicle, vehicleData)
    local options = {}

    if not vehicleData.equipment then
        table.insert(options, {
            title = 'Keine Equipment verfügbar',
            disabled = true
        })
    else
        -- Equipment Tools
        if vehicleData.equipment.tools then
            for _, tool in pairs(vehicleData.equipment.tools) do
                table.insert(options, {
                    title = tool,
                    description = 'Equipment entnehmen',
                    icon = 'fa-solid fa-tools',
                    onSelect = function()
                        TriggerServerEvent('fl:equipment:request', tool)
                    end
                })
            end
        end

        -- Spezielle Features
        if vehicleData.features then
            table.insert(options, {
                title = '──────────────────',
                disabled = true
            })

            -- Wasserwerfer
            if vehicleData.features.waterCannon then
                table.insert(options, {
                    title = '🌊 Wasserwerfer',
                    description = 'E-Taste zum Aktivieren',
                    icon = 'fa-solid fa-water',
                    disabled = true
                })
            end

            -- Suchscheinwerfer
            if vehicleData.features.searchlight then
                table.insert(options, {
                    title = '🔦 Suchscheinwerfer',
                    description = 'H-Taste zum Umschalten',
                    icon = 'fa-solid fa-flashlight',
                    disabled = true
                })
            end

            -- Leiter
            if vehicleData.features.ladder then
                table.insert(options, {
                    title = '🪜 Leiter',
                    description = 'Y-Taste zum Ausfahren',
                    icon = 'fa-solid fa-ladder',
                    disabled = true
                })
            end
        end
    end

    -- Fahrzeug-Info
    table.insert(options, {
        title = '──────────────────',
        disabled = true
    })

    local plate = GetVehicleNumberPlateText(vehicle)
    local engineHealth = math.floor(GetVehicleEngineHealth(vehicle) / 10)
    local bodyHealth = math.floor(GetVehicleBodyHealth(vehicle) / 10)

    table.insert(options, {
        title = '📋 Fahrzeug-Info',
        description = 'Kennzeichen: ' .. plate,
        metadata = {
            { label = 'Motor',      value = engineHealth .. '%' },
            { label = 'Karosserie', value = bodyHealth .. '%' },
            { label = 'Kraftstoff', value = FL.Vehicles.GetFuelLevel(vehicle) .. '%' }
        },
        disabled = true
    })

    lib.registerContext({
        id = 'vehicle_equipment_' .. tostring(vehicle),
        title = 'Fahrzeug-Equipment - ' .. vehicleData.data.label,
        options = options
    })

    lib.showContext('vehicle_equipment_' .. tostring(vehicle))
end

-- ================================
-- 🔧 VEHICLE MANAGEMENT
-- ================================

-- Despawn Vehicle
function FL.Vehicles.DespawnVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end

    -- Entferne Target-Zonen
    FL.RemoveZone('vehicle_equipment_' .. tostring(vehicle))

    -- Entferne aus Tracking
    FL.Vehicles.spawnedVehicles[vehicle] = nil

    if FL.Vehicles.currentVehicle == vehicle then
        FL.Vehicles.currentVehicle = nil
    end

    -- Lösche Fahrzeug
    DeleteVehicle(vehicle)

    lib.notify({
        type = 'success',
        description = 'Fahrzeug despawned'
    })
end

-- Hole Kraftstoff-Level
function FL.Vehicles.GetFuelLevel(vehicle)
    if not DoesEntityExist(vehicle) then return 0 end

    -- Legacy Fuel
    if GetResourceState('LegacyFuel') == 'started' then
        return math.floor(exports['LegacyFuel']:GetFuel(vehicle))
    end

    -- ox_fuel
    if GetResourceState('ox_fuel') == 'started' then
        return math.floor(Entity(vehicle).state.fuel or 100)
    end

    -- ps-fuel
    if GetResourceState('ps-fuel') == 'started' then
        return math.floor(exports['ps-fuel']:GetFuel(vehicle))
    end

    return 100 -- Default
end

-- Repariere Fahrzeug
function FL.Vehicles.RepairVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end

    SetVehicleFixed(vehicle)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehiclePetrolTankHealth(vehicle, 1000.0)

    lib.notify({
        type = 'success',
        description = 'Fahrzeug repariert'
    })
end

-- ================================
-- 🔄 VEHICLE CLEANUP
-- ================================

-- Cleanup Thread
CreateThread(function()
    while true do
        Wait(Config.VehicleSettings.performance.cleanupInterval)

        for vehicle, data in pairs(FL.Vehicles.spawnedVehicles) do
            if not DoesEntityExist(vehicle) then
                -- Entferne nicht-existierende Fahrzeuge
                FL.Vehicles.spawnedVehicles[vehicle] = nil
            else
                -- Prüfe Idle-Zeit
                local driver = GetPedInVehicleSeat(vehicle, -1)
                if not driver or driver == 0 then
                    local idleTime = GetGameTimer() - data.lastUsed
                    if idleTime > Config.VehicleSettings.performance.maxIdleTime then
                        FL.Vehicles.DespawnVehicle(vehicle)
                    end
                else
                    data.lastUsed = GetGameTimer()
                end
            end
        end
    end
end)

-- ================================
-- 📡 EVENT HANDLERS
-- ================================

-- Vehicle Spawn Event
RegisterNetEvent('fl:vehicle:spawn', function(vehicleKey, vehicleData, spawnData)
    FL.SpawnVehicle(vehicleKey, vehicleData, spawnData)
end)

-- Vehicle Despawn Event
RegisterNetEvent('fl:vehicle:despawn', function(vehicleId)
    if type(vehicleId) == 'string' then
        -- Despawn by plate
        for vehicle, data in pairs(FL.Vehicles.spawnedVehicles) do
            if data.plate == vehicleId then
                FL.Vehicles.DespawnVehicle(vehicle)
                break
            end
        end
    else
        -- Despawn by entity
        FL.Vehicles.DespawnVehicle(vehicleId)
    end
end)

-- Player Left Vehicle
RegisterNetEvent('baseevents:leftVehicle', function(vehicle, seat, displayname, netId)
    if seat == -1 and FL.Vehicles.spawnedVehicles[vehicle] then
        FL.Vehicles.spawnedVehicles[vehicle].lastUsed = GetGameTimer()
    end
end)

-- ================================
-- 🎮 CONTROLS
-- ================================

-- Vehicle Controls Thread
CreateThread(function()
    while true do
        Wait(0)

        if FL.Player.onDuty and FL.Vehicles.currentVehicle then
            local vehicle = FL.Vehicles.currentVehicle
            local driver = GetPedInVehicleSeat(vehicle, -1)

            if driver == PlayerPedId() then
                local vehicleData = FL.Vehicles.spawnedVehicles[vehicle]
                if vehicleData then
                    -- Spezielle Features steuern
                    FL.Vehicles.HandleVehicleControls(vehicle, vehicleData)
                end
            end
        end
    end
end)

-- Handle Vehicle Controls
function FL.Vehicles.HandleVehicleControls(vehicle, vehicleData)
    -- Sirene Toggle (Q)
    if IsControlJustPressed(0, 44) then
        local sirenState = IsVehicleSirenOn(vehicle)
        SetVehicleSiren(vehicle, not sirenState)
    end

    -- Horn Override für Emergency Horn
    if IsControlPressed(0, 86) and vehicleData.data.features and vehicleData.data.features.horn then
        -- Spiele Emergency Horn
        -- (Implementierung hängt von Audio-System ab)
    end
end

-- ================================
-- 📤 EXPORTS
-- ================================

-- Export Functions
exports('SpawnVehicle', FL.SpawnVehicle)
exports('DespawnVehicle', FL.Vehicles.DespawnVehicle)
exports('GetCurrentVehicle', function()
    return FL.Vehicles.currentVehicle
end)
exports('GetSpawnedVehicles', function()
    return FL.Vehicles.spawnedVehicles
end)
