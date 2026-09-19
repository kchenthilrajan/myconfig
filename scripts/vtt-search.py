#!/usr/bin/env python3
"""Search across YouTube-style auto-caption .vtt files and print timestamped matches.

YouTube's auto-generated .vtt uses a "rolling caption" format: each cue repeats
the previous cue's text plus one new word/phrase, with per-word inline timing
tags. This collapses that into one clean, deduplicated line per new phrase.

Multiple space-separated terms are AND-ed as a PROXIMITY search, not a same-line
match: each deduped line is only ~1-2 seconds of speech, so two concepts almost
never land in the exact same line. Instead, a line matches if it contains at
least one search term AND every other term also appears somewhere within
WINDOW_SECONDS of it — i.e. "the same stretch of discussion", not "the same
sentence". Quote a phrase to search it as one term.

Usage:
  vtt-search.py search  <directory> <query>            list matches (tab-separated:
                                                          video_basename \t HH:MM:SS \t text)
  vtt-search.py context <directory> <video_basename> <HH:MM:SS>   print surrounding lines
"""
import glob
import os
import re
import sys

CUE_TIME_RE = re.compile(r'^(\d{2}:\d{2}:\d{2})\.\d{3} --> ')
INLINE_TAG_RE = re.compile(r'<[^>]+>')
CONTEXT_LINES = 6
WINDOW_SECONDS = 20  # how close together multiple search terms must occur


def parse_vtt(path):
    """Return [(timestamp_str, text), ...] for each genuinely new line of dialogue."""
    with open(path, encoding='utf-8', errors='replace') as f:
        lines = f.read().splitlines()

    entries = []
    i = 0
    cur_ts = None
    while i < len(lines):
        line = lines[i]
        m = CUE_TIME_RE.match(line)
        if m:
            cur_ts = m.group(1)
            i += 1
            continue
        text = INLINE_TAG_RE.sub('', line).strip()
        if text and cur_ts:
            entries.append((cur_ts, text))
        i += 1

    deduped = []
    last_text = None
    for ts, text in entries:
        if text == last_text:
            continue
        deduped.append((ts, text))
        last_text = text
    return deduped


def ts_to_seconds(ts):
    h, m, s = ts.split(':')
    return int(h) * 3600 + int(m) * 60 + int(s)


def find_vtt_for_base(directory, base):
    for path in glob.glob(os.path.join(directory, '**', f'{base}.*vtt'), recursive=True):
        return path
    return None


def parse_terms(query):
    terms = [t.strip('"') for t in re.findall(r'"[^"]+"|\S+', query)]
    return [t.lower() for t in terms]


def find_proximity_matches(entries, terms):
    """Return indices where entries[i] contains a term AND every term appears
    somewhere within WINDOW_SECONDS of entries[i], collapsing nearby hits."""
    secs = [ts_to_seconds(ts) for ts, _ in entries]
    texts_lower = [text.lower() for _, text in entries]
    n = len(entries)

    matches = []
    left = 0
    right = 0
    for i in range(n):
        while left < n and secs[left] < secs[i] - WINDOW_SECONDS:
            left += 1
        while right < n and secs[right] <= secs[i] + WINDOW_SECONDS:
            right += 1

        if not any(t in texts_lower[i] for t in terms):
            continue

        window_text = ' '.join(texts_lower[left:right])
        if all(t in window_text for t in terms):
            matches.append(i)

    # collapse matches that fall within WINDOW_SECONDS of the previous kept one
    collapsed = []
    for i in matches:
        if collapsed and secs[i] - secs[collapsed[-1]] < WINDOW_SECONDS:
            continue
        collapsed.append(i)
    return collapsed


def cmd_search(directory, query):
    terms = parse_terms(query)

    for path in sorted(glob.glob(os.path.join(directory, '**', '*.vtt'), recursive=True)):
        base = os.path.basename(path)
        base = re.sub(r'\.[a-z]{2,3}\.vtt$', '', base)  # strip ".en.vtt"
        entries = parse_vtt(path)

        if len(terms) == 1:
            for ts, text in entries:
                if terms[0] in text.lower():
                    print(f'{base}\t{ts}\t{text}')
        else:
            for i in find_proximity_matches(entries, terms):
                ts, text = entries[i]
                print(f'{base}\t{ts}\t{text}')


def cmd_context(directory, base, target_ts):
    path = find_vtt_for_base(directory, base)
    if not path:
        print(f'(no caption file found for {base})')
        return
    entries = parse_vtt(path)
    idx = next((i for i, (ts, _) in enumerate(entries) if ts == target_ts), None)
    if idx is None:
        print('(timestamp not found)')
        return
    lo = max(0, idx - CONTEXT_LINES)
    hi = min(len(entries), idx + CONTEXT_LINES + 1)
    for i in range(lo, hi):
        ts, text = entries[i]
        marker = '>>' if i == idx else '  '
        print(f'{marker} [{ts}] {text}')


def main():
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    mode = sys.argv[1]
    if mode == 'search' and len(sys.argv) == 4:
        cmd_search(sys.argv[2], sys.argv[3])
    elif mode == 'context' and len(sys.argv) == 5:
        cmd_context(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        print(__doc__, file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
