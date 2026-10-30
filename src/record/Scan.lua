-- EsoMacMinion - scan _G for SavedVariables-shaped tables (next/rawget only).

local EMM = EsoMacMinion

local MAX_DEPTH = 4
local MAX_KEYS_PER_LEVEL = 24
local SCAN_PER_FRAME = 20

local SKIP_PREFIXES = {
    "ZO_",
    "SI_",
    "CT_",
    "TOP",
    "BOT",
    "LEFT",
    "RIGHT",
    "CENTER",
    "EVENT_",
    "SETTING_TYPE_",
    "CAMERA_SETTING_",
}

local function skipGlobalName(name)
    if name == EMM.SV_NAME or name == EMM.NAME or name == "EsoMacMinion" then
        return true
    end
    for i = 1, #SKIP_PREFIXES do
        local prefix = SKIP_PREFIXES[i]
        if string.sub(name, 1, #prefix) == prefix then
            return true
        end
    end
    return false
end

local function isAccountKey(key)
    if type(key) ~= "string" then
        return false
    end
    if string.sub(key, 1, 1) == "@" then
        return true
    end
    return key == "AllAccountsTheSame" or key == "$AllAccounts" or key == "$InstallationWide" or key == "Default"
end

local function isCharacterOrAccountWideKey(key)
    if key == "$AccountWide" then
        return true
    end
    if type(key) == "string" and string.match(key, "^%d+$") then
        return true
    end
    return false
end

--- True when tbl looks like SV[profile][displayName][characterKey].
function EMM.LooksLikeSavedVars(tbl)
    if type(tbl) ~= "table" then
        return false
    end
    local profiles = 0
    local profile, accounts = next(tbl)
    while profile ~= nil do
        if type(profile) == "string" and type(accounts) == "table" then
            local acc, chars = next(accounts)
            while acc ~= nil do
                if isAccountKey(acc) and type(chars) == "table" then
                    local ck, leaf = next(chars)
                    while ck ~= nil do
                        if isCharacterOrAccountWideKey(ck) and type(leaf) == "table" then
                            profiles = profiles + 1
                            break
                        end
                        -- name-keyed character tables (letters / spaces) also count
                        if type(ck) == "string" and type(leaf) == "table" and not string.match(ck, "^%$") then
                            profiles = profiles + 1
                            break
                        end
                        ck, leaf = next(chars, ck)
                    end
                    if profiles > 0 then
                        break
                    end
                end
                acc, chars = next(accounts, acc)
            end
        end
        if profiles > 0 then
            break
        end
        profile, accounts = next(tbl, profile)
    end
    return profiles > 0
end

local function collectKeys(tbl, limit)
    local keys = {}
    if type(tbl) ~= "table" then
        return keys
    end
    local k = next(tbl)
    while k ~= nil and #keys < limit do
        if type(k) == "string" or type(k) == "number" then
            keys[#keys + 1] = tostring(k)
        end
        k = next(tbl, k)
    end
    table.sort(keys)
    return keys
end

local function typeCode(value)
    local ty = type(value)
    if ty == "number" then
        return "n"
    end
    if ty == "string" then
        return "s"
    end
    if ty == "boolean" then
        return "b"
    end
    if ty == "table" then
        return "t"
    end
    if ty == "function" then
        return "f"
    end
    return "u"
end

local function walkSignature(tbl, prefix, depth, parts, seen)
    if depth > MAX_DEPTH or type(tbl) ~= "table" then
        return
    end
    if seen[tbl] then
        return
    end
    seen[tbl] = true
    local n = 0
    local k, v = next(tbl)
    while k ~= nil and n < MAX_KEYS_PER_LEVEL do
        local key = tostring(k)
        local path = prefix == "" and key or (prefix .. "." .. key)
        parts[#parts + 1] = path .. ":" .. typeCode(v)
        n = n + 1
        if type(v) == "table" then
            walkSignature(v, path, depth + 1, parts, seen)
        end
        k, v = next(tbl, k)
    end
end

function EMM.ScanSavedVarsTable(svName, tbl)
    if type(svName) ~= "string" or svName == EMM.SV_NAME or type(tbl) ~= "table" then
        return
    end
    if not EMM.db or EMM.db.recordLayouts == false then
        return
    end
    EMM.EnsureCompanionShape()

    local profiles = collectKeys(tbl, MAX_KEYS_PER_LEVEL)
    local accounts = {}
    local characters = {}
    local profileKey = next(tbl)
    if type(profileKey) == "string" then
        local accountsTbl = rawget(tbl, profileKey)
        if type(accountsTbl) == "table" then
            accounts = collectKeys(accountsTbl, MAX_KEYS_PER_LEVEL)
            local accKey = next(accountsTbl)
            if accKey ~= nil then
                local charsTbl = rawget(accountsTbl, accKey)
                if type(charsTbl) == "table" then
                    characters = collectKeys(charsTbl, MAX_KEYS_PER_LEVEL)
                end
            end
        end
    end

    local parts = {}
    walkSignature(tbl, "", 1, parts, {})
    local sig = EMM.Hash(table.concat(parts, "\n"))

    local bucket = EMM.db.layouts.sv[svName]
    if type(bucket) ~= "table" then
        bucket = {}
        EMM.db.layouts.sv[svName] = bucket
    end
    bucket.keys = profiles
    bucket.accounts = accounts
    bucket.characterKeys = characters
    bucket.sig = sig
    bucket.pathCount = #parts
    if not bucket.source then
        bucket.source = "scan"
    elseif bucket.source == "wrap" then
        bucket.source = "wrap+scan"
    end
    if not bucket.addon then
        bucket.addon = svName
    end
end

function EMM.StartGlobalScan()
    if not EMM.db or EMM.db.recordLayouts == false then
        return
    end
    if EMM._scanStarted then
        return
    end
    EMM._scanStarted = true

    local names = {}
    local k, v = next(_G)
    while k ~= nil do
        if type(k) == "string" and type(v) == "table" and not skipGlobalName(k) then
            if EMM.LooksLikeSavedVars(v) then
                names[#names + 1] = k
            end
        end
        k, v = next(_G, k)
    end

    local i = 1
    local function step()
        local n = 0
        while i <= #names and n < SCAN_PER_FRAME do
            local name = names[i]
            EMM.ScanSavedVarsTable(name, rawget(_G, name))
            i = i + 1
            n = n + 1
        end
        if i <= #names then
            if zo_callLater then
                zo_callLater(step, 0)
            else
                step()
            end
        else
            EMM.TouchWritten()
            EMM.DebugPrint("SCAN", function()
                return string.format("scanned %d SavedVariables-shaped globals", #names)
            end)
        end
    end
    step()
end
