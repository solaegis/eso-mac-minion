-- EsoMacMinion - AddOnManager inventory plus observed load timing.

local EMM = EsoMacMinion

local function addonStateName(enabled, state)
    if enabled == false then
        return "disabled"
    end
    if ADDON_STATE_ENABLED and state == ADDON_STATE_ENABLED then
        return "loaded"
    end
    if ADDON_STATE_DEPENDENCIES_DISABLED and state == ADDON_STATE_DEPENDENCIES_DISABLED then
        return "missing"
    end
    if ADDON_STATE_VERSION_MISMATCH and state == ADDON_STATE_VERSION_MISMATCH then
        return "outdated"
    end
    return "unknown"
end

local function missingDependencies(mgr, index)
    local missing = {}
    if not mgr.GetAddOnNumDependencies or not mgr.GetAddOnDependencyInfo then
        return missing
    end
    local numDeps = mgr:GetAddOnNumDependencies(index) or 0
    for d = 1, numDeps do
        local ok, depName, exists, active = EMM.SafeCallMulti(function()
            return mgr:GetAddOnDependencyInfo(index, d)
        end)
        if ok and type(depName) == "string" and depName ~= "" then
            if exists == false or active == false then
                missing[#missing + 1] = depName
            end
        end
    end
    return missing
end

function EMM.CollectAddons()
    if not EMM.db then
        return
    end
    EMM.EnsureCompanionShape()

    local mgr = EMM.SafeCall(GetAddOnManager)
    if not mgr or not mgr.GetNumAddOns or not mgr.GetAddOnInfo then
        return
    end

    local n = mgr:GetNumAddOns() or 0
    for i = 1, n do
        local ok, name, title, _, _, enabled, state, isOutOfDate, isLibrary = EMM.SafeCallMulti(function()
            return mgr:GetAddOnInfo(i)
        end)
        if ok and type(name) == "string" and name ~= "" then
            local addonVersion = 0
            if mgr.GetAddOnVersion then
                addonVersion = mgr:GetAddOnVersion(i) or 0
            end
            local metaVersion = EMM.SafeCall(GetAddOnMetadata, name, "Version")
            local load = EMM._loadEvents and EMM._loadEvents[name]
            EMM.db.addons[name] = {
                title = title,
                version = type(metaVersion) == "string" and metaVersion ~= "" and metaVersion or tostring(addonVersion),
                addonVersion = addonVersion,
                enabled = enabled == true,
                state = addonStateName(enabled, state),
                outOfDate = isOutOfDate == true,
                isLibrary = isLibrary == true,
                missing = missingDependencies(mgr, i),
                loadOrder = load and load.loadOrder or nil,
                loadMs = load and load.loadMs or nil,
            }
        end
    end
    EMM.TouchWritten()
end
