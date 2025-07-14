-- ================================
-- 🚨 FL EMERGENCY SERVICES - CLIENT MAIN (FIXED)
-- ================================

-- Wait for QBCore to be ready
local QBCore = exports['qb-core']:GetCoreObject()

-- Wait for ox_lib to be ready
while not lib do Wait(100) end

-- ================================
-- 📊 CLIENT STATE MANAGEMENT
-- ================================

FL = {
    -- Player Data
    Player = {
        data = {},
        service = nil,
        onDuty = false,
        currentStation = nil,
        currentVehicle = nil
    },

    -- System State
    State = {
        activeCalls = {},
        nearbyPlayers = {},
        stationsLoaded = false,
        uiOpen = false
    },

    -- Threads
    Threads = {
        stationCheck = nil,
        interactionCheck = nil
    },

    -- Cache
    Cache = {
        stations = {},
        vehicles = {},
        lastUpdate = 0
    }
}

-- ================================
-- 🔧 SYSTEM INITIALIZATION
-- ================================

CreateThread(function()
    -- Warte auf Spieler-Login
    while not LocalPlayer.state.isLoggedIn do
        Wait(1000)
    end

    -- Initialisiere Player Data
    QBCore.Functions.GetPlayerData(function(PlayerData)
        FL.Player.data = PlayerData
        FL.UpdatePlayerService()

        -- Setup nur wenn Emergency Service
        if FL.Player.service then
            -- Warte auf Target-System
            while not FL.Target or not FL.Target.Available do
                Wait(100)
            end

            -- Setup Stations
            FL.SetupStations()

            -- Starte Threads
            FL.StartThreads()

            if Config.Debug then
                print('^2[FL Client]^7 Emergency services initialized for: ' .. FL.Player.service)
            end
        else
            if Config.Debug then
                print('^3[FL Client]^7 Player is not emergency service member, skipping initialization')
            end
        end
    end)
end)

-- ================================
-- 🎯 PLAYER SERVICE MANAGEMENT
-- ================================

function FL.UpdatePlayerService()
    local job = FL.Player.data.job.name
    FL.Player.service = nil

    for service, data in pairs(Config.Services) do
        if data.job == job then
            FL.Player.service = service
            FL.Player.onDuty = FL.Player.data.job.onduty or false
            break
        end
    end

    if Config.Debug and FL.Player.service then
        print('^3[FL Debug]^7 Player service: ' .. FL.Player.service .. ' (Duty: ' .. tostring(FL.Player.onDuty) .. ')')
    end
end

-- ================================
-- 🏢 STATION SETUP
-- ================================

function FL.SetupStations()
    if FL.State.stationsLoaded then return end

    for service, stations in pairs(Config.Stations) do
        for stationId, stationData in pairs(stations) do
            FL.SetupStation(service, stationId, stationData)
        end
    end

    FL.State.stationsLoaded = true
    if Config.Debug then print('^2[FL Debug]^7 All stations loaded') end
end

function FL.SetupStation(service, stationId, stationData)
    -- Duty Point Setup
    if stationData.dutyPoint then
        FL.AddBoxZone({
            coords = stationData.dutyPoint.coords,
            size = stationData.dutyPoint.size,
            rotation = stationData.dutyPoint.rotation or 0,
            options = {
                {
                    name = 'fl_duty_' .. stationId,
                    icon = stationData.dutyPoint.icon,
                    label = stationData.dutyPoint.label,
                    groups = { service },
                    onSelect = function()
                        FL.OpenDutyMenu(service, stationId)
                    end,
                    distance = Config.Interaction.targetDistance or 3.0
                }
            }
        })
    end

    -- Equipment Point Setup
    if stationData.equipment then
        FL.AddBoxZone({
            coords = stationData.equipment.coords,
            size = stationData.equipment.size,
            rotation = 0,
            options = {
                {
                    name = 'fl_equipment_' .. stationId,
                    icon = stationData.equipment.icon,
                    label = stationData.equipment.label,
                    groups = { service },
                    canInteract = function()
                        return FL.Player.onDuty and FL.Player.service == service
                    end,
                    onSelect = function()
                        FL.OpenEquipmentMenu(service, stationId)
                    end,
                    distance = Config.Interaction.targetDistance or 3.0
                }
            }
        })
    end

    -- Vehicle Spawns Setup
    if stationData.vehicles then
        for i, vehicleSpawn in pairs(stationData.vehicles) do
            FL.AddBoxZone({
                coords = vehicleSpawn.coords,
                size = vector3(3.0, 6.0, 2.0),
                rotation = vehicleSpawn.heading or 0,
                options = {
                    {
                        name = 'fl_vehicle_' .. stationId .. '_' .. i,
                        icon = 'fa-solid fa-car',
                        label = 'Fahrzeug spawnen',
                        groups = { service },
                        canInteract = function()
                            return FL.Player.onDuty and FL.Player.service == service
                        end,
                        onSelect = function()
                            FL.OpenVehicleMenu(service, stationId, i, vehicleSpawn)
                        end,
                        distance = Config.Interaction.targetDistance or 3.0
                    }
                }
            })
        end
    end

    -- Wardrobe Setup
    if stationData.wardrobe then
        FL.AddBoxZone({
            coords = stationData.wardrobe.coords,
            size = stationData.wardrobe.size,
            rotation = 0,
            options = {
                {
                    name = 'fl_wardrobe_' .. stationId,
                    icon = stationData.wardrobe.icon,
                    label = stationData.wardrobe.label,
                    groups = { service },
                    onSelect = function()
                        FL.OpenWardrobeMenu(service, stationId)
                    end,
                    distance = Config.Interaction.targetDistance or 3.0
                }
            }
        })
    end
