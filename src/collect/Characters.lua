-- EsoMacMinion - account roster keyed by character id.

local EMM = EsoMacMinion

function EMM.CollectCharacters()
    if not EMM.db then
        return
    end
    EMM.EnsureCompanionShape()

    local n = EMM.SafeCall(GetNumCharacters) or 0
    local currentId = tostring(EMM.SafeCall(GetCurrentCharacterId) or "")
    local now = EMM.SafeCall(GetTimeStamp)
    local champion = EMM.SafeCall(GetPlayerChampionPointsEarned)

    for i = 1, n do
        local ok, name, _, level, classId, raceId, alliance, id, locationId = EMM.SafeCallMulti(GetCharacterInfo, i)
        if ok and id then
            id = tostring(id)
            local row = EMM.db.characters[id]
            if type(row) ~= "table" then
                row = {}
                EMM.db.characters[id] = row
            end
            row.name = name
            row.class = classId
            row.race = raceId
            row.alliance = alliance
            row.level = level
            if locationId ~= nil then
                row.zoneId = locationId
            end
            if id == currentId then
                row.champion = champion
                row.lastPlayed = now
            end
        end
    end
    EMM.TouchWritten()
end
