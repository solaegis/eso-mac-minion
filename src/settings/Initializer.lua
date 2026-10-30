-- EsoMacMinion - SavedVariables initializer helpers

local EMM = EsoMacMinion

--- Ensure the current character has a bucket under account-wide perCharacterData.
--- Product addons can store character-specific fields here; do not put these in Defaults.
function EMM.EnsureCharacterData()
    if not EMM.db then
        return nil
    end
    if not EMM.db.perCharacterData then
        EMM.db.perCharacterData = {}
    end

    local characterId = tostring(GetCurrentCharacterId())
    if not EMM.db.perCharacterData[characterId] then
        EMM.db.perCharacterData[characterId] = {
            _initialized = true,
        }
    end

    EMM.charData = EMM.db.perCharacterData[characterId]
    return EMM.charData
end
