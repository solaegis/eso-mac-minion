-- Luacheck for EsoMacMinion (ESO Lua 5.1)

std = "lua51"

ignore = {
    "212", -- unused argument (ESO event callbacks)
    "631", -- line too long
}

globals = {
    EsoMacMinion = {
        other_fields = true,
    },
    EsoMacMinion_Data = {
        other_fields = true,
    },
    SLASH_COMMANDS = {
        other_fields = true,
    },
    ZO_SavedVars = {
        other_fields = true,
    },
    LibAddonMenu2 = {
        other_fields = true,
    },
}

read_globals = {
    "EVENT_MANAGER",
    "SLASH_COMMANDS",
    "d",
    "zo_callLater",
    "zo_strformat",
    "RequestOpenURL",
    "ZO_ShallowTableCopy",
    "ZO_DeepTableCopy",
    "ZO_SAVED_VARS_CHARACTER_NAME_KEY",
    "ZO_SAVED_VARS_CHARACTER_ID_KEY",
    "GetWorldName",
    "GetDisplayName",
    "GetCurrentCharacterId",
    "GetUnitName",
    "GetAddOnMetadata",
    "GetAddOnManager",
    "GetAPIVersion",
    "GetESOVersionString",
    "GetCVar",
    "GetTimeStamp",
    "GetNumCharacters",
    "GetCharacterInfo",
    "GetPlayerChampionPointsEarned",
    "GetGameTimeMilliseconds",
    "GetFrameTimeMilliseconds",
    "HashString",
    "SOUNDS",
    "CALLBACK_MANAGER",
    "LibDebugLogger",
    "_G",
    "EVENT_ADD_ON_LOADED",
    "EVENT_PLAYER_ACTIVATED",
    "ADDON_STATE_ENABLED",
    "ADDON_STATE_DEPENDENCIES_DISABLED",
    "ADDON_STATE_VERSION_MISMATCH",
    "MAIL_SEND",
    "CallSecureProtected",
    "GetCurrentMoney",
    "IsInGamepadPreferredMode",
}
