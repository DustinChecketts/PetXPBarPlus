# Architecture

PetXPBarPlus is maintained by StormtrooperTK421 as part of a multi-client World of Warcraft addon family.

## Design goals

- Keep pet XP behavior independent from Blizzard client-specific APIs where practical.
- Prefer capability detection over client/version checks.
- Keep client/API compatibility in `Compat.lua`.
- Keep user-facing settings and defaults in `Options.lua`.
- Preserve one addon version across supported WoW clients; client support is not the addon version.
- Preserve established Classic Era/Anniversary behavior while allowing Forever-specific presentation where required.

## File responsibilities

- `PetXPBarPlus.lua` — core Hunter-pet XP, visibility, frame, and event behavior.
- `Compat.lua` — Blizzard API adapters, client capability handling, and Settings compatibility.
- `Options.lua` — SavedVariables defaults and user-facing settings.
- `PetXPBarPlus.toc` — metadata and load order.

## Compatibility strategy

Feature code should use the compatibility layer when Blizzard exposes equivalent functionality through different APIs. Explicit client detection is reserved for presentation or behavior that genuinely differs by client.

WoW Forever must not be assumed to be Retail solely because it reports `WOW_PROJECT_MAINLINE`; capability checks remain authoritative.

The addon only displays for Hunter-style pets reported by Blizzard's pet UI as Hunter pets.

## StormCore quality and packaging

StormCore supplies shared development guidance and reusable validation; it is not loaded by the addon. The pilot workflow runs Lua 5.1 parsing, TOC and metadata checks, package-preview inspection, and advisory lint/format checks. Do not reformat working Lua merely to clear an unreviewed baseline.

`.pkgmeta` excludes developer-only material from player ZIPs. Inspect the actual package preview and final release ZIP before publishing. The existing CurseForge release workflow remains separate.

## Development

`main` is the known-good/release branch. Compatibility and modernization work is developed on branches and merged after testing. Avoid PRs during iteration; never merge, tag, or publish without maintainer approval. Preserve saved settings, slash commands, and tested client behavior.

PetXPBarPlus is authored and maintained by StormtrooperTK421. Development and modernization work is performed with assistance from OpenAI's ChatGPT, including code implementation, compatibility work, testing support, and documentation.
