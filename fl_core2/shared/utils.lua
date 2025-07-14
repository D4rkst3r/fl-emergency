-- ================================
-- 🔧 FL EMERGENCY - UTILITY FUNCTIONS (MINIMAL SAFE VERSION)
-- ================================

-- Sichere FL Initialisierung
if not FL then FL = {} end
if not FL.Utils then FL.Utils = {} end

-- ================================
-- 📝 BASIC LOGGING SYSTEM
-- ================================

FL.Utils.Log = FL.Utils.Log or {}

-- Log-Level
FL.Utils.Log.Levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}

FL.Utils.Log.LevelNames = {
    [1] = 'DEBUG',
    [2] = 'INFO',
    [3] = 'WARN',
    [4] = 'ERROR',
    [5] = 'FATAL'
}

FL.Utils.Log.LevelColors = {
    [1] = '^5', -- Magenta
    [2] = '^2', -- Grün
    [3] = '^3', -- Gelb
    [4] = '^1', -- Rot
    [5] = '^9'  -- Dunkelrot
}

-- Sichere Log-Funktion
function FL.Utils.Log.Write(level, message, data, source)
    local levelName = FL.Utils.Log.LevelNames[level] or 'UNKNOWN'
    local levelColor = FL.Utils.Log.LevelColors[level] or '^7'
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')

    -- Console Output
    local consoleMessage = string.format(
        '%s[FL Emergency]^7 [%s%s^7] %s',
        levelColor,
        levelColor,
        levelName,
        message
    )

    if data then
        consoleMessage = consoleMessage .. ' | Data: ' .. json.encode(data)
    end

    print(consoleMessage)
end

-- Convenience Functions
function FL.Utils.Log.Debug(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.DEBUG, message, data, source)
end

function FL.Utils.Log.Info(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.INFO, message, data, source)
end

function FL.Utils.Log.Warn(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.WARN, message, data, source)
end

function FL.Utils.Log.Error(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.ERROR, message, data, source)
end

function FL.Utils.Log.Fatal(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.FATAL, message, data, source)
end

-- ================================
-- 🔧 BASIC STRING UTILITIES
-- ================================

FL.Utils.String = FL.Utils.String or {}

function FL.Utils.String.Trim(str)
    return str:match("^%s*(.-)%s*$")
end

function FL.Utils.String.Split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function FL.Utils.String.Random(length, chars)
    chars = chars or 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    local result = ''
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

-- ================================
-- 🔢 BASIC MATH UTILITIES
-- ================================

FL.Utils.Math = FL.Utils.Math or {}

function FL.Utils.Math.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function FL.Utils.Math.Clamp(num, min, max)
    return math.min(math.max(num, min), max)
end

function FL.Utils.Math.Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- ================================
-- 📅 BASIC TIME UTILITIES
-- ================================

FL.Utils.Time = FL.Utils.Time or {}

function FL.Utils.Time.Now()
    return os.time()
end

function FL.Utils.Time.Format(timestamp, format)
    format = format or '%Y-%m-%d %H:%M:%S'
    return os.date(format, timestamp)
end

function FL.Utils.Time.Diff(start, finish)
    finish = finish or os.time()
    return finish - start
end

function FL.Utils.Time.FormatDuration(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format('%d:%02d:%02d', hours, minutes, secs)
    else
        return string.format('%02d:%02d', minutes, secs)
    end
end

-- ================================
-- 🔍 BASIC TABLE UTILITIES
-- ================================

FL.Utils.Table = FL.Utils.Table or {}

function FL.Utils.Table.IsEmpty(tbl)
    return next(tbl) == nil
end

function FL.Utils.Table.Size(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function FL.Utils.Table.Contains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- ================================
-- 🎯 BASIC VALIDATION UTILITIES
-- ================================

FL.Utils.Validate = FL.Utils.Validate or {}

function FL.Utils.Validate.Coords(coords)
    if type(coords) ~= 'table' then return false end
    if not coords.x or not coords.y or not coords.z then return false end
    if type(coords.x) ~= 'number' or type(coords.y) ~= 'number' or type(coords.z) ~= 'number' then return false end
    return true
end

function FL.Utils.Validate.CitizenId(citizenid)
    if type(citizenid) ~= 'string' then return false end
    if #citizenid < 8 or #citizenid > 50 then return false end
    return true
end

-- ================================
-- 🔄 SAFE INITIALIZATION
-- ================================

function FL.Utils.Init()
    FL.Utils.Log.Info('FL Utils initialized (minimal version)', {
        timestamp = os.time()
    })
end

-- Export Utils für andere Resources (nur server-side)
if IsDuplicityVersion() then
    exports('Utils', FL.Utils)
end

-- Sichere Initialisierung
CreateThread(function()
    Wait(2000) -- Warte bis alles geladen ist
    if FL and FL.Utils then
        FL.Utils.Init()
    end
end)