end

-- ================================
-- 📱 UI MENUS
-- ================================

function FL.OpenDutyMenu(service, stationId)
    local serviceData = Config.Services[service]

    lib.registerContext({
        id = 'fl_duty_' .. service,
        title = serviceData.label,
        options = {
            {
                title = FL.Player.onDuty and 'Dienst beenden' or 'Dienst beginnen',
                description = FL.Player.onDuty and 'Dienstzeit beenden und Equipment abgeben' or
                    'Dienstzeit beginnen und Equipment erhalten',
                icon = FL.Player.onDuty and 'fa-solid fa-clock-o' or 'fa-solid fa-clock',
                iconColor = FL.Player.onDuty and '#e74c3c' or '#2ecc71',
                onSelect = function()
                    TriggerServerEvent('fl:duty:toggle', stationId)
                end
            },
            {
                title = 'Fahrzeug-Garage',
                description = 'Einsatzfahrzeuge spawnen und verwalten',
                icon = 'fa-solid fa-car',
                iconColor = serviceData.color,
                disabled = not FL.Player.onDuty,
                onSelect = function()
                    FL.OpenVehicleMenu(service, stationId)
                end
            },
            {
                title = 'Ausrüstung',
                description = 'Equipment und Ausrüstung verwalten',
                icon = 'fa-solid fa-toolbox',
                iconColor = serviceData.color,
                disabled = not FL.Player.onDuty,
                onSelect = function()
                    FL.OpenEquipmentMenu(service, stationId)
                end
            },
            {
                title = 'Einsatz-Zentrale',
                description = 'Aktive Einsätze anzeigen und verwalten',
                icon = 'fa-solid fa-radio',
                iconColor = serviceData.color,
                disabled = not FL.Player.onDuty,
                onSelect = function()
                    FL.OpenCallCenter(service)
                end
            }
        }
    })

    lib.showContext('fl_duty_' .. service)
end

function FL.OpenVehicleMenu(service, stationId, spawnIndex, spawnData)
    local serviceData = Config.Services[service]
    local vehicles = Config.Vehicles[service]
    local options = {}

    if not vehicles then
        table.insert(options, {
            title = 'Keine Fahrzeuge verfügbar',
            disabled = true
        })
    else
        for category, categoryVehicles in pairs(vehicles) do
            for vehicleKey, vehicleData in pairs(categoryVehicles) do
                local playerRank = FL.GetPlayerRank()
                local canSpawn = playerRank >= (vehicleData.requiredGrade or 0)

                table.insert(options, {
                    title = vehicleData.label,
                    description = canSpawn and ('Kategorie: ' .. category .. ' | Plätze: ' .. (vehicleData.seats or 4)) or
                    ('Rang ' .. (vehicleData.requiredGrade or 0) .. ' benötigt'),
                    icon = 'fa-solid fa-car',
                    iconColor = canSpawn and serviceData.color or '#95a5a6',
                    disabled = not canSpawn,
                    metadata = {
                        { label = 'Rang benötigt', value = vehicleData.requiredGrade or 0 },
                        { label = 'Sitze',         value = vehicleData.seats or 4 },
                        { label = 'Kategorie',     value = category }
                    },
                    onSelect = function()
                        FL.RequestVehicleSpawn(vehicleKey, vehicleData, spawnData or {
                            coords = GetEntityCoords(PlayerPedId()),
                            heading = GetEntityHeading(PlayerPedId())
                        })
                    end
                })
            end
        end
    end

    lib.registerContext({
        id = 'fl_vehicles_' .. service,
        title = 'Fahrzeug-Garage - ' .. serviceData.label,
        options = options
    })

    lib.showContext('fl_vehicles_' .. service)
end

