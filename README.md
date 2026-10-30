# ESO Mac Minion

[![Version](https://img.shields.io/github/v/release/solaegis/eso-mac-minion?include_prereleases&sort=semver&label=Version)](https://github.com/solaegis/eso-mac-minion/releases)
[![ESO API](https://img.shields.io/badge/ESO_API-101051-blue)](https://github.com/solaegis/eso-mac-minion)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

In-game companion for [MacMinion](https://github.com/solaegis/mac-minion). It writes what only the running game knows to `SavedVariables/EsoMacMinion_Data.lua`, which MacMinion reads after you log out or `/reloadui`.

Nothing is sent anywhere. The file stays on the Mac.

## What it records (schema 1)

| Section | Contents |
|---|---|
| `env` | API version, game version, server, language, companion version |
| `characters` | Roster keyed by character id (class, level, last played for the current character) |
| `addons` | What actually loaded, missing dependencies, load order / timing |
| `layouts.sv` | ZO_SavedVars constructor calls plus a `_G` backfill (key paths and types, not values) |
| `layouts.lam` | LibAddonMenu panel and control types, names, and `reference` strings |

Later versions add Lua errors, performance samples, guilds, name lookups, and an optional account snapshot. The settings toggles for those are already in the panel.

## Commands

| Command | Action |
|---|---|
| `/emm` | Status: what was recorded and when |
| `/emm help` | Help |
| `/emm settings` | Open LibAddonMenu panel |
| `/emm debug` | Toggle debug |
| `/emm clear` | Wipe recorded snapshots |
| `/emm reset` | Reset settings (keeps snapshots) |

Alias: `/esomacminion`. LAM also registers `/emmsettings`.

## Install

```bash
task install:live
```

Then `/reloadui` in game. MacMinion will later bundle and update this addon; until then, install from this repo.

## SavedVariables layout

```lua
EsoMacMinion_Data = {
    ["NA Megaserver"] = { ["@account"] = { ["$AccountWide"] = {
        version = 1,
        schema = 1,
        written = 1793288692,
        env = { ... },
        characters = { ... },
        addons = { ... },
        layouts = { sv = { ... }, lam = { ... } },
    } } },
}
```

`GetWorldName()` is the **profile** (first table level), not the namespace. See [docs/SAVEDVARS.md](docs/SAVEDVARS.md).

## Tooling

| Task | Description |
|---|---|
| `task test` | Lint + validate |
| `task lint` | Luacheck |
| `task format` | StyLua |
| `task install:live` | Copy into ESO Live AddOns with version injection |

## Support

- [Buy Me a Coffee](https://www.buymeacoffee.com/lewisvavasw)
- In-game gold mail to `@solaegis` (from the settings Support footer)

## License

MIT — see [LICENSE](LICENSE).
