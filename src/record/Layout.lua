-- EsoMacMinion - record ZO_SavedVars / LAM layouts (types and names only, never values).

local EMM = EsoMacMinion

local MAX_LAM_CONTROLS = 80

local function layoutsEnabled()
    return EMM.db == nil or EMM.db.recordLayouts ~= false
end

local function ensureSvBucket(svName)
    EMM.EnsureCompanionShape()
    local bucket = EMM.db.layouts.sv[svName]
    if type(bucket) ~= "table" then
        bucket = {}
        EMM.db.layouts.sv[svName] = bucket
    end
    return bucket
end

local function keyTypeForCtor(ctorName, characterName, characterKeyType)
    if ctorName == "NewAccountWide" then
        return "account"
    end
    if ctorName == "NewCharacterIdSettings" then
        return "characterId"
    end
    if ctorName == "NewCharacterNameSettings" then
        return "characterName"
    end
    if characterName == nil then
        return "account"
    end
    if characterKeyType == ZO_SAVED_VARS_CHARACTER_ID_KEY then
        return "characterId"
    end
    return "characterName"
end

--- Record a ZO_SavedVars constructor call. Safe to call before our own SV exists.
function EMM.RecordSavedVarsCall(
    ctorName,
    _,
    savedVariableTable,
    version,
    namespace,
    defaults,
    profile,
    displayName,
    characterName,
    characterId,
    characterKeyType
)
    if not layoutsEnabled() then
        return
    end
    if type(namespace) == "table" then
        characterKeyType = characterId
        characterName = displayName
        profile = defaults
        namespace = nil
    end

    local svName
    if type(savedVariableTable) == "string" then
        svName = savedVariableTable
    else
        return
    end
    if svName == "" or svName == EMM.SV_NAME then
        return
    end

    if not EMM.db then
        EMM._pendingSvCalls = EMM._pendingSvCalls or {}
        EMM._pendingSvCalls[#EMM._pendingSvCalls + 1] = {
            ctor = ctorName,
            svName = svName,
            version = version,
            namespace = type(namespace) == "string" and namespace or nil,
            profile = type(profile) == "string" and profile or "Default",
            keyType = keyTypeForCtor(ctorName, characterName, characterKeyType),
            addon = EMM.AddonFromTraceback(),
        }
        return
    end

    local bucket = ensureSvBucket(svName)
    bucket.ctor = ctorName
    bucket.version = version
    if type(namespace) == "string" then
        bucket.namespace = namespace
    end
    bucket.profile = type(profile) == "string" and profile or (bucket.profile or "Default")
    bucket.keyType = keyTypeForCtor(ctorName, characterName, characterKeyType)
    bucket.addon = EMM.AddonFromTraceback() or bucket.addon
    if bucket.source == "scan" then
        bucket.source = "wrap+scan"
    else
        bucket.source = "wrap"
    end
    EMM.TouchWritten()
end

function EMM.FlushPendingSavedVarsCalls()
    local pending = EMM._pendingSvCalls
    if type(pending) ~= "table" then
        return
    end
    EMM._pendingSvCalls = nil
    if not EMM.db then
        return
    end
    for i = 1, #pending do
        local row = pending[i]
        local bucket = ensureSvBucket(row.svName)
        bucket.ctor = row.ctor
        bucket.version = row.version
        bucket.namespace = row.namespace
        bucket.profile = row.profile
        bucket.keyType = row.keyType
        bucket.addon = row.addon or bucket.addon
        if bucket.source == "scan" then
            bucket.source = "wrap+scan"
        else
            bucket.source = bucket.source or "wrap"
        end
    end
    EMM.TouchWritten()
end

local function controlSnapshot(control)
    if type(control) ~= "table" then
        return nil
    end
    local row = {}
    if type(control.type) == "string" then
        row.type = control.type
    end
    if type(control.name) == "string" then
        row.name = control.name
    end
    if type(control.reference) == "string" then
        row.reference = control.reference
    end
    if not row.type and not row.name and not row.reference then
        return nil
    end
    return row
end

local function ensureLamBucket(panelName)
    EMM.EnsureCompanionShape()
    local bucket = EMM.db.layouts.lam[panelName]
    if type(bucket) ~= "table" then
        bucket = { controls = {} }
        EMM.db.layouts.lam[panelName] = bucket
    end
    if type(bucket.controls) ~= "table" then
        bucket.controls = {}
    end
    return bucket
end

function EMM.RecordLAMPanel(panelName, panelData)
    if not layoutsEnabled() or type(panelName) ~= "string" or panelName == "" then
        return
    end
    if not EMM.db then
        return
    end
    local bucket = ensureLamBucket(panelName)
    bucket.addon = EMM.AddonFromTraceback() or bucket.addon
    if type(panelData) == "table" and type(panelData.name) == "string" then
        bucket.name = panelData.name
    end
    EMM.TouchWritten()
end

function EMM.RecordLAMOptions(panelName, optionsTable)
    if not layoutsEnabled() or type(panelName) ~= "string" or panelName == "" then
        return
    end
    if type(optionsTable) ~= "table" or not EMM.db then
        return
    end
    local bucket = ensureLamBucket(panelName)
    bucket.addon = EMM.AddonFromTraceback() or bucket.addon
    local controls = {}
    for i = 1, #optionsTable do
        if #controls >= MAX_LAM_CONTROLS then
            break
        end
        local snap = controlSnapshot(optionsTable[i])
        if snap then
            controls[#controls + 1] = snap
        end
    end
    bucket.controls = controls
    bucket.controlCount = #optionsTable
    EMM.TouchWritten()
end

function EMM.RecordLAMPanelCreated(panel)
    if not layoutsEnabled() or not EMM.db then
        return
    end
    local panelName
    if type(panel) == "table" then
        panelName = panel.data and panel.data.name or panel.GetName and panel:GetName()
    end
    if type(panelName) ~= "string" then
        return
    end
    local bucket = ensureLamBucket(tostring(panelName))
    bucket.created = true
    EMM.TouchWritten()
end
