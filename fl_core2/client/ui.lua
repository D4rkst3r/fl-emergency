-- ================================
-- 🎨 FL EMERGENCY - UI MANAGEMENT CLIENT
-- ================================

FL.UI = {}

-- ================================
-- 📱 MDT (MOBILE DATA TERMINAL)
-- ================================

-- Öffne MDT
function FL.UI.OpenMDT(service)
    if FL.State.uiOpen then return end

    FL.State.uiOpen = true
    SetNuiFocus(true, true)

    -- Sammle Daten
    local playerData = {
        service = service,
        rank = FL.GetPlayerRank(),
        station = FL.Player.currentStation,
        onDuty = FL.Player.onDuty
    }

    local serviceData = Config.Services[service]

    SendNUIMessage({
        type = 'openMDT',
        service = service,
        serviceData = serviceData,
        calls = FL.State.activeCalls,
        playerData = playerData,
        config = {
            colors = Config.ServiceColors[service],
            settings = Config.MDT
        }
    })
end

-- Schließe MDT
function FL.UI.CloseMDT()
    if not FL.State.uiOpen then return end

    FL.State.uiOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        type = 'closeMDT'
    })
end

-- ================================
-- 🎮 CONTEXT MENUS
-- ================================

-- Erstelle Service-Hauptmenü
function FL.UI.CreateServiceMenu(service, stationId)
    local serviceData = Config.Services[service]
    local options = {}

    -- Duty Toggle
    table.insert(options, {
        title = FL.Player.onDuty and 'Dienst beenden' or 'Dienst beginnen',
        description = FL.Player.onDuty and 'Schichtende und Equipment abgeben' or 'Schichtbeginn und Equipment erhalten',
        icon = FL.Player.onDuty and 'fa-solid fa-sign-out-alt' or 'fa-solid fa-sign-in-alt',
        iconColor = FL.Player.onDuty and '#e74c3c' or '#2ecc71',
        onSelect = function()
            TriggerServerEvent('fl:duty:toggle', stationId)
        end
    })

    -- Separator
    table.insert(options, {
        title = '──────────────────',
        disabled = true
    })

    -- Fahrzeug-Garage
    table.insert(options, {
        title = 'Fahrzeug-Garage',
        description = 'Einsatzfahrzeuge spawnen und verwalten',
        icon = 'fa-solid fa-car',
        iconColor = serviceData.color,
        disabled = not FL.Player.onDuty,
        onSelect = function()
            FL.UI.OpenVehicleGarage(service, stationId)
        end
    })

    -- Ausrüstung
    table.insert(options, {
        title = 'Ausrüstung',
        description = 'Equipment und Gegenstände verwalten',
        icon = 'fa-solid fa-toolbox',
        iconColor = serviceData.color,
        disabled = not FL.Player.onDuty,
        onSelect = function()
            FL.UI.OpenEquipmentMenu(service, stationId)
        end
    })

    -- Umkleidekabine
    table.insert(options, {
        title = 'Umkleidekabine',
        description = 'Uniform und Kleidung wechseln',
        icon = 'fa-solid fa-shirt',
        iconColor = serviceData.color,
        onSelect = function()
            FL.UI.OpenWardrobeMenu(service, stationId)
        end
    })

    -- Separator
    table.insert(options, {
        title = '──────────────────',
        disabled = true
    })

    -- Einsatz-Zentrale
    table.insert(options, {
        title = 'Einsatz-Zentrale (MDT)',
        description = 'Mobile Data Terminal öffnen',
        icon = 'fa-solid fa-desktop',
        iconColor = serviceData.color,
        disabled = not FL.Player.onDuty,
        onSelect = function()
            FL.UI.OpenMDT(service)
        end
    })

    -- Aktuelle Einsätze (Quick-View)
    local activeCallsCount = 0
    for callId, call in pairs(FL.State.activeCalls) do
        if call.service == service then
            activeCallsCount = activeCallsCount + 1
        end
    end

    table.insert(options, {
        title = 'Aktive Einsätze',
        description = activeCallsCount .. ' Einsätze verfügbar',
        icon = 'fa-solid fa-radio',
        iconColor = activeCallsCount > 0 and '#e74c3c' or '#95a5a6',
        disabled = not FL.Player.onDuty,
        onSelect = function()
            FL.UI.OpenCallsQuickView(service)
        end
    })

    return options
end

