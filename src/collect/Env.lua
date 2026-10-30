-- EsoMacMinion - environment snapshot (game / client).

local EMM = EsoMacMinion

function EMM.CollectEnv()
    if not EMM.db then
        return
    end
    EMM.EnsureCompanionShape()
    EMM.db.env = {
        apiVersion = EMM.SafeCall(GetAPIVersion),
        gameVersion = EMM.SafeCall(GetESOVersionString),
        server = EMM.SafeCall(GetWorldName),
        language = EMM.SafeCall(GetCVar, "language.2"),
        companionVersion = EMM.VERSION,
    }
    EMM.TouchWritten()
end
