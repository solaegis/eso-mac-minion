-- EsoMacMinion - observe every later EVENT_ADD_ON_LOADED. Do not unregister.

local EMM = EsoMacMinion

EMM._loadEvents = EMM._loadEvents or {}
EMM._loadOrder = EMM._loadOrder or 0

local function nowMs()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return 0
end

EMM._observerStartMs = nowMs()

local function onAnyAddonLoaded(_, name)
    if type(name) ~= "string" or name == "" then
        return
    end

    local now = nowMs()
    local dt
    if EMM._lastLoadMs then
        dt = now - EMM._lastLoadMs
    else
        dt = now - (EMM._observerStartMs or now)
    end
    EMM._lastLoadMs = now
    EMM._loadOrder = (EMM._loadOrder or 0) + 1
    EMM.lastLoadedAddon = name
    EMM._loadEvents[name] = {
        loadOrder = EMM._loadOrder,
        loadMs = dt,
        at = now,
    }

    if name == "LibAddonMenu-2.0" or name == "LibAddonMenu2" then
        if EMM.WrapLAM then
            EMM.WrapLAM()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(EMM.NAME .. "Observer", EVENT_ADD_ON_LOADED, onAnyAddonLoaded)
