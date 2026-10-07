local ADDON_NAME = ...
PetXPBarPlus = PetXPBarPlus or {}
local Addon = PetXPBarPlus
local Compat = Addon.Compat

local PURPLE = { r = 0.58, g = 0.24, b = 0.86 }
local BLUE = { r = 25 / 255, g = 125 / 255, b = 255 / 255 }

local DEFAULTS = {
    showXPBar = true,
    showPetLevel = true,
    alwaysShowXPBar = false,
    alwaysShowPetLevel = false,
    locked = false,
}
Addon.DEFAULTS = DEFAULTS

local function CopyColor(color)
    return { r = color.r, g = color.g, b = color.b }
end

local function InitializeDB()
    PetXPBarPlusDB = type(PetXPBarPlusDB) == "table" and PetXPBarPlusDB or {}
    Addon.db = PetXPBarPlusDB

    for key, value in pairs(DEFAULTS) do
        if Addon.db[key] == nil then
            Addon.db[key] = value
        end
    end

    if type(Addon.db.xpColor) ~= "table" then
        Addon.db.xpColor = CopyColor(Compat.isForever and PURPLE or BLUE)
    end
end

local controls = {}
local colorRadios = {}
local customLabel

local function ColorToHex(color)
    local r = math.floor((color.r or 0) * 255 + 0.5)
    local g = math.floor((color.g or 0) * 255 + 0.5)
    local b = math.floor((color.b or 0) * 255 + 0.5)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function SameColor(a, b)
    return a and b and math.abs(a.r - b.r) < 0.001 and math.abs(a.g - b.g) < 0.001 and math.abs(a.b - b.b) < 0.001
end

local function Apply()
    if Addon.ApplyDisplayOptions then Addon.ApplyDisplayOptions() end
    if Addon.ApplyXPBarColor then Addon.ApplyXPBarColor() end
    if Addon.SetLocked then Addon.SetLocked(Addon.db.locked) end
end

local function RefreshControls()
    for key, check in pairs(controls) do
        check:SetChecked(Addon.db[key])
    end
    local mode = Addon.db.xpColorMode
    if not mode then
        if SameColor(Addon.db.xpColor, PURPLE) then mode = "purple"
        elseif SameColor(Addon.db.xpColor, BLUE) then mode = "blue"
        else mode = "custom" end
    end
    for key, radio in pairs(colorRadios) do
        radio:SetChecked(key == mode)
    end
    if customLabel then
        customLabel:SetText(mode == "custom" and ("Custom (" .. ColorToHex(Addon.db.xpColor) .. ")") or "Custom (Pick)")
    end
end

local function SetColor(color, mode)
    Addon.db.xpColor = CopyColor(color)
    if mode then Addon.db.xpColorMode = mode end
    RefreshControls()
    Apply()
end

local function ResetDefaults()
    for key, value in pairs(DEFAULTS) do
        Addon.db[key] = value
    end
    Addon.db.xpColor = CopyColor(Compat.isForever and PURPLE or BLUE)
    Addon.db.xpColorMode = Compat.isForever and "purple" or "blue"
    if Addon.ResetPosition then Addon.ResetPosition() end
    RefreshControls()
    Apply()
end
Addon.ResetDefaults = ResetDefaults

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
    if textRegion then textRegion:SetText(label) end
    controls[key] = check
    check:SetScript("OnShow", function(self) self:SetChecked(Addon.db[key]) end)
    check:SetScript("OnClick", function(self)
        Addon.db[key] = self:GetChecked() and true or false
        Apply()
    end)
    return check
end

MakeCheckbox("Show XP Bar", "showXPBar", -58)
MakeCheckbox("Show Pet Level", "showPetLevel", -88)

local behaviorTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
behaviorTitle:SetPoint("TOPLEFT", 16, -126)
behaviorTitle:SetText("Visibility Behavior")

MakeCheckbox("Always show XP Bar", "alwaysShowXPBar", -150)
MakeCheckbox("Always show Pet Level", "alwaysShowPetLevel", -180)

