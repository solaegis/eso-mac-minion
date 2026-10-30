-- EsoMacMinion - default SavedVariables

local EMM = EsoMacMinion

local SETTINGS_KEYS = {
    enabled = true,
    debug = true,
    recordLayouts = true,
    recordErrors = true,
    recordPerf = true,
    recordAccount = true,
}

EMM.defaults = {
    enabled = true,
    debug = false,
    schema = 1,
    written = 0,
    recordLayouts = true,
    recordErrors = true,
    recordPerf = true,
    recordAccount = false,
    env = {},
    characters = {},
    addons = {},
    layouts = {
        sv = {},
        lam = {},
    },
    errors = {},
    perf = {
        samples = {},
        loads = {},
    },
    guilds = {},
    lookups = {
        requests = {},
        answers = {},
    },
    account = {},
    -- Reserved for optional per-character buckets (do not wipe on reset).
    perCharacterData = {},
}

--- Reset account settings to defaults, preserving recorded snapshots and perCharacterData.
function EMM.ResetSettings()
    if not EMM.db then
        return
    end

    local preserved = EMM.db.perCharacterData
    for key, value in pairs(EMM.defaults) do
        if SETTINGS_KEYS[key] then
            EMM.db[key] = value
        end
    end
    EMM.db.perCharacterData = preserved or {}
    EMM.debug = EMM.db.debug == true
    EMM.Info("Settings reset to defaults")
end

--- Wipe recorded snapshots. Leaves toggles and perCharacterData alone.
function EMM.ClearRecordedData()
    if not EMM.db then
        return
    end
    EMM.db.env = {}
    EMM.db.characters = {}
    EMM.db.addons = {}
    EMM.db.layouts = { sv = {}, lam = {} }
    EMM.db.errors = {}
    EMM.db.perf = { samples = {}, loads = {} }
    EMM.db.guilds = {}
    EMM.db.lookups = { requests = {}, answers = {} }
    EMM.db.account = {}
    EMM.TouchWritten()
    EMM.Info("Recorded data cleared")
end
