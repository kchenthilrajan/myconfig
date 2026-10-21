# sess Shortcuts

Browse/search Claude Code session transcripts (`~/.claude/projects/*/*.jsonl`) and hand
isolated context off to a new session. See `scripts/sess.py` for the implementation;
`resume` lives in `zshrc` (a subprocess can't `cd` its parent shell).

## List sessions
| Command                | Action                                                          |
|-------------------------|------------------------------------------------------------------|
| `sess ls`               | Recent sessions, newest first, numbered `@1`, `@2`…               |
| `sess ls -n 30`         | Show 30 instead of the default 15                                 |
| `sess ls --all`         | Also include history-only entries with no transcript file (cannot be tailed/resumed) |

## Search across all sessions
| Command                                  | Action                                                    |
|--------------------------------------------|--------------------------------------------------------------|
| `sess find kafka partition`                | Sessions where a single turn contains **all** these words   |
| `sess find kafka partition --any`          | ...contains **any** of these words (synonyms, spelling variants) |
| `sess find kafka --who user`               | Only search your own turns, not Claude's                    |
| `sess find kafka -n 20`                    | Show up to 20 matching sessions instead of the default 8    |

## Read one session
| Command                                     | Action                                                     |
|-----------------------------------------------|----------------------------------------------------------------|
| `sess tail @2`                                | Last 6 turns of the 2nd most recent session                    |
| `sess tail 3a09`                              | ...of the session whose id starts with `3a09`                  |
| `sess tail kubernetes`                        | ...of the newest session whose name/project/last prompt matches |
| `sess tail 3a09 -n 15`                        | Show 15 turns instead of the default 6                          |
| `sess tail 3a09 --chars 2000`                 | Up to 2000 chars per turn instead of the default 900             |
| `sess tail 3a09 --match kafka`                | Jump to the turns around the **last** mention of "kafka", not the end |

## Hand off isolated context to a new session
| Command                          | Action                                                              |
|------------------------------------|--------------------------------------------------------------------|
| `sess chop 3a09`                   | List every turn in that session, numbered (pipe into `fz` to browse/search) |
| `sess chop 3a09 12-27`             | Extract turns 12–27 as a seed, print it, **copy to clipboard**      |
| `sess chop 3a09 12-27 --out f.md`  | Write the seed to a file instead of stdout                          |
| `sess chop 3a09 12-27 --no-copy`   | Print only, skip the clipboard copy                                 |

Paste a chopped seed as the opening message of a new session — it's a self-contained
excerpt (source session/project + the turns), no need to re-explain.

## Resume
| Command                | Action                                                                    |
|--------------------------|-------------------------------------------------------------------------|
| `sess resume @2`         | `cd` into that session's project dir, then `claude --resume <exact id>` — skips the generic picker |
| `sess resume 3a09`       | Same, resolved by id prefix                                              |
| `sess resume kubernetes` | Same, resolved by name/project/last-prompt match                         |

## Selector syntax (shared by `tail`, `chop`, `resume`)
| Form         | Meaning                                              |
|--------------|-------------------------------------------------------|
| `@N`         | Nth most recent session (`@1` = newest)                |
| `3a09`       | Session id prefix                                     |
| `kubernetes` | Substring match against name / AI title / project / last prompt |
