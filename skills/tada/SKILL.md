---
name: tada
description: Read and write tada plans, the short nested todo files kept in a project's .tada/ folder. Use when planning work, breaking a project into tasks, tracking progress on a plan, or when the project has a .tada/ folder or a Tadafile, and whenever you would otherwise write a planning document in Markdown.
---

# Tada plans

A tada plan is a short outline of work that a person and you both edit. The
person reads it in an editor that folds topics, colours todos by status, and
counts what's left, so they can take in a whole project in a few seconds and
open only the part they care about. Everything below serves that: the plan is
for glancing at. If it reads like a document, it has stopped doing its job.

## Where things live

- `.tada/<name>.tada` is a plan. Start with one plan and give each feature a
  topic in it; a round of work on a small project is one file. Split into
  several plans when the streams are worked on separately, such as different
  PR stacks or projects at work. Look for an existing plan that fits before
  starting a new one, and keep parked ideas in it as flagged todos.
- `.tada/context/` is yours. Long notes, findings, anything you want a later
  session to know. Write there freely, in whatever form helps you.
- `.tada/archive/` holds finished work. Leave it alone unless you're pointed at it.
- An older project may have a single `Tadafile` at its root. Treat it as a plan.

## The format

```
> Admins can put item photos in the order they want
| &:https://linear.app/acme/project/photo-order
- Admin:
  - Photos:
    | &:.tada/context/photo-order.md
    - [✔] Upload photos
    - [•] Reorder photos
          > Order survives a reload
    - [ ] Remove a photo
    - [⚑] Bulk upload
          > Not now, nobody has asked
- Storefront:
  - [ ] Photos show in the admin's order
```

- A **topic** is `- Title:`. Topics nest up to three deep, two spaces a level.
- A **todo** is `- [ ] text`. Todos are leaves: if one needs children, make it a topic.
- The box holds a status: `[ ]` not started, `[•]` in progress, `[✔]` done,
  `[⚑]` flagged (blocked, dropped, or needing a decision). Some projects use
  other symbols; match the plans already there.
- A **note** is `> text`, hung under the text of the entry it belongs to.
- **Metadata** is `| sigil:value`, on the lines right after its topic's title
  and lined up with the title's text: `&` link, `@` assignees,
  `!` priority, `#` tags, `^` start date, `$` end date. A link can be
  a web address or `path/to/file.rb:42`.
- A plain `- text` is a list item, for things that aren't work to tick off.
- `# text` is a comment.
- A plan may open with one note saying what it's for, and links. That's optional.

## What to write

**Todos say what someone can do when the work is done**, not what you will do
to the code. "Reorder photos" is a todo. "Add position column" is a step, and
steps go stale the moment the approach shifts, which then forces a rewrite of
the plan. Outcomes survive changes of approach, so the plan stays still while
the work moves. If the person asks for steps, or it's their plan and they write
that way, follow them.

**Things to check or find out are not todos either.** "Is vips installed on
the server?" is a question for you to answer, or to write down in
`.tada/context/`; it isn't something a visitor or admin will be able to do.

**Keep steps, when you need them, under the item being worked on now.** Don't
break future items down in advance. Take them out again when the item is done.

**Write the way the person does.** Topics are a noun or two. Todos are a short
phrase, no full sentences, no articles where they aren't needed. Use the real
name of a thing when it's the fastest way to say it.

| Instead of | Write |
|---|---|
| `- Photo Management Functionality:` | `- Photos:` |
| `- [ ] Implement the ability for admin users to reorder photos` | `- [ ] Reorder photos` |
| `- [ ] Add position column to photos table` | (a step; leave it out) |
| `- [ ] Investigate and resolve Turbo link issue` | `- [ ] Item link works without turbo: false` |
| `> We decided against this because it adds complexity and...` | `> No, 3 levels is enough` |

**Notes are rare and one line.** Most todos need none. A note earns its place
when it records a decision or a condition the todo's few words can't carry.

**Record a decision as a flagged todo with its verdict in a note.** That keeps
"we considered this and said no" in the plan, where it stops being suggested again.

**Anything longer goes in `.tada/context/`**, linked from the topic it explains
with `| &:.tada/context/<file>.md`. The person will rarely open it, so it
doesn't need to be written for them.

## How much

There's no fixed length. A useful check: with the second level of topics
folded, could the person see the whole plan without scrolling? If not, it's
likely two plans, or steps have crept in. A handful of topics with a few todos
each is typical; one topic with three todos is a fine plan.

## Working from a plan

- Read the file again before you edit it. The person changes it too.
- Mark a todo `[•]` when you start it and `[✔]` when it's done and verified.
- Add what you discover. Leave the person's wording and ordering as they are.
- If the work shows that an item should change, split, or go, say so and let
  the person decide; that's a change of scope, not housekeeping.
- When you'd reach for a Markdown planning document, write a plan here instead,
  and put the reasoning in `.tada/context/`.
