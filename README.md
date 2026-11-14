# Vim Tada

Turn your todos :white_check_mark: into tadas :tada:.

Tada is a plain-text format for short plans, and a Neovim plugin for moving
around in them fast: nested topics, todos with statuses, folds that count
what's left, and an archive for what's done.

```
> Admins can put item photos in the order they want
- Admin:
  - Photos:
    - [✔] Upload photos
    - [•] Reorder photos
          > Order survives a reload
    - [ ] Remove a photo
    - [⚑] Bulk upload
          > Not now, nobody has asked
- Storefront:
  - [ ] Photos show in the admin's order
```

Folded, that plan reads:

```
> Admins can put item photos in the order they want
❯ Admin: 1[ ], 1[•], 1[✔], 1[⚑]
❯ Storefront: 1[ ]
```

## Motivation

On solo projects I want an organized list of what I'm doing without leaving my
editor, and GitHub projects, Trello and Jira are all more than that. These days
I also plan work with an LLM, which will happily produce a long Markdown
document nobody wants to read. A tada plan is a format we can both write that
stays short enough to take in at a glance.

## Installation

Requires Neovim 0.10 or later. With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "dewyze/vim-tada" }
```

Calling `setup` is optional; see [Configuration](#configuration).

The earlier Vimscript version, which also runs in Vim, is the `1.0.0` tag:

```vim
Plug 'dewyze/vim-tada', { 'tag': '1.0.0' }
```

## Format

Files ending in `.tada`, and files named `Tadafile`, are tada plans.

| Line | Looks like | Notes |
|---|---|---|
| Topic | `- Title:` | Nests up to three deep, two spaces a level |
| Todo | `- [ ] text` | The box holds a status |
| List item | `- text` | For things that aren't work to tick off |
| Note | `> text` | Hangs under the text of the entry it belongs to |
| Metadata | `\| @:alice` | Hangs under its topic; see below |
| Comment | `# text` | |

A todo has no children. If it needs them, it's a topic.

A plan can open with a note saying what it's for and some links, above the
first topic.

### Statuses

A todo moves through an ordered list of statuses. There are four styles:

| Style | Statuses |
|---|---|
| `unicode` (default) | `[ ]` blank, `[•]` in progress, `[✔]` done, `[⚑]` flagged |
| `ascii` | `[ ]` blank, `[-]` in progress, `[x]` done, `[o]` flagged |
| `simple` | `[ ]` blank, `[✔]` done |
| `markdown` | `[ ]` blank, `[x]` done |

