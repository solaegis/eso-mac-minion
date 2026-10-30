-- EsoMacMinion - wrap LibAddonMenu-2.0 registration (no registration callback exists).

local EMM = EsoMacMinion

function EMM.WrapLAM()
    if EMM._lamWrapped then
        return
    end
    if type(LibAddonMenu2) ~= "table" then
        return
    end
    EMM._lamWrapped = true

    local LAM = LibAddonMenu2
    local origPanel = LAM.RegisterAddonPanel
    if type(origPanel) == "function" then
        LAM.RegisterAddonPanel = function(self, panelName, panelData)
            if EMM.RecordLAMPanel then
                pcall(EMM.RecordLAMPanel, panelName, panelData)
            end
            return origPanel(self, panelName, panelData)
        end
    end

    local origOpts = LAM.RegisterOptionControls
    if type(origOpts) == "function" then
        LAM.RegisterOptionControls = function(self, panelName, optionsTable)
            if EMM.RecordLAMOptions then
                pcall(EMM.RecordLAMOptions, panelName, optionsTable)
            end
            return origOpts(self, panelName, optionsTable)
        end
    end

    if CALLBACK_MANAGER and CALLBACK_MANAGER.RegisterCallback then
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
            if EMM.RecordLAMPanelCreated then
                pcall(EMM.RecordLAMPanelCreated, panel)
            end
        end)
    end
end

EMM.WrapLAM()
