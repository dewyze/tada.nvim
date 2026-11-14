## 0.1.0 - 2026-11-14

First release of tada.nvim, a rewrite in Lua for Neovim 0.11 and later of
[vim-tada](https://github.com/dewyze/vim-tada). The Vimscript plugin's own
history is in that repository's changelog.

- Plans live in a project's `.tada/` folder, one file each, with finished work
  in `.tada/archive/`
- A side pane for the plan edited last, and `:Tada` commands to pick a plan,
  start one, and archive an entry, a selection, or a whole plan
- Topics nest three deep; folds are Vim's own, and a closed topic counts its
  todos by status
- Links open with `gf`, and names are offered while typing assignees
- One `setup()` call for statuses, colors, keys and the pane, replacing the
  `g:tada_*` variables
- A Claude Code skill for reading and writing plans

Changed from vim-tada:

- Neovim only
- No key prefix: fold with `zM`, `zR`, `zm`, `zr`, `zO`, `zc`, and give any
  other action a key in `setup()`
- No per-file `@config` lines, no in-file `===` archive, and no `?` status sigil
- Colors are a hex string or a highlight group name; terminal color numbers
  are gone
