# Agent notes — EsoMacMinion

## Learned User Preferences

- After addon code changes (`.lua`, manifest, `src/`), run `task install:live` then `/reloadui` for in-game testing on Mac (prefer copy+inject over symlink).
- LAM: no emoji/Unicode icons in names or tooltips; keep `choices`/`choicesValues`/`tooltips` the same length; non-nil sentinels only.
- Support footer: Buy Me a Coffee + Send Gold In-Game to `@solaegis`.
- `## Version:` is free-form / `@project-version@` (semver from tag). `## AddOnVersion:` is integer only (`@addon-build-version@` → YYYYMMDD) — never semver.
- Account SavedVariables use `GetWorldName()` as the **profile** (5th arg to `NewAccountWide`), not the namespace.
- Prefer `.yaml` for new YAML files.
- Do not edit attached plan files when implementing from a plan.
- Never index another addon's ZO_SavedVars proxy; walk `_G[svName]` with `next` / `rawget` only.

## Learned Workspace Facts

- This is the in-game companion for MacMinion (`solaegis/mac-minion`). MacMinion reads `SavedVariables/EsoMacMinion_Data.lua`.
- PC manifest is `EsoMacMinion.txt` (not `.addon`). ZIP root must be `EsoMacMinion/`.
- Optional deps: LibAddonMenu-2.0, LibDebugLogger.
- Slash: `/emm` (alias `/esomacminion`). Docs SoT under `docs/`.
- Release workflow uploads to ESOUI when `ESOUI_ADDON_ID != 0` using `secrets.ESOUI_API_KEY`.
- ZO_SavedVars wraps install at file scope; `EVENT_ADD_ON_LOADED` observer is never unregistered.

## Docs map

- `docs/ARCHITECTURE.md`, `DEVELOPMENT.md`, `PUBLISHING.md`
- `docs/esoui-addon-best-practices.md`, `VERSION_PLACEHOLDER_SYSTEM.md`
- `docs/LUA_PATTERNS.md`, `SAVEDVARS.md`, `OPTIONAL_ADVANCED.md`
