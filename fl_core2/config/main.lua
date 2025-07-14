Config = {}
Config.Debug = true -- Debug-Modus für Entwicklung

-- ================================
-- 🎯 FRAMEWORK EINSTELLUNGEN
-- ================================

Config.Framework = 'qb-core'
Config.Target = 'ox_target'
Config.Inventory = 'qb-inventory' -- 'qb-inventory', 'ox_inventory', 'qs-inventory'
Config.Clothing = 'qb-clothing'   -- 'qb-clothing', 'illenium-appearance', 'fivem-appearance'

-- ================================
-- 🚨 CORE SYSTEM EINSTELLUNGEN
-- ================================

-- Real-time Updates System
Config.WebSocket = {
    enabled = true,
    port = 3001,
    updateInterval = 5000 -- ms
}

-- Performance & Caching
Config.Cache = {
    enabled = true,
    ttl = 300, -- Time to live in seconds (5 minutes)
    maxEntries = 1000
}

-- Database Einstellungen
Config.Database = {
    tableName = 'fl_emergency_data',
    cleanupInterval = 3600, -- Cleanup every hour (seconds)
    maxLogDays = 30         -- Keep logs for 30 days
}

-- ================================
-- 🎮 GAMEPLAY EINSTELLUNGEN
-- ================================

-- Einsatz-System
Config.Calls = {
    maxActiveCallsPerService = 10,
    autoAssignRadius = 2000.0, -- Meter
    callTimeout = 1800,        -- 30 minutes in seconds
    priorityColors = {
        [1] = '#e74c3c',       -- Rot (Höchste Priorität)
        [2] = '#f39c12',       -- Orange (Mittlere Priorität)
        [3] = '#3498db',       -- Blau (Niedrige Priorität)
    }
}

-- Dienst-System
Config.Duty = {
    requirePhysicalStation = true, -- Spieler müssen zur Wache
    allowRemoteDutyEnd = false,    -- Dienst nur in der Wache beenden
    uniformAutoEquip = true,       -- Uniform automatisch anziehen
    equipmentAutoGive = true,      -- Ausrüstung automatisch geben
    maxDutyTime = 14400            -- 4 Stunden maximum (seconds)
}

-- Fahrzeug-System
Config.Vehicles = {
    spawnRadius = 50.0,     -- Meter um Spawn-Point
    deleteOnDutyEnd = true, -- Fahrzeuge beim Dienstende löschen
    requireKeys = true,     -- Fahrzeugschlüssel benötigt
    fuelConsumption = true, -- Kraftstoffverbrauch aktiviert
    damageRealistic = true  -- Realistische Fahrzeugschäden
}

-- Equipment & Inventar
Config.Equipment = {
    removeOnDutyEnd = true,    -- Equipment beim Dienstende entfernen
    allowPersonalItems = true, -- Private Gegenstände behalten
    maxEquipmentWeight = 50.0, -- kg
    autoReplenish = true       -- Equipment automatisch nachfüllen
}

-- ================================
-- 🎨 UI/UX EINSTELLUNGEN
-- ================================

-- Notifications
Config.Notifications = {
    position = 'top-right', -- 'top-right', 'top-left', 'bottom-right', 'bottom-left'
    duration = 5000,        -- ms
    showIcons = true,
    playSound = true
}

-- MDT (Mobile Data Terminal)
Config.MDT = {
    command = 'mdt',          -- Chat-Command zum Öffnen
    keybind = 'F6',           -- Tastenbindung
    adminCommand = 'fladmin', -- Admin-MDT Command
    updateInterval = 2000     -- ms
}

-- Marker & Interaktion
Config.Interaction = {
    markerDistance = 10.0,     -- Sichtweite für Marker
    interactionDistance = 2.0, -- Interaktionsreichweite
    targetDistance = 5.0,      -- ox_target Reichweite
    showMarkerText = true
}

-- ================================
-- 🔧 TECHNISCHE EINSTELLUNGEN
-- ================================

-- Threads & Performance
Config.Threads = {
    stationCheck = 5000,  -- Station proximity check (ms)
    callUpdate = 3000,    -- Call status update (ms)
    vehicleCheck = 10000, -- Vehicle status check (ms)
    cleanup = 60000       -- General cleanup (ms)
}

-- Debug & Logging
Config.Logging = {
    enabled = true,
    level = 'info',         -- 'debug', 'info', 'warn', 'error'
    logFile = 'fl_emergency.log',
    discordWebhook = false, -- Discord-Benachrichtigungen
    webhookURL = ''         -- Discord Webhook URL
}

-- Berechtigungen & Whitelist
Config.Permissions = {
    useJobGrades = true,      -- QBCore Job-Grades verwenden
    requireWhitelist = false, -- Separate Whitelist-Tabelle
    adminBypass = true,       -- Admins können alles
    checkLicense = false      -- Discord/Steam License Check
}

-- ================================
-- 🌍 LOKALISIERUNG
-- ================================

Config.Locale = 'de' -- 'en', 'de', 'es', 'fr'

-- Texte für UI (Basis-Set)
Config.Texts = {
    ['duty_start'] = 'Dienst begonnen',
    ['duty_end'] = 'Dienst beendet',
    ['not_authorized'] = 'Keine Berechtigung',
    ['vehicle_spawned'] = 'Fahrzeug wurde gespawnt',
    ['call_assigned'] = 'Einsatz zugewiesen',
    ['equipment_received'] = 'Ausrüstung erhalten',
    ['station_enter'] = 'Wache betreten',
    ['mdt_opened'] = 'MDT geöffnet'
}

-- ================================
-- 🚗 FAHRZEUG-KATEGORIEN
-- ================================

Config.VehicleCategories = {
    ['fire'] = {
        ['light'] = 'Leichte Fahrzeuge',
        ['heavy'] = 'Schwere Fahrzeuge',
        ['special'] = 'Spezialfahrzeuge'
    },
    ['police'] = {
        ['patrol'] = 'Streifenwagen',
        ['unmarked'] = 'Zivilfahrzeuge',
        ['special'] = 'Spezialfahrzeuge'
    },
    ['ems'] = {
        ['ambulance'] = 'Rettungswagen',
        ['helicopter'] = 'Rettungshubschrauber',
        ['support'] = 'Unterstützungsfahrzeuge'
    }
}

-- ================================
-- 🎯 ENTWICKLER-OPTIONEN
-- ================================

if Config.Debug then
    Config.DevMode = {
        skipJobCheck = false,       -- Job-Prüfung überspringen
        unlimitedEquipment = false, -- Unbegrenzte Ausrüstung
        fastRespawn = true,         -- Schnelles Fahrzeug-Spawning
        showCoords = true,          -- Koordinaten anzeigen
        bypassCooldowns = false     -- Cooldowns überspringen
    }
end

-- ================================
-- 🔄 VERSION & UPDATE CHECK
-- ================================

Config.Version = {
    current = '2.0.0',
    checkForUpdates = true,
    updateURL = 'https://api.github.com/repos/fl-emergency/releases/latest',
    updateInterval = 86400 -- Check daily (seconds)
}
