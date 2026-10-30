# SavedVariables

## Profile is the server

`ZO_SavedVars:NewAccountWide` takes `profile` as the **fifth** argument. That is the first table level. This companion passes `GetWorldName()` there so MacMinion finds data at `["NA Megaserver"]["@account"]["$AccountWide"]`:

```lua
EMM.db = ZO_SavedVars:NewAccountWide(
    EMM.SV_NAME,
    EMM.SV_VERSION,
    nil,
    defaults,
    GetWorldName()
)
```

The third argument is `namespace` (deepest extra key). It has no default. Community posts mix profile and namespace; go by `zo_savedvars.lua`.

Create SavedVariables only inside `EVENT_ADD_ON_LOADED` (see `src/Init.lua`).

## Naming

- Manifest: `## SavedVariables: EsoMacMinion_Data`
- File the game writes: `SavedVariables/EsoMacMinion_Data.lua`
- Keep `EMM.SV_NAME` in Core in sync with the manifest

## Schema

`schema = 1` is the snapshot shape MacMinion reads. Bump `EMM.SCHEMA` when a section changes shape. `written` is `GetTimeStamp()` after each record change — there is no “about to save” hook, so the in-memory table must stay complete.

## Per-character data

Optional product fields stay under `perCharacterData[characterId]`. Reset preserves that table and the recorded snapshots; **Clear recorded data** wipes snapshots only.

## Walking other addons’ tables

Never index another addon’s ZO_SavedVars proxy (`sv.someKey` copies defaults into their file). Walk `_G[svName]` with `next` / `rawget` only.