local behaviorNote = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
behaviorNote:SetPoint("TOPLEFT", 42, -208)
behaviorNote:SetWidth(430)
behaviorNote:SetJustifyH("LEFT")
behaviorNote:SetText("By default, the XP bar hides when your pet cannot gain XP, and the pet level hides at the level cap.")

local appearanceTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
appearanceTitle:SetPoint("TOPLEFT", 16, -244)
appearanceTitle:SetText("XP Bar Color")

local function MakeButton(label, x, y, width, onClick)
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    button:SetPoint("TOPLEFT", x, y)
    button:SetText(label)
    button:SetScript("OnClick", onClick)
    return button
end

local function MakeColorRadio(key, label, color, y)
    local radio = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
    radio:SetPoint("TOPLEFT", 16, y)
    colorRadios[key] = radio

    local sample = panel:CreateTexture(nil, "ARTWORK")
    sample:SetSize(18, 18)
    sample:SetPoint("LEFT", radio, "RIGHT", 4, 0)
    sample:SetColorTexture(color.r, color.g, color.b)

    local textRegion = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    textRegion:SetPoint("LEFT", sample, "RIGHT", 8, 0)
    textRegion:SetText(label)

    radio:SetScript("OnClick", function()
        SetColor(color, key)
    end)
    return radio, textRegion
end

MakeColorRadio("purple", "Forever", PURPLE, -268)
MakeColorRadio("blue", "Classic", BLUE, -298)

local customRadio = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
customRadio:SetPoint("TOPLEFT", 16, -328)
colorRadios.custom = customRadio

local customSample = panel:CreateTexture(nil, "ARTWORK")
customSample:SetSize(18, 18)
customSample:SetPoint("LEFT", customRadio, "RIGHT", 4, 0)
customSample:SetColorTexture(1, 1, 1)

customLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
customLabel:SetPoint("LEFT", customSample, "RIGHT", 8, 0)
customLabel:SetText("Custom (Pick)")

local function OpenColorPicker()
    local old = CopyColor(Addon.db.xpColor)
    local oldMode = Addon.db.xpColorMode
    Addon.db.xpColorMode = "custom"
    RefreshControls()

    local function changed()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        customSample:SetColorTexture(r, g, b)
        SetColor({ r = r, g = g, b = b }, "custom")
    end
    local function cancelled(previous)
        local restore = (type(previous) == "table" and previous.r) and previous or old
        customSample:SetColorTexture(restore.r, restore.g, restore.b)
        SetColor(restore, oldMode)
    end

    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = old.r, g = old.g, b = old.b,
            swatchFunc = changed,
            cancelFunc = cancelled,
            hasOpacity = false,
        })
    else
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.previousValues = old
        ColorPickerFrame.func = changed
        ColorPickerFrame.cancelFunc = cancelled
        ColorPickerFrame:SetColorRGB(old.r, old.g, old.b)
        ColorPickerFrame:Show()
    end
end
customRadio:SetScript("OnClick", OpenColorPicker)
customLabel:SetScript("OnMouseDown", OpenColorPicker)
customLabel:EnableMouse(true)
local positionTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
positionTitle:SetPoint("TOPLEFT", 16, -370)
positionTitle:SetText("Position")

MakeCheckbox("Lock Position", "locked", -392)
MakeButton("Reset Position", 42, -424, 112, function()
    if Addon.ResetPosition then Addon.ResetPosition() end
end)

local defaultsButton = MakeButton("Defaults", 16, -470, 96, ResetDefaults)

panel:SetScript("OnShow", function()
    RefreshControls()
end)

local category = Compat.RegisterOptionsPanel(panel)

function Addon.OpenOptions()
    Compat.OpenOptionsPanel(panel, category)
end

-- SavedVariables are guaranteed to be available for this addon when
-- ADDON_LOADED fires. Initializing earlier can replace the table before the
-- client restores PetXPBarPlusDB, which makes settings appear to work for the
-- current session but revert after logout/reload on affected clients.
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, loadedAddon)
    if loadedAddon ~= ADDON_NAME then
        return
    end

    self:UnregisterEvent("ADDON_LOADED")
    InitializeDB()
    RefreshControls()
    Apply()
end)
