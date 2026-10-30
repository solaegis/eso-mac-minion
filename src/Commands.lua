-- EsoMacMinion - slash commands

local EMM = EsoMacMinion

local function printHelp()
    EMM.Chat("Commands:")
    EMM.Chat("  /emm            — status (what was recorded and when)")
    EMM.Chat("  /emm help       — this help")
    EMM.Chat("  /emm settings   — open settings (LibAddonMenu)")
    EMM.Chat("  /emm debug      — toggle debug logging")
    EMM.Chat("  /emm clear      — clear recorded snapshots")
    EMM.Chat("  /emm reset      — reset settings to defaults")
end

local function printStatus()
    local db = EMM.db
    local env = db and db.env or {}
    local written = db and db.written or 0
    local nChars = EMM.CountTable(db and db.characters)
    local nAddons = EMM.CountTable(db and db.addons)
    local nSv = EMM.CountTable(db and db.layouts and db.layouts.sv)
    local nLam = EMM.CountTable(db and db.layouts and db.layouts.lam)

    EMM.Chat(
        string.format(
            "%s v%s | schema=%s written=%s",
            EMM.DISPLAY_NAME,
            EMM.VERSION,
            tostring(db and db.schema or EMM.SCHEMA),
            tostring(written)
        )
    )
    EMM.Chat(
        string.format(
            "  env: api=%s game=%s server=%s lang=%s",
            tostring(env.apiVersion or "?"),
            tostring(env.gameVersion or "?"),
            tostring(env.server or "?"),
            tostring(env.language or "?")
        )
    )
    EMM.Chat(string.format("  roster=%d addons=%d layouts sv=%d lam=%d", nChars, nAddons, nSv, nLam))
    EMM.Chat(
        string.format(
            "  layouts=%s errors=%s perf=%s account=%s debug=%s",
            tostring(db and db.recordLayouts ~= false),
            tostring(db and db.recordErrors ~= false),
            tostring(db and db.recordPerf ~= false),
            tostring(db and db.recordAccount == true),
            tostring(EMM.IsDebugEnabled())
        )
    )
    EMM.Chat("Nothing is sent anywhere. MacMinion reads this file after you log out or /reloadui.")
end

local function handleCommand(args)
    args = zo_strformat("<<1>>", args or "") or ""
    args = string.lower(string.gsub(args, "^%s+", ""))
    args = string.gsub(args, "%s+$", "")

    if args == "" or args == "status" then
        printStatus()
        return
    end

    if args == "help" or args == "?" then
        printHelp()
        return
    end

    if args == "settings" or args == "options" then
        if EMM.OpenSettings then
            EMM.OpenSettings()
        else
            EMM.Chat("Open Settings > Addons > " .. EMM.DISPLAY_NAME)
        end
        return
    end

    if args == "debug" then
        if not EMM.db then
            return
        end
        EMM.db.debug = not EMM.db.debug
        EMM.debug = EMM.db.debug
        EMM.Chat("Debug " .. (EMM.db.debug and "ON" or "OFF"))
        return
    end

    if args == "clear" then
        EMM.ClearRecordedData()
        return
    end

    if args == "reset" then
        EMM.ResetSettings()
        return
    end

    EMM.Chat("Unknown command. Try /emm help")
end

function EMM.RegisterCommands()
    SLASH_COMMANDS["/emm"] = handleCommand
    SLASH_COMMANDS["/esomacminion"] = handleCommand
end