-- Erstelle Fahrzeug-Garage Menü
function FL.UI.OpenVehicleGarage(service, stationId)
    local vehicles = Config.Vehicles[service]
    local options = {}

    -- Kategorien durchgehen
    for category, categoryVehicles in pairs(vehicles) do
        local categoryData = Config.VehicleUI.categories[service][category]

        -- Kategorie-Header
        table.insert(options, {
            title = '📁 ' .. category:upper(),
            description = 'Fahrzeug-Kategorie',
            disabled = true
        })

        -- Fahrzeuge in Kategorie
        for vehicleKey, vehicleData in pairs(categoryVehicles) do
            local playerRank = FL.GetPlayerRank()
            local canSpawn = playerRank >= vehicleData.requiredGrade

            table.insert(options, {
                title = vehicleData.label,
                description = canSpawn and 'Fahrzeug spawnen' or 'Rang ' .. vehicleData.requiredGrade .. ' benötigt',
                icon = categoryData.icon,
                iconColor = canSpawn and categoryData.color or '#95a5a6',
                disabled = not canSpawn,
                metadata = {
                    { label = 'Sitze',           value = vehicleData.seats },
                    { label = 'Benötigter Rang', value = vehicleData.requiredGrade },
                    { label = 'Kategorie',       value = category }
                },
                onSelect = function()
                    FL.UI.RequestVehicleSpawn(vehicleKey, vehicleData, stationId)
                end
            })
        end

        -- Separator
        table.insert(options, {
            title = '──────────────────',
            disabled = true
        })
    end

    -- Aktuelles Fahrzeug despawnen
    if FL.Player.currentVehicle and DoesEntityExist(FL.Player.currentVehicle) then
        table.insert(options, {
            title = '🗑️ Aktuelles Fahrzeug despawnen',
            description = 'Fahrzeug zurückbringen',
            icon = 'fa-solid fa-trash',
            iconColor = '#e74c3c',
            onSelect = function()
                FL.UI.DespawnCurrentVehicle()
            end
        })
    end

    lib.registerContext({
        id = 'fl_vehicle_garage_' .. service,
        title = 'Fahrzeug-Garage - ' .. Config.Services[service].label,
        menu = 'fl_duty_' .. service,
        options = options
    })

    lib.showContext('fl_vehicle_garage_' .. service)
end

-- Erstelle Equipment-Menü
function FL.UI.OpenEquipmentMenu(service, stationId)
    local serviceData = Config.Services[service]
    local options = {}

    -- Standard Equipment
    if serviceData.equipment.items then
        table.insert(options, {
            title = '📦 Standard-Ausrüstung',
            description = 'Basis-Equipment anfordern',
            disabled = true
        })

        for _, item in pairs(serviceData.equipment.items) do
            table.insert(options, {
                title = item,
                description = 'Equipment anfordern',
                icon = 'fa-solid fa-tools',
                iconColor = serviceData.color,
                onSelect = function()
                    TriggerServerEvent('fl:equipment:request', item)
                end
            })
        end
    end

    -- Waffen (nur für Polizei)
    if service == 'police' and serviceData.equipment.weapons then
        table.insert(options, {
            title = '──────────────────',
            disabled = true
        })

        table.insert(options, {
            title = '🔫 Waffenkammer',
            description = 'Dienstwaffen anfordern',
            disabled = true
        })

        for _, weapon in pairs(serviceData.equipment.weapons) do
            table.insert(options, {
                title = weapon,
                description = 'Waffe anfordern',
                icon = 'fa-solid fa-gun',
                iconColor = '#e74c3c',
                onSelect = function()
                    TriggerServerEvent('fl:equipment:request', weapon)
                end
            })
        end
    end

    lib.registerContext({
        id = 'fl_equipment_' .. service,
        title = 'Ausrüstung - ' .. Config.Services[service].label,
        menu = 'fl_duty_' .. service,
        options = options
    })

    lib.showContext('fl_equipment_' .. service)
end

-- Erstelle Wardrobe-Menü
function FL.UI.OpenWardrobeMenu(service, stationId)
    local serviceData = Config.Services[service]
    local uniforms = serviceData.uniforms
    local gender = GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') and 'female' or 'male'
    local options = {}

    -- Uniformen
    if uniforms[gender] then
        table.insert(options, {
            title = '👕 Dienstuniformen',
            description = 'Verfügbare Uniformen',
            disabled = true
        })

        for uniformId, uniformData in pairs(uniforms[gender]) do
            local uniformName = uniformId == 0 and 'Standard-Uniform' or 'Uniform ' .. (uniformId + 1)

            table.insert(options, {
                title = uniformName,
                description = 'Uniform anziehen',
                icon = 'fa-solid fa-shirt',
                iconColor = serviceData.color,
                onSelect = function()
                    FL.ApplyUniform(uniformData)
                end
            })
        end
    end

    -- Separator
    table.insert(options, {
        title = '──────────────────',
        disabled = true
    })

    -- Zivilkleidung
    table.insert(options, {
        title = '👤 Zivilkleidung',
        description = 'Zurück zur normalen Kleidung',
        icon = 'fa-solid fa-user',
        iconColor = '#95a5a6',
        onSelect = function()
            FL.ApplyCivilianClothing()
        end
    })

    lib.registerContext({
        id = 'fl_wardrobe_' .. service,
        title = 'Umkleidekabine - ' .. Config.Services[service].label,
        menu = 'fl_duty_' .. service,
        options = options
    })

    lib.showContext('fl_wardrobe_' .. service)
