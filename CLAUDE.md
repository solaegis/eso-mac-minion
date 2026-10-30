# CLAUDE.md

Guidance for Claude Code when working in this repository.

<!-- AUTO-MANAGED: project-description -->
## Overview

EsoMacMinion is the in-game companion for MacMinion. It records roster, addon states, and passive SavedVariables/LAM layouts to `EsoMacMinion_Data`. ESO Lua 5.1; no `goto`.

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: build-commands -->
## Build & Development Commands

- **Lint**: `task lint`
- **Format**: `task format`
- **Test**: `task test`
- **Validate**: `task validate`
- **Build**: `task build` / `task build:fast`
- **Install to ESO Live**: `task install:live` (required after code changes for in-game testing)

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->
## Architecture

Load order: Core → SavedVars wrap → AddonObserver → LAM wrap → Layout/Scan → collectors → settings → Init.

Namespace: `EsoMacMinion` (`EMM`). Account-wide SV `EsoMacMinion_Data` with `profile = GetWorldName()`. Docs under `docs/`.

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->
## Code Conventions

- Lua 5.1 only (no `goto`)
- `EMM.SafeCall` / `SafeCallMulti`; `EMM.Info`/`Warn`/`Error`/`DebugPrint` — avoid raw `d()` for product logs
- LAM: plain text only; Support footer via `AppendSupportFooter`
- After code changes: `task install:live`

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->
## Custom Notes

MacMinion reads `SavedVariables/EsoMacMinion_Data.lua`. Keep `EMM.SV_NAME`, the manifest `## SavedVariables:`, and MacMinion `CompanionData` in sync. Never index other addons' ZO_SavedVars proxies.

<!-- END MANUAL -->