Or define your own; see [Configuration](#configuration).

### Metadata

A metadata line is `| <sigil>:<value>`.

| Sigil | Meaning |
|---|---|
| `&` | Link: a web address, or `path/to/file.rb:42` |
| `@` | Assignees |
| `!` | Priority |
| `#` | Tags |
| `^` | Start date |
| `$` | End date |
| `?` | Status |

Links can be followed with `gf`. While you type after `@:`, a menu offers the
names already assigned anywhere in the project's plans; `<Tab>` moves through
it and `<CR>` takes the chosen name. The other sigils are highlighted and
otherwise do nothing yet.

## Keys

All of these apply only in a tada file, and all can be moved or turned off.

### Editing

| Key | Mode | Does |
|---|---|---|
| `<C-Space>` | normal, insert | Adds or removes the box on a line |
| `<Space>` | normal | Moves a todo to its next status |
| `<CR>`, `o`, `O` | insert, normal | Carry on with the same kind of line: a new box after a todo, a bullet inside a topic |
| `<CR>` on an empty bullet or box | insert | Clears the line, ending the list |
| `<Tab>`, `<S-Tab>` | insert | Indent or outdent an empty bullet or box |
| `:` on an empty bullet or box | insert | Steps it out a level, ready for a topic title |
| `>` on an empty bullet or box | insert | Turns it into a note |
| `\|` on an empty bullet or box | insert | Turns it into metadata |
| `<C-H>` | insert | Blanks out everything left of the cursor, so the text continues the line above |

### Folds

| Key | Does |
|---|---|
| `<CR>` | Opens or closes the topic under the cursor |
| `<C-T>1` to `<C-T>3` | Shows topics down to that level |
| `<C-T>0` | Shows everything |
| `<C-T>o`, `<C-T>c` | Opens or closes the topic around the cursor |

A closed topic shows its title and a count of the todos beneath it by status.

### Moving

| Key | Does |
|---|---|
| `(`, `)` | Previous or next topic at this level or above |
| `{`, `}` | Previous or next topic one level up |
| `gf` | On a link, opens the file at its line, or the web address |

## Plans

A project keeps its plans in a `.tada/` folder, one file per plan:

```
.tada/
  photo-order.tada
  checkout.tada
  archive/
    photo-order.tada
```

A `Tadafile` in the project root also counts as a plan.

| Key | Command | Does |
|---|---|---|
| `<LocalLeader>td` | `:Tada` | Opens the plan edited last in a side pane, or closes the pane |
| `<LocalLeader>tp` | `:Tada pick` | Picks a plan, or starts a new one |
| `<LocalLeader>ta` | `:Tada archived` | Picks an archived plan |
| | `:Tada new <name>` | Starts a plan |

These work from any buffer. With no plans yet, `<LocalLeader>td` asks for a
name and starts one.

### Archiving

| Key | Command | Does |
|---|---|---|
| `<C-T>a` | `:Tada archive` | Archives the entry under the cursor and everything beneath it |
| `<C-T>a` (visual) | `:'<,'>Tada archive` | Archives the selected lines |
| `<C-T>A` | `:Tada archive-plan` | Archives the whole plan and removes it, after asking |

Archived lines move to the file of the same name in `.tada/archive/`, under
the titles of the topics they sat in. Both files are saved straight away.

## Configuration

Everything is optional. These are the defaults:

```lua
require("tada").setup({
  style = "unicode", -- or "ascii", "simple", "markdown"

  assignees = {}, -- names to offer after @:, besides the ones already in your plans

  pane = {
    side = "right", -- or "left", "top", "bottom"
    size = nil, -- a number, or a function returning one; a third of the screen, up to 60 columns
  },

  keys = {
    toggle_box = "<C-Space>",
    cycle_status = "<Space>",
    clear_marker = "<C-H>",
    prefix = "<C-T>", -- for the fold and archive keys

    pane = "<LocalLeader>td",
    pick = "<LocalLeader>tp",
    archived = "<LocalLeader>ta",
  },

  colors = {
    topic = { "#b294bb", "#648cb4", "#de935f" }, -- one per level
    note = "#bfbc91",
    metadata = "#4bb1a7",
    comment = "#969896",
    todo = {
      in_progress = "#f0c674",
      done = "#84b97c",
      flagged = "#cc6666",
    },
  },
})
```

Set any key to `false` to turn it off. The other keys can be set the same way:
`continue`, `open_below`, `open_above`, `indent_more`, `indent_less`,
`start_topic`, `start_note`, `start_metadata`, `toggle_fold`, `previous_topic`,
`next_topic`, `previous_parent_topic`, `next_parent_topic`, `follow_link`,
`archive` and `archive_plan`.

A color is a hex string or the name of a highlight group to follow, such as
`"Comment"`.

To use your own statuses in place of a style, list them in order. The first is
where a new todo starts:

```lua
require("tada").setup({
  statuses = {
    { name = "planned", symbol = " " },
    { name = "doing", symbol = "🛠️", color = "#f0c674" },
    { name = "complete", symbol = "✅", color = "#84b97c" },
  },
})
```

## Planning with Claude

`skills/tada` is a [Claude Code](https://claude.com/claude-code) skill that
teaches Claude to read and write tada plans: outcomes over implementation
steps, short phrases, and long notes kept out of the plan in `.tada/context/`.
To install it, link it into your skills folder:

```
ln -s /path/to/vim-tada/skills/tada ~/.claude/skills/tada
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Tests run in headless Neovim with
`bin/test`.

## [Code of Conduct](CODE_OF_CONDUCT.md)

## [License](LICENSE)
