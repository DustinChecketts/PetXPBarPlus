# Changelog

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