function FL.OpenEquipmentMenu(service, stationId)
    local serviceData = Config.Services[service]
    local equipment = serviceData.equipment
    local options = {}

    -- Items
    if equipment and equipment.items then
        for _, item in pairs(equipment.items) do
            table.insert(options, {
                title = item,
                description = 'Equipment-Item anfordern',
                icon = 'fa-solid fa-tools',
                iconColor = serviceData.color,
                onSelect = function()
                    TriggerServerEvent('fl:equipment:request', item)
                end
            })
        end
    end

    -- Waffen (nur Polizei)
    if equipment and equipment.weapons and service == 'police' then
        table.insert(options, {
            title = 'Waffenkammer',
            description = 'Dienstwaffen anfordern',
            icon = 'fa-solid fa-gun',
            iconColor = '#e74c3c',
            onSelect = function()
                FL.OpenArmoryMenu(service)
            end
        })
    end

    if #options == 0 then
        table.insert(options, {
            title = 'Keine Ausrüstung verfügbar',
            disabled = true
        })
    end

    lib.registerContext({
        id = 'fl_equipment_' .. service,
        title = 'Ausrüstung - ' .. serviceData.label,
        options = options
    })

    lib.showContext('fl_equipment_' .. service)
end

function FL.OpenWardrobeMenu(service, stationId)
    local serviceData = Config.Services[service]
    local uniforms = serviceData.uniforms
    local gender = GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') and 'female' or 'male'
    local options = {}

    if uniforms and uniforms[gender] then
        for uniformId, uniformData in pairs(uniforms[gender]) do
            table.insert(options, {
                title = 'Uniform ' .. (uniformId + 1),
                description = 'Dienstkleidung anziehen',
                icon = 'fa-solid fa-shirt',
                iconColor = serviceData.color,
                onSelect = function()
                    FL.ApplyUniform(uniformData)
                end
            })
        end
    end

    -- Zivil-Option
    table.insert(options, {
        title = 'Zivilkleidung',
        description = 'Zurück zur normalen Kleidung',
        icon = 'fa-solid fa-user',
        iconColor = '#7f8c8d',
        onSelect = function()
            FL.ApplyCivilianClothing()
        end
    })

    lib.registerContext({
        id = 'fl_wardrobe_' .. service,
        title = 'Umkleidekabine - ' .. serviceData.label,
        options = options
    })

    lib.showContext('fl_wardrobe_' .. service)
end

-- ================================
-- 🚗 VEHICLE MANAGEMENT
-- ================================

function FL.RequestVehicleSpawn(vehicleKey, vehicleData, spawnData)
    local coords = spawnData.coords
    local heading = spawnData.heading or 0.0

    -- Prüfe ob Platz frei ist
    if FL.IsSpawnPointOccupied(coords, 5.0) then
        lib.notify({
            type = 'error',
            description = 'Spawn-Punkt ist blockiert'
        })
        return
    end

    -- Trigger Server Event für Spawn
    TriggerServerEvent('fl:vehicle:requestSpawn', vehicleKey, vehicleData, spawnData)
end

function FL.IsSpawnPointOccupied(coords, radius)
    local vehicles = GetGamePool('CVehicle')

    for _, vehicle in pairs(vehicles) do
        local distance = #(coords - GetEntityCoords(vehicle))
        if distance < radius then
            return true
        end
    end

    return false
end

function FL.GeneratePlateName(service)
    local prefixes = {
        fire = 'FW',
        police = 'POL',
        ems = 'RD'
    }

    local prefix = prefixes[service] or 'FL'
    local number = math.random(100, 999)

    return prefix .. number
end

-- ================================
-- 👕 UNIFORM SYSTEM
-- ================================

function FL.ApplyUniform(uniformData)
    local playerPed = PlayerPedId()

    -- Setze Components
    if uniformData.components then
        for component, data in pairs(uniformData.components) do
            SetPedComponentVariation(playerPed, component, data.drawable, data.texture, 0)
        end
    end

    -- Setze Props
    if uniformData.props then
        for prop, data in pairs(uniformData.props) do
            if data.drawable == -1 then
                ClearPedProp(playerPed, prop)
            else
                SetPedPropIndex(playerPed, prop, data.drawable, data.texture, true)
            end
        end
    end

    lib.notify({
        type = 'success',
        description = 'Uniform angezogen'
    })
end

function FL.ApplyCivilianClothing()
    -- Trigger QBCore Clothing Event
    TriggerEvent('qb-clothing:client:loadPlayerClothing')

    lib.notify({
        type = 'success',
        description = 'Zivilkleidung angezogen'
    })
end

-- ================================
-- 🔧 UTILITY FUNCTIONS
-- ================================

function FL.GetPlayerRank()
    if not FL.Player.data.job then return 0 end
    return FL.Player.data.job.grade.level or 0
end

