# PetXPBarPlus development guidance

Follow the shared [StormCore standards](https://github.com/DustinChecketts/stormcore). Before significant changes, read its AGENTS.md and standards/development.md, compatibility.md, packaging.md, and release-readiness.md.

- PetXPBarPlus remains independently installable; never add a StormCore runtime dependency.
- Preserve Hunter-only behavior, Blizzard PetFrame integration, `/pxp` commands, and `PetXPBarPlusDB` SavedVariables, including the 1.3.1 ADDON_LOADED persistence fix.
- Preserve Forever, Classic Anniversary, and Classic Era behavior; Forever is not Retail despite its project ID.
- Keep the existing small Compat.lua, Options.lua, and core structure unless a focused change warrants otherwise.
- Treat protected/secret values defensively; offline checks cannot replace in-game tests.
- Develop on a branch; do not create PRs, merge, tag, or publish without maintainer approval.
- Validate Lua 5.1 syntax, TOC references, changelog/version, package contents, and affected client behavior before release.
- Keep development documents, CI files, and tests out of player ZIPs.
