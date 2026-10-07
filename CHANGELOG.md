# Changelog

## 1.3.1

### Fixes
- Fix PetXPBarPlus settings not reliably persisting between sessions on affected clients.
- Initialize SavedVariables after the addon receives `ADDON_LOADED`, ensuring saved color, visibility, lock, and position settings are restored before they are applied.


## 1.3.0

### Appearance
- Add Forever and Classic XP bar color presets.
- Add a custom color picker with a persistent color swatch and hex value.

### Position
- Add Lock Position and Reset Position controls to the options panel.
- Persist the dragged frame position and lock state across sessions.
- Keep `/pxp lock`, `/pxp unlock`, and `/pxp reset` synchronized with the saved options.

## 1.2.0

### WoW Forever
- Add support for WoW Forever 1.60.1 / Interface 16001.
- Add a Forever-specific purple pet XP bar and compact pet-level medallion.
- Automatically hide the XP bar when the active Hunter pet cannot gain XP.
- Automatically hide the pet level at the client level cap.
- Add optional overrides to always show the XP bar or pet level.

### Options
- Add a dedicated PetXPBarPlus options panel.
- Add persistent Show XP Bar and Show Pet Level settings.
- Add visibility-behavior overrides and a Defaults button.
- Add `/pxp options` and `/pxp debug`.

### Compatibility and maintenance
- Preserve Classic Anniversary 2.5.6 / Interface 20506 and Classic Era 1.15.9 / Interface 11509 support.
- Add capability-based compatibility helpers in `Compat.lua`.
- Preserve the established Classic presentation on non-Forever clients.
- Harden Hunter-pet detection, pet-frame anchoring, layer synchronization, and guarded API access.
