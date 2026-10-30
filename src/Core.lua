-- EsoMacMinion - Core namespace, helpers, and branding constants

EsoMacMinion = EsoMacMinion or {}
local EMM = EsoMacMinion

EMM.NAME = "EsoMacMinion"
EMM.DISPLAY_NAME = "ESO Mac Minion"
EMM.VERSION = "@project-version@"
EMM.AUTHOR = "solaegis"

EMM.WEBSITE_URL = "https://github.com/solaegis/eso-mac-minion"
EMM.FEEDBACK_URL = "https://github.com/solaegis/eso-mac-minion/issues"
EMM.DONATION_URL = "https://www.buymeacoffee.com/lewisvavasw"
EMM.DONATION_ACCOUNT = "@solaegis"
EMM.DONATION_GOLD_DEFAULT = 5000

EMM.SV_NAME = "EsoMacMinion_Data"
EMM.SV_VERSION = 1
EMM.SCHEMA = 1

EMM.db = nil
EMM.defaults = nil
EMM.debug = false

--- Count entries in a map-style table (non-sequence keys).
function EMM.CountTable(tbl)
    if type(tbl) ~= "table" then
        return 0
    end
    local n = 0
    for _ in pairs(tbl) do
        n = n + 1
    end
    return n
end

--- Stamp schema + written so the next SavedVariables write is current.
function EMM.TouchWritten()
    if not EMM.db then
        return
    end
    EMM.db.schema = EMM.SCHEMA
    if GetTimeStamp then
        EMM.db.written = GetTimeStamp()
    end
end

--- Ensure schema-1 sections exist as real tables (not defaults-metatable holes).
function EMM.EnsureCompanionShape()
    if not EMM.db then
        return
    end
    EMM.db.schema = EMM.db.schema or EMM.SCHEMA
    if type(EMM.db.env) ~= "table" then
        EMM.db.env = {}
    end
    if type(EMM.db.characters) ~= "table" then
        EMM.db.characters = {}
    end
    if type(EMM.db.addons) ~= "table" then
        EMM.db.addons = {}
    end
    if type(EMM.db.layouts) ~= "table" then
        EMM.db.layouts = {}
    end
    if type(EMM.db.layouts.sv) ~= "table" then
        EMM.db.layouts.sv = {}
    end
    if type(EMM.db.layouts.lam) ~= "table" then
        EMM.db.layouts.lam = {}
    end
    if type(EMM.db.errors) ~= "table" then
        EMM.db.errors = {}
    end
    if type(EMM.db.perf) ~= "table" then
        EMM.db.perf = {}
    end
    if type(EMM.db.guilds) ~= "table" then
        EMM.db.guilds = {}
    end
    if type(EMM.db.lookups) ~= "table" then
        EMM.db.lookups = {}
    end
    if type(EMM.db.lookups.requests) ~= "table" then
        EMM.db.lookups.requests = {}
    end
    if type(EMM.db.lookups.answers) ~= "table" then
        EMM.db.lookups.answers = {}
    end
    if type(EMM.db.account) ~= "table" then
        EMM.db.account = {}
    end
end

--- Deterministic hash for compact layout signatures.
function EMM.Hash(text)
    text = tostring(text or "")
    if HashString then
        return HashString(text)
    end
    local h = 0
    for i = 1, #text do
        h = (h * 33 + string.byte(text, i)) % 2147483647
    end
    return h
end

--- Addon folder from debug.traceback, else the most recent EVENT_ADD_ON_LOADED name.
function EMM.AddonFromTraceback()
    local tb = ""
    if debug and debug.traceback then
        local ok, result = pcall(debug.traceback)
        if ok and type(result) == "string" then
            tb = result
        end
    end
    local folder = string.match(tb, "user:/Add[Oo]ns/([^/\n]+)/")
    if folder and folder ~= EMM.NAME then
        return folder
    end
    if EMM.lastLoadedAddon and EMM.lastLoadedAddon ~= EMM.NAME then
        return EMM.lastLoadedAddon
    end
    return folder
end

------------------------------------------------------------
-- Optional LibDebugLogger
------------------------------------------------------------

local logger = nil
if LibDebugLogger and LibDebugLogger.Create then
    logger = LibDebugLogger.Create(EMM.NAME)
end

local function chatPrefix()
    return "|c7EC8E3[EMM]|r "
end

local function printToChat(message)
    d(chatPrefix() .. tostring(message))
end

------------------------------------------------------------
-- Logging
------------------------------------------------------------

--- Debug category log (silent unless LibDebugLogger or EMM.debug).
--- @param category string
--- @param ... any message parts, or a single function for lazy evaluation
function EMM.DebugPrint(category, ...)
    if not logger and not EMM.debug then
        return
    end

    local args = { ... }
    local parts = {}

    if #args == 1 and type(args[1]) == "function" then
        local ok, result = pcall(args[1])
        if ok then
            parts[1] = tostring(result)
        else
            parts[1] = "Error in debug function: " .. tostring(result)
        end
    else
        for i, v in ipairs(args) do
            parts[i] = tostring(v)
        end
    end

    local message = table.concat(parts, " ")
    if logger then
        logger:Debug(string.format("[%s] %s", category or "CORE", message))
    elseif EMM.debug then
        printToChat(string.format("|cAAAAAA[%s] %s|r", category or "CORE", message))
    end
end

function EMM.Info(message)
    local text = tostring(message)
    if logger then
        logger:Info(text)
    end
    printToChat(text)
end

function EMM.Warn(message)
    local text = tostring(message)
    if logger then
        logger:Warn(text)
    end
    printToChat("|cE6B800" .. text .. "|r")
end

function EMM.Error(message)
    local text = tostring(message)
    if logger then
        logger:Error(text)
    end
    printToChat("|cFF6666" .. text .. "|r")
end

--- Chat helper used by SupportFooter and Commands (always visible).
function EMM.Chat(message)
    printToChat(message)
end

--- Debug line gated by settings.debug (and always via DebugPrint when logger present).
function EMM.Debug(message)
    EMM.DebugPrint("DEBUG", tostring(message))
    if EMM.db and EMM.db.debug then
        printToChat("|cAAAAAA" .. tostring(message) .. "|r")
    end
end

------------------------------------------------------------
-- SafeCall helpers (ESO API wrappers)
------------------------------------------------------------

--- Call func with pcall; return first result or nil on failure.
function EMM.SafeCall(func, ...)
    local success, result = EMM.SafeCallMulti(func, ...)
    if success then
        return result
    end
    return nil
end

--- Call func with pcall preserving multiple return values.
--- Returns success, then the function returns (or error message on failure).
function EMM.SafeCallMulti(func, ...)
    if not func or type(func) ~= "function" then
        local errorMsg = string.format("SafeCallMulti: function is nil or not a function (type=%s)", type(func))
        EMM.DebugPrint("SAFECALL", errorMsg)
        return false, errorMsg
    end

    local function capture(ok, ...)
        return ok, select("#", ...), { ... }
    end

    local pcallOk, count, results = capture(pcall(func, ...))
    if not pcallOk then
        local errorMsg = results[1]
        EMM.DebugPrint("SAFECALL", function()
            return string.format("Error in SafeCallMulti: %s", tostring(errorMsg))
        end)
        return false, errorMsg
    end

    return true, unpack(results, 1, count)
end

------------------------------------------------------------
-- Settings accessors
------------------------------------------------------------

function EMM.GetSettings()
    return EMM.db
end

function EMM.IsDebugEnabled()
    return EMM.db ~= nil and EMM.db.debug == true
end
