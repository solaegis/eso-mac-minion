-- EsoMacMinion - initialization

local EMM = EsoMacMinion

local ADDON_NAME = EMM.NAME
local loaded = false
local firstActivated = false

local function collectSnapshots()
    if EMM.CollectEnv then
        EMM.CollectEnv()
    end
    if EMM.CollectCharacters then
        EMM.CollectCharacters()
    end
    if EMM.CollectAddons then
        EMM.CollectAddons()
    end
end

local function onPlayerActivated()
    if firstActivated then
        return
    end
    firstActivated = true
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
    collectSnapshots()
    if EMM.StartGlobalScan then
        EMM.StartGlobalScan()
    end
end

local function onAddOnLoaded(_, name)
    if name ~= ADDON_NAME then
        return
    end
    if loaded then
        return
    end
    loaded = true
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    local defaults = EMM.defaults or {}

    -- Profile (5th arg) is the server so MacMinion labels NA / EU / PTS at the first level.
    EMM.db = ZO_SavedVars:NewAccountWide(EMM.SV_NAME, EMM.SV_VERSION, nil, defaults, GetWorldName())
    EMM.debug = EMM.db.debug == true

    EMM.EnsureCompanionShape()
    if EMM.EnsureCharacterData then
        EMM.EnsureCharacterData()
    end
    if EMM.FlushPendingSavedVarsCalls then
        EMM.FlushPendingSavedVarsCalls()
    end
    if EMM.WrapLAM then
        EMM.WrapLAM()
    end

    collectSnapshots()

    EMM.RegisterCommands()
    EMM.RegisterSettingsPanel()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, onPlayerActivated)

    EMM.Info(string.format("%s v%s loaded — /emm help", EMM.DISPLAY_NAME, EMM.VERSION))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
