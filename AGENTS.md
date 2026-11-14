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

## Mandatory research-first workflow
1. Before unfamiliar features or bug fixes, search maintained WoW addons that solve the same or similar problem. Inspect their source code and Blizzard UI implementations when relevant; document the applicable APIs, compatibility constraints, and tradeoffs. Respect licenses and credit adaptations.
2. If no proven implementation exists, consult Blizzard UI source, API documentation, and reliable technical references. Separate facts from hypotheses; use minimal read-only diagnostics and targeted in-game tests to gather evidence. Do not cycle through speculative fixes.
3. Before substantial changes, define module responsibilities and preserve clear boundaries between compatibility, data, logic, UI, events, and options where useful. Prefer existing Blizzard APIs and simple reusable helpers over duplication or needless abstractions.
4. Review code for consistency, dead code, oversized modules, performance costs, and unintended client regressions. Run applicable StormCore lint, format, syntax, TOC, and packaging checks. Clearly distinguish offline checks from in-game verification.
5. Work on dedicated branches, preserve known-good behavior, and do not open PRs during iteration, merge, tag, or publish without maintainer approval. Report evidence, changes, checks, remaining uncertainty, and exact test instructions.

Priority: correctness and compatibility > architecture and maintainability > portfolio consistency > lightweight simplicity > optional visual polish.
