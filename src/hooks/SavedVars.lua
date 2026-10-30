-- EsoMacMinion - wrap ZO_SavedVars constructors at file scope (before any EVENT_ADD_ON_LOADED).

local EMM = EsoMacMinion

local CTOR_NAMES = {
    "New",
    "NewCharacterIdSettings",
    "NewCharacterNameSettings",
    "NewAccountWide",
}

local function wrapConstructors()
    if EMM._svWrapped then
        return
    end
    if type(ZO_SavedVars) ~= "table" then
        return
    end
    EMM._svWrapped = true

    for i = 1, #CTOR_NAMES do
        local name = CTOR_NAMES[i]
        local original = ZO_SavedVars[name]
        if type(original) == "function" then
            ZO_SavedVars[name] = function(self, ...)
                if EMM.RecordSavedVarsCall then
                    pcall(EMM.RecordSavedVarsCall, name, self, ...)
                end
                return original(self, ...)
            end
        end
    end
end

wrapConstructors()
