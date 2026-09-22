local ADDON_NAME = ...
PetXPBarPlus = PetXPBarPlus or {}
local Addon = PetXPBarPlus\nlocal Compat = Addon.Compat

local DEFAULTS = {
    showXPBar = true,
    showPetLevel = true,
}

local function InitializeDB()
    PetXPBarPlusDB = type(PetXPBarPlusDB) == "table" and PetXPBarPlusDB or {}
    Addon.db = PetXPBarPlusDB

    for key, value in pairs(DEFAULTS) do
        if Addon.db[key] == nil then
            Addon.db[key] = value
        end
    end
end

local function Apply()
    if Addon.ApplyDisplayOptions then
        Addon.ApplyDisplayOptions()
    end
end

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

local category = Compat.RegisterOptionsPanel(panel)

function Addon.OpenOptions()
    Compat.OpenOptionsPanel(panel, category)
end
