# mpv Shortcuts

Stock mpv defaults (no custom `input.conf` on this machine) — verified against
`man mpv`. Used via `vsearch` (see nvim-shortcuts.md's Math Notation section's
neighbor, the video-transcript search tool) which launches `mpv --start=<ts>`.

## Playback Speed
| Key            | Action                              |
|----------------|--------------------------------------|
| `[` / `]`      | Slow down / speed up by 10%          |
| `{` / `}`      | Halve / double speed                 |
| `BACKSPACE`    | Reset speed to normal                |

## Seeking
| Key                     | Action                                              |
|--------------------------|-----------------------------------------------------|
| `←` / `→`                | Seek ±5 seconds                                     |
| `Shift+←` / `Shift+→`    | Seek ±1 second (exact)                              |
| `↑` / `↓`                | Seek ±1 minute                                      |
| `Ctrl+←` / `Ctrl+→`      | Jump to previous/next subtitle line                 |
| `Shift+Backspace`        | Undo last seek (press again to go back before that) |
| `HOME`                   | Seek to the beginning of the file                   |

## Playback Control
| Key         | Action                                                      |
|-------------|---------------------------------------------------------------|
| `SPACE`/`p` | Pause / unpause                                              |
| `,` / `.`   | Step one frame back/forward (auto-pauses)                    |
| `l`         | Set A–B loop points — replay one explanation on repeat       |
| `L`         | Toggle infinite loop of the whole file                       |
| `q`         | Quit                                                          |
| `Q`         | Quit and remember position (resumes here next time)           |

## Study Extras
| Key       | Action                                                          |
|-----------|-------------------------------------------------------------------|
| `s`       | Screenshot (e.g. grab a whiteboard/diagram frame)                 |
| `Ctrl+s`  | Screenshot as displayed (with subtitles/OSD, scaled)               |
| `v`       | Toggle caption visibility (`.vtt` captions auto-load as subtitles) |
| `j` / `J` | Cycle through available subtitle tracks                            |
| `9` / `0` | Volume down/up                                                    |
| `m`       | Mute                                                               |
| `f`       | Toggle fullscreen                                                  |
| `o`       | Show progress bar / elapsed / total duration on OSD                |
