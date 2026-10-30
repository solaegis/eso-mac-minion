-- EsoMacMinion - LibAddonMenu-2.0 settings panel

local EMM = EsoMacMinion

local PANEL_NAME = "EsoMacMinionPanel"
local lamPanel = nil

function EMM.OpenSettings()
    if LibAddonMenu2 and LibAddonMenu2.OpenToPanel and lamPanel then
        LibAddonMenu2:OpenToPanel(lamPanel)
    else
        EMM.Chat("Open Settings > Addons > " .. EMM.DISPLAY_NAME)
    end
end

function EMM.RegisterSettingsPanel()
    if not LibAddonMenu2 then
        EMM.Chat("LibAddonMenu-2.0 not found — use /emm for status; settings UI unavailable")
        return
    end

    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = EMM.DISPLAY_NAME,
        displayName = EMM.DISPLAY_NAME,
        author = EMM.AUTHOR,
        version = EMM.VERSION,
        slashCommand = "/emmsettings",
        registerForRefresh = true,
        registerForDefaults = true,
        website = EMM.WEBSITE_URL,
        feedback = EMM.FEEDBACK_URL,
        donation = EMM.OpenGoldDonationMail,
        defaultsFunc = function()
            EMM.ResetSettings()
        end,
    }

    local optionsTable = {
        {
            type = "description",
            text = "Records what only the running game knows so MacMinion can read it after you log out or /reloadui. Nothing is sent anywhere.",
            width = "full",
        },
        {
            type = "header",
            name = "Recording",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Record SavedVariables and LAM layouts",
            tooltip = "Observe ZO_SavedVars constructors and LibAddonMenu panels. Stores key paths and types, not values.",
            getFunc = function()
                return EMM.db == nil or EMM.db.recordLayouts ~= false
            end,
            setFunc = function(value)
                if EMM.db then
                    EMM.db.recordLayouts = value
                end
            end,
            default = true,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Record Lua errors",
            tooltip = "Reserved for a later version. When enabled, Lua errors will be attributed to addons.",
            getFunc = function()
                return EMM.db == nil or EMM.db.recordErrors ~= false
            end,
            setFunc = function(value)
                if EMM.db then
                    EMM.db.recordErrors = value
                end
            end,
            default = true,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Record performance samples",
            tooltip = "Reserved for a later version. When enabled, frame rate and load times will be sampled out of combat.",
            getFunc = function()
                return EMM.db == nil or EMM.db.recordPerf ~= false
            end,
            setFunc = function(value)
                if EMM.db then
                    EMM.db.recordPerf = value
                end
            end,
            default = true,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Record account snapshot",
            tooltip = "Reserved for a later version. Gold, currencies, and bag space. Off by default.",
            getFunc = function()
                return EMM.db and EMM.db.recordAccount == true
            end,
            setFunc = function(value)
                if EMM.db then
                    EMM.db.recordAccount = value
                end
            end,
            default = false,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug logging",
            tooltip = "Show extra debug messages in chat (and LibDebugLogger when installed).",
            getFunc = function()
                return EMM.db and EMM.db.debug == true
            end,
            setFunc = function(value)
                if EMM.db then
                    EMM.db.debug = value
                end
                EMM.debug = value
            end,
            default = false,
            width = "full",
        },
        {
            type = "button",
            name = "Clear recorded data",
            tooltip = "Wipe roster, addon, and layout snapshots. Settings toggles stay.",
            func = function()
                EMM.ClearRecordedData()
            end,
            width = "full",
        },
    }

    EMM.AppendSupportFooter(optionsTable)

    lamPanel = LAM:RegisterAddonPanel(PANEL_NAME, panelData)
    LAM:RegisterOptionControls(PANEL_NAME, optionsTable)
end