function FL.IsNearStation(service)
    if not Config.Stations[service] then return false end

    local playerCoords = GetEntityCoords(PlayerPedId())

    for stationId, stationData in pairs(Config.Stations[service]) do
        local distance = #(playerCoords - stationData.coords)
        if distance < 50.0 then
            return true, stationId, stationData
        end
    end

    return false
end

-- ================================
-- 🔄 THREADS
-- ================================

function FL.StartThreads()
    -- Station Check Thread
    FL.Threads.stationCheck = CreateThread(function()
        while true do
            Wait(Config.Threads and Config.Threads.stationCheck or 5000)

            if FL.Player.service then
                local near, stationId = FL.IsNearStation(FL.Player.service)
                FL.Player.currentStation = near and stationId or nil
            end
        end
    end)
end

-- ================================
-- 📡 EVENT HANDLERS
-- ================================

-- Player Job Update
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    FL.Player.data.job = JobInfo
    FL.UpdatePlayerService()
end)

-- Duty Started
RegisterNetEvent('fl:duty:started', function(data)
    FL.Player.onDuty = true
    FL.Player.currentStation = data.station

    -- Uniform anziehen
    if Config.Duty and Config.Duty.uniformAutoEquip and data.service == FL.Player.service then
        local serviceData = Config.Services[data.service]
        local gender = GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') and 'female' or 'male'

        if serviceData.uniforms and serviceData.uniforms[gender] and serviceData.uniforms[gender][0] then
            FL.ApplyUniform(serviceData.uniforms[gender][0])
        end
    end
end)

-- Duty Ended
RegisterNetEvent('fl:duty:ended', function(data)
    FL.Player.onDuty = false
    FL.Player.currentStation = nil

    -- Zivil-Kleidung
    FL.ApplyCivilianClothing()

    -- Despawn aktuelles Fahrzeug
    if FL.Player.currentVehicle and DoesEntityExist(FL.Player.currentVehicle) then
        DeleteVehicle(FL.Player.currentVehicle)
        FL.Player.currentVehicle = nil
    end
end)

-- Call Events
RegisterNetEvent('fl:callCreated', function(call)
    if FL.Player.service == call.service then
        FL.State.activeCalls[call.id] = call

        lib.notify({
            type = 'error',
            title = 'Neuer Einsatz',
            description = call.type .. ' - Priorität ' .. call.priority,
            duration = 8000
        })

        -- Spiele Sound
        if Config.Notifications and Config.Notifications.playSound then
            PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
        end
    end
end)

RegisterNetEvent('fl:callUpdated', function(call)
    FL.State.activeCalls[call.id] = call
end)

RegisterNetEvent('fl:callClosed', function(data)
    FL.State.activeCalls[data.id] = nil
end)

-- Vehicle Events
RegisterNetEvent('fl:vehicle:despawn', function(vehicleId)
    if FL.Player.currentVehicle == vehicleId then
        if DoesEntityExist(FL.Player.currentVehicle) then
            DeleteVehicle(FL.Player.currentVehicle)
        end
        FL.Player.currentVehicle = nil
    end
end)

-- System Shutdown
RegisterNetEvent('fl:system:shutdown', function()
    lib.notify({
        type = 'error',
        title = 'System-Nachricht',
        description = 'Emergency Services System wird neu gestartet...'
    })
end)

-- ================================
-- 📝 COMMANDS
-- ================================

RegisterCommand('mdt', function()
    if not FL.Player.service then
        lib.notify({
            type = 'error',
            description = 'Du bist kein Mitglied eines Emergency Service'
        })
        return
    end

    if not FL.Player.onDuty then
        lib.notify({
            type = 'error',
            description = 'Du musst im Dienst sein'
        })
        return
    end

    FL.OpenCallCenter(FL.Player.service)
end)

-- Debug-Command
RegisterCommand('mdtdebug', function()
    SetNuiFocus(true, true)

    -- Öffne Debug-Interface
    SendNUIMessage({
        type = 'openDebug'
    })

    lib.notify({
        type = 'info',
        description = 'Debug-MDT geöffnet'
    })
end)

function FL.OpenCallCenter(service)
    if FL.State.uiOpen then return end
    FL.State.uiOpen = true
    SetNuiFocus(true, true)

    -- Service Data definieren
    local serviceData = Config.Services[service] or {
        label = 'Emergency Service',
        icon = 'fa-solid fa-shield',
        color = '#3498db'
    }

    SendNUIMessage({
        type = 'openMDT',
        service = service,
        serviceData = serviceData,
        calls = FL.State.activeCalls,
        playerData = FL.Player,
        config = {}
    })
end

-- ================================
-- 🌐 NUI CALLBACKS
-- ================================

RegisterNUICallback('closeUI', function(data, cb)
    FL.State.uiOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('assignCall', function(data, cb)
    TriggerServerEvent('fl:call:assign', data.callId)
    cb('ok')
end)