end

-- Erstelle Quick-View für Einsätze
function FL.UI.OpenCallsQuickView(service)
    local options = {}
    local hasActiveCalls = false

    -- Aktive Einsätze
    for callId, call in pairs(FL.State.activeCalls) do
        if call.service == service then
            hasActiveCalls = true

            local priorityColor = Config.Calls.priorityColors[call.priority] or '#95a5a6'
            local statusIcon = call.status == 'pending' and 'fa-solid fa-clock' or 'fa-solid fa-users'

            table.insert(options, {
                title = call.id,
                description = call.type .. ' - Priorität ' .. call.priority,
                icon = statusIcon,
                iconColor = priorityColor,
                metadata = {
                    { label = 'Status',     value = call.status },
                    { label = 'Zugewiesen', value = #call.assigned .. '/' .. (call.requiredUnits or 1) },
                    { label = 'Zeit',       value = os.date('%H:%M', call.created) }
                },
                onSelect = function()
                    FL.UI.OpenCallActions(callId, call)
                end
            })
        end
    end

    -- Keine Einsätze
    if not hasActiveCalls then
        table.insert(options, {
            title = '✅ Keine aktiven Einsätze',
            description = 'Momentan sind keine Einsätze verfügbar',
            icon = 'fa-solid fa-check',
            iconColor = '#2ecc71',
            disabled = true
        })
    end

    -- Separator
    table.insert(options, {
        title = '──────────────────',
        disabled = true
    })

    -- MDT öffnen
    table.insert(options, {
        title = '📱 Vollständiges MDT öffnen',
        description = 'Mobile Data Terminal mit allen Funktionen',
        icon = 'fa-solid fa-desktop',
        iconColor = Config.Services[service].color,
        onSelect = function()
            FL.UI.OpenMDT(service)
        end
    })

    lib.registerContext({
        id = 'fl_calls_quick_' .. service,
        title = 'Aktive Einsätze - ' .. Config.Services[service].label,
        menu = 'fl_duty_' .. service,
        options = options
    })

    lib.showContext('fl_calls_quick_' .. service)
end

-- Einsatz-Aktionen
function FL.UI.OpenCallActions(callId, call)
    local options = {}

    -- Prüfe ob zugewiesen
    local isAssigned = false
    for _, source in pairs(call.assigned) do
        if source == GetPlayerServerId(PlayerId()) then
            isAssigned = true
            break
        end
    end

    -- Zuweisen/Entfernen
    if isAssigned then
        table.insert(options, {
            title = '❌ Von Einsatz entfernen',
            description = 'Zuweisung aufheben',
            icon = 'fa-solid fa-user-minus',
            iconColor = '#e74c3c',
            onSelect = function()
                TriggerServerEvent('fl:call:unassign', callId)
            end
        })
    else
        table.insert(options, {
            title = '✅ Zu Einsatz zuweisen',
            description = 'Diesem Einsatz beitreten',
            icon = 'fa-solid fa-user-plus',
            iconColor = '#2ecc71',
            onSelect = function()
                TriggerServerEvent('fl:call:assign', callId)
            end
        })
    end

    -- GPS-Marker setzen
    table.insert(options, {
        title = '📍 GPS-Marker setzen',
        description = 'Route zum Einsatzort anzeigen',
        icon = 'fa-solid fa-map-marker-alt',
        iconColor = '#3498db',
        onSelect = function()
            SetNewWaypoint(call.coords.x, call.coords.y)
            lib.notify({
                type = 'success',
                description = 'GPS-Marker gesetzt'
            })
        end
    })

    -- Abschließen (nur wenn zugewiesen)
    if isAssigned then
        table.insert(options, {
            title = '✅ Einsatz abschließen',
            description = 'Einsatz als erledigt markieren',
            icon = 'fa-solid fa-check',
            iconColor = '#2ecc71',
            onSelect = function()
                FL.UI.ShowCallCompletionDialog(callId)
            end
        })
    end

    lib.registerContext({
        id = 'fl_call_actions_' .. callId,
        title = 'Einsatz ' .. call.id,
        menu = 'fl_calls_quick_' .. call.service,
        options = options
    })

    lib.showContext('fl_call_actions_' .. callId)
end

-- ================================
-- 📝 INPUT DIALOGS
-- ================================

-- Fahrzeug-Spawn Dialog
function FL.UI.RequestVehicleSpawn(vehicleKey, vehicleData, stationId)
    local nearestSpawn = FL.FindNearestVehicleSpawn(FL.Player.service, stationId)

    if not nearestSpawn then
        lib.notify({
            type = 'error',
            description = 'Kein Spawn-Punkt verfügbar'
        })
        return
    end

    -- Prüfe ob Spawn-Punkt frei ist
    if FL.IsSpawnPointOccupied(nearestSpawn.coords, 5.0) then
        lib.notify({
            type = 'error',
            description = 'Spawn-Punkt ist blockiert'
        })
        return
    end

    FL.SpawnVehicle(vehicleKey, vehicleData, nearestSpawn)
end

-- Call-Completion Dialog
function FL.UI.ShowCallCompletionDialog(callId)
    local input = lib.inputDialog('Einsatz abschließen', {
        {
            type = 'textarea',
            label = 'Abschlussbericht (optional)',
            placeholder = 'Kurze Beschreibung des Einsatzverlaufs...',
            rows = 4
        }
    })

    if input then
        TriggerServerEvent('fl:call:complete', callId, input[1])
    end
end

-- ================================
-- 🔧 UTILITY FUNCTIONS
-- ================================

-- Finde nächsten Fahrzeug-Spawn
function FL.FindNearestVehicleSpawn(service, stationId)
    local station = Config.Stations[service] and Config.Stations[service][stationId]
    if not station or not station.vehicles then return nil end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestSpawn = nil
    local nearestDistance = math.huge

    for _, spawn in pairs(station.vehicles) do
        local distance = #(playerCoords - spawn.coords)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestSpawn = spawn
        end
    end

    return nearestSpawn
end

-- Despawn aktuelles Fahrzeug
function FL.UI.DespawnCurrentVehicle()
    if FL.Player.currentVehicle and DoesEntityExist(FL.Player.currentVehicle) then
        DeleteVehicle(FL.Player.currentVehicle)
        FL.Player.currentVehicle = nil

        lib.notify({
            type = 'success',
            description = 'Fahrzeug despawned'
        })
    else
        lib.notify({
            type = 'error',
            description = 'Kein aktives Fahrzeug'
        })
    end
end

-- ================================
-- 🎯 NOTIFICATION SYSTEM
-- ================================

-- Zeige Service-Notification
function FL.UI.ShowServiceNotification(type, title, description, service)
    local serviceColor = Config.Services[service] and Config.Services[service].color or '#3498db'

    lib.notify({
        type = type,
        title = title,
        description = description,
        iconColor = serviceColor,
        duration = Config.Notifications.duration
    })

    -- Sound abspielen
    if Config.Notifications.playSound then
        local sounds = {
            success = 'TIMER_STOP',
            error = 'ERROR',
            info = 'NAV_UP_DOWN'
        }

        PlaySoundFrontend(-1, sounds[type] or 'NAV_UP_DOWN', "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    end
end

-- ================================
-- 📡 NUI CALLBACKS
-- ================================

-- NUI: MDT schließen
RegisterNUICallback('closeUI', function(data, cb)
    FL.UI.CloseMDT()
    cb('ok')
end)

-- NUI: Einsatz zuweisen
RegisterNUICallback('assignCall', function(data, cb)
    TriggerServerEvent('fl:call:assign', data.callId)
    cb('ok')
end)

-- NUI: Einsatz abschließen
RegisterNUICallback('completeCall', function(data, cb)
    TriggerServerEvent('fl:call:complete', data.callId, data.notes)
    cb('ok')
end)

-- NUI: GPS-Marker setzen
RegisterNUICallback('setWaypoint', function(data, cb)
    SetNewWaypoint(data.coords.x, data.coords.y)
    cb('ok')
end)

-- NUI: Fahrzeug spawnen
RegisterNUICallback('spawnVehicle', function(data, cb)
    -- Implementierung für Fahrzeug-Spawn via NUI
    cb('ok')
end)

-- ================================
-- 🎮 KEYBINDS
-- ================================

-- MDT Keybind
RegisterCommand('+mdt', function()
    if not FL.Player.service or not FL.Player.onDuty then return end
    FL.UI.OpenMDT(FL.Player.service)
end, false)

RegisterCommand('-mdt', function()
    -- Nur für Keybind-System
end, false)

RegisterKeyMapping('+mdt', 'MDT öffnen', 'keyboard', Config.MDT.keybind or 'F6')
