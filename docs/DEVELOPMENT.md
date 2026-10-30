# Development

## Prerequisites

```bash
brew install go-task stylua luajit
luarocks install luacheck
brew install pre-commit   # or: pip install pre-commit
```

## Day-to-day

| Task | Command |
|------|---------|
| Lint | `task lint` |
| Format | `task format` |
| Validate | `task validate` |
| Test (lint + validate) | `task test` |
| Install to Live (preferred on Mac) | `task install:live` then `/reloadui` |
| Symlink install | `task install:dev` |
| Fast ZIP | `task build:fast` |

After any Lua/manifest change, run `task install:live` before in-game testing.

## Slash commands

- `/emm` / `/esomacminion` — status (what was recorded and when)
- `/emm help` — help
- `/emm settings` — open LAM
- `/emm debug` — toggle debug
- `/emm clear` — clear recorded snapshots
- `/emm reset` — reset settings (preserves snapshots and `perCharacterData`)

## Agent / AI notes

See root `AGENTS.md`, `CLAUDE.md`, and `.cursorrules`. Prefer the docs in this folder as the source of truth.
