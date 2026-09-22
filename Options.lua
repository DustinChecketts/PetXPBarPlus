local ADDON_NAME = ...
PetXPBarPlus = PetXPBarPlus or {}
local Addon = PetXPBarPlus
local Compat = Addon.Compat

local DEFAULTS = {
    showXPBar = true,
    showPetLevel = true,
}
Addon.DEFAULTS = DEFAULTS

local function InitializeDB()
    PetXPBarPlusDB = type(PetXPBarPlusDB) == "table" and PetXPBarPlusDB or {}
    Addon.db = PetXPBarPlusDB

    for key, value in pairs(DEFAULTS) do
        if Addon.db[key] == nil then
            Addon.db[key] = value
        end
    end
end

local controls = {}

local function Apply()
    if Addon.ApplyDisplayOptions then
        Addon.ApplyDisplayOptions()
    end
end

local function RefreshControls()
    for key, check in pairs(controls) do
        check:SetChecked(Addon.db[key])
    end
end

local function ResetDefaults()
    for key, value in pairs(DEFAULTS) do
        Addon.db[key] = value
    end
    RefreshControls()
    Apply()
end
Addon.ResetDefaults = ResetDefaults

InitializeDB()

local panel = CreateFrame("Frame", "PetXPBarPlusOptionsPanel")
panel.name = "PetXPBarPlus"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("PetXPBarPlus")

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Pet experience display options.")

local function MakeCheckbox(label, key, y)
    local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", 16, y)

    local textRegion = check.Text or check.text
    if textRegion then
        textRegion:SetText(label)
    end

    controls[key] = check
    check:SetScript("OnShow", function(self)
        self:SetChecked(Addon.db[key])
    end)
    check:SetScript("OnClick", function(self)
        Addon.db[key] = self:GetChecked() and true or false
        Apply()
    end)
    return check
end

MakeCheckbox("Show XP Bar", "showXPBar", -58)
MakeCheckbox("Show Pet Level", "showPetLevel", -88)

local defaultsButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
defaultsButton:SetSize(96, 22)
defaultsButton:SetPoint("TOPLEFT", 16, -124)
defaultsButton:SetText("Defaults")
defaultsButton:SetScript("OnClick", ResetDefaults)

panel:SetScript("OnShow", function()
    RefreshControls()
end)

local category = Compat.RegisterOptionsPanel(panel)

function Addon.OpenOptions()
    Compat.OpenOptionsPanel(panel, category)
end
