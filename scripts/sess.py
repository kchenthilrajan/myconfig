#!/usr/bin/env python3
"""sess - list Claude Code sessions and print the tail of one.

Built so a word-hunt in one session can be handed to another without re-explaining:
    sess find kafka partition  which sessions discussed this? (full text, all words in one turn)
    sess ls                    recent sessions, newest first (numbered)
    sess tail 3a09 --match kafka   turns around where "kafka" was said in that session
    sess tail @2               last turns of the 2nd most recent session
    sess tail 3a09             ... of the session whose id starts with 3a09
    sess tail kubernetes       ... of the newest session whose name/project/last prompt matches
    sess chop 3a09             list every turn in that session, numbered (pipe into `fz` to browse)
    sess chop 3a09 12-27       extract turns 12-27 as a seed, print + copy to clipboard —
                                paste as the opening message of a new, isolated-context session
    sess thread 'sudoku|LC ?37' --project interview-company-wise-problems/master --out t.md
                               every matching turn across sessions, verbatim, time-ordered, ±3 turns context

Reads ~/.claude/projects/<project>/<session-id>.jsonl (stdlib only, read-only).
Only human and assistant text is shown; tool calls, tool output and system records are skipped.
"""
import argparse, glob, json, os, re, subprocess, sys
from datetime import datetime

ROOT = os.path.expanduser("~/.claude/projects")
TAG = re.compile(r"<(system-reminder|local-command-[a-z]+|command-[a-z]+)>.*?</\1>", re.S)
SECTION_RE = re.compile(r"^§ Section: (.+)$", re.M)


def records(path):
    with open(path, errors="replace") as f:
        for line in f:
            try:
                yield json.loads(line)
            except ValueError:
                continue


def sessions():
    out = []
    for p in glob.glob(os.path.join(ROOT, "*", "*.jsonl")):
        out.append((os.path.getmtime(p), p))
    return [p for _, p in sorted(out, reverse=True)]


def meta(path):
    """Session id, project, names. Only lines that can carry a title are parsed."""
    m = {"id": os.path.basename(path)[:-6], "project": "",
         "name": "", "title": "", "last": "", "mtime": os.path.getmtime(path), "path": path}
    with open(path, errors="replace") as f:
        for line in f:
            if not m["project"] and '"cwd"' in line:
                try:
                    m["project"] = json.loads(line).get("cwd", "").replace(os.path.expanduser("~"), "~")
                except ValueError:
                    pass
            if '"ai-title"' in line or '"agent-name"' in line or '"last-prompt"' in line:
                try:
                    d = json.loads(line)
                except ValueError:
                    continue
                t = d.get("type")
                if t == "agent-name":
                    m["name"] = d.get("agentName", "")
                elif t == "ai-title":
                    m["title"] = d.get("aiTitle", "")
                elif t == "last-prompt":
                    m["last"] = d.get("lastPrompt", "")
    return m


def label(m):
    return m["name"] or m["title"] or (m["last"][:60] + "..." if m["last"] else "(untitled)")


def resolve(sel):
    """Return (best, others). Selector: @N, id prefix, or substring of name/title/project/last prompt."""
    paths = sessions()
    if re.fullmatch(r"@\d+", sel):
        i = int(sel[1:]) - 1
        if not 0 <= i < len(paths):
            sys.exit(f"sess: only {len(paths)} sessions")
        return meta(paths[i]), []
    hits = [meta(p) for p in paths if os.path.basename(p).startswith(sel)]
    if not hits:
        s = sel.lower()
        for p in paths:
            m = meta(p)
            if s in " ".join((m["name"], m["title"], m["project"], m["last"])).lower():
                hits.append(m)
    if not hits:
        sys.exit(f"sess: nothing matches '{sel}' (try: sess ls)")
    return hits[0], hits[1:6]


def text_of(d):
    """Plain conversational text of a record, or '' if it is tool/system noise."""
    if d.get("isSidechain") or d.get("isMeta"):
        return ""
    c = (d.get("message") or {}).get("content")
    if d.get("type") == "user":
        if isinstance(c, list):
            c = " ".join(b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text")
        return TAG.sub("", c).strip() if isinstance(c, str) else ""
    if d.get("type") == "assistant" and isinstance(c, list):
        return "\n".join(b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text").strip()
    return ""


def is_summary(t):
    """Context-compaction summary: restates the whole earlier chat, so it would match every search."""
    return t.startswith("This session is being continued")


def section_of(t):
    """First `§ Section: <name>` marker in a turn's text, or None. See global
    CLAUDE.md 'Section markers for context handoff' — Claude tags clean topic
    pivots going forward so `chop`/`sections` can suggest boundaries."""
    m = SECTION_RE.search(t)
    return m.group(1).strip() if m else None


def clip(s, n):
    if len(s) <= n:
        return s
    head = int(n * 0.6)
    return s[:head].rstrip() + f"  [... {len(s) - n} chars cut ...]  " + s[-(n - head):].lstrip()


def local(iso):
    """ISO-8601 UTC timestamp -> local 'Mon DD HH:MM'."""
    try:
        return datetime.fromisoformat(iso.replace("Z", "+00:00")).astimezone().strftime("%b %d %H:%M")
    except ValueError:
        return iso[:16]


def history_only(have):
    """Sessions that appear in ~/.claude/history.jsonl but have no transcript file (cannot be resumed or tailed)."""
    rows = {}
    try:
        for d in records(os.path.expanduser("~/.claude/history.jsonl")):
            sid = d.get("sessionId")
            if not sid or sid in have:
                continue
            r = rows.setdefault(sid, {"id": sid, "project": d.get("project", "").replace(os.path.expanduser("~"), "~"),
                                      "ts": 0, "first": ""})
            r["ts"] = max(r["ts"], d.get("timestamp", 0) / 1000)
            text = d.get("display", "").strip()
            if not r["first"] and text and not text.startswith("/"):
                r["first"] = text.replace("\n", " ")
    except OSError:
        pass
    return list(rows.values())


def cmd_ls(a):
    paths = sessions()
    rows = [(os.path.getmtime(p), f"@{i}", None, p) for i, p in enumerate(paths, 1)]
    if a.all:
        have = {os.path.basename(p)[:-6] for p in paths}
        rows += [(h["ts"], "-", h, None) for h in history_only(have)]
        rows.sort(key=lambda r: r[0], reverse=True)
    for ts, tag, h, p in rows[: None if a.all else a.n]:
        when = datetime.fromtimestamp(ts).strftime("%b %d %H:%M")
        if p:
            m = meta(p)
            print(f"{tag:<4} {when}  {m['id']}  {m['project'][:28]:28}  {label(m)[:45]}")
        else:
            print(f"{tag:<4} {when}  {h['id']}  {h['project'][:28]:28}  [prompt only] {h['first'][:32]}")
    if a.all:
        print("\n# '-' rows have no transcript: they cannot be tailed or resumed, only recognised by their first prompt.")


def snippet(t, term, w=90):
    i = max(t.lower().find(term), 0)
    s = max(0, i - w)
    return ("..." if s else "") + " ".join(t[s:i + len(term) + w].split()) + "..."


def cmd_find(a):
    """Full-text search of what was said (not titles). All terms must appear in the same turn."""
    terms = [t.lower() for t in a.terms]
    agg = any if a.any else all
    found = []
    for p in sessions():
        hits = []
        with open(p, errors="replace") as f:
            for line in f:
                if not agg(t in line.lower() for t in terms):  # cheap prefilter before parsing JSON
                    continue
                try:
                    d = json.loads(line)
                except ValueError:
                    continue
                t = text_of(d)
                if t and not is_summary(t) and agg(x in t.lower() for x in terms) and a.who in ("any", d["type"]):
                    hits.append((d.get("timestamp", ""), d["type"], t))
        if hits:
            found.append((max(h[0] for h in hits), p, hits))
    found.sort(reverse=True)
    if not found:
        sys.exit(f"sess: no turn contains {'any' if a.any else 'all'} of {a.terms}")
    for _, p, hits in found[: a.n]:
        m = meta(p)
        print(f"\n{m['id'][:8]}  {m['project'][:34]}  {label(m)[:50]}  ({len(hits)} hits)")
        for ts, role, t in sorted(hits, reverse=True)[:2]:
            print(f"   {'YOU' if role == 'user' else 'CLAUDE':6} {local(ts)}  {snippet(t, next((x for x in terms if x in t.lower()), terms[0]))}")
    print(f"\n# {len(found)} sessions match. Open one:  sess tail <id> --match \"{a.terms[0]}\"")


def cmd_tail(a):
    m, others = resolve(a.session)
    turns = []
    for d in records(m["path"]):
        t = text_of(d)
        if t:
            turns.append((d["type"], d.get("timestamp", ""), t))
    if a.match:
        idx = [i for i, (_, _, t) in enumerate(turns) if a.match.lower() in t.lower() and not is_summary(t)]
        if not idx:
            sys.exit(f"sess: '{a.match}' not found in this session's text")
        lo = max(0, idx[-1] - 1)
        shown, mode = turns[lo:lo + a.n], f"showing {a.n} turns from just before the last match of '{a.match}'"
    else:
        shown, mode = turns[-a.n:], f"showing last {min(a.n, len(turns))}"
    when = datetime.fromtimestamp(m["mtime"]).strftime("%b %d %H:%M")
    print(f"# {label(m)}\n# {m['project']}  id={m['id']}  last activity {when}  ({len(turns)} text turns; {mode})")
    if others:
        print("# also matched: " + "; ".join(f"{o['id'][:8]} {label(o)[:40]}" for o in others))
    for role, ts, t in shown:
        who = "YOU" if role == "user" else "CLAUDE"
        print(f"\n--- {who} {local(ts)} ---\n{clip(t, a.chars)}")


def cmd_resolve(a):
    """Internal: print PROJECT_PATH<TAB>SESSION_ID for a selector. Used by the
    `sess resume` shell wrapper (a subprocess can't cd its parent shell, so the
    zsh function does the cd; this just resolves what to cd to and resume)."""
    m, _ = resolve(a.session)
    print(f"{os.path.expanduser(m['project'])}\t{m['id']}")


def cmd_sections(a):
    """Table of contents: list only the `§ Section:` markers in a session, in
    order, with their turn index — so you can pick clean chop boundaries
    without scanning the full turn list."""
    m, _ = resolve(a.session)
    turns = []
    for d in records(m["path"]):
        t = text_of(d)
        if t and not is_summary(t):
            turns.append((d["type"], d.get("timestamp", ""), t))
    found = [(i, ts, section_of(t)) for i, (_, ts, t) in enumerate(turns, 1) if section_of(t)]
    if not found:
        print(f"# No section markers in {label(m)} ({len(turns)} turns).")
        print("# Markers are only added going forward (see global CLAUDE.md) — nothing to retrofit here.")
        return
    print(f"# {label(m)}  ({len(found)} sections, {len(turns)} turns total)")
    for i, ts, sec in found:
        print(f"{i:>4}  {local(ts)}  {sec}")
    print(f"\n# Chop between two of these:  sess chop {a.session} <start>-<end>")


def cmd_chop(a):
    """No range: list every turn, numbered (pipe into `fz` to browse/search it).
    With a range (START-END, 1-based, inclusive): extract just those turns,
    format as a self-contained seed, print it, and copy it to the clipboard —
    paste as the opening message of a new session to hand off isolated context."""
    m, others = resolve(a.session)
    turns = []
    for d in records(m["path"]):
        t = text_of(d)
        if t and not is_summary(t):
            turns.append((d["type"], d.get("timestamp", ""), t))

    if not a.range:
        print(f"# {label(m)}  ({m['project']}, id={m['id']})  {len(turns)} turns")
        for i, (role, ts, t) in enumerate(turns, 1):
            who = "YOU" if role == "user" else "CLAUDE"
            sec = section_of(t)
            if sec:
                print(f"{i:>4}  {who:<6} {local(ts)}  ▶ SECTION: {sec}")
            else:
                preview = " ".join(t.split())[:90]
                print(f"{i:>4}  {who:<6} {local(ts)}  {preview}")
        print(f"\n# Pick a range:  sess chop {a.session} <start>-<end>          (or: sess chop {a.session} | fz)")
        print(f"# Or see just the section markers:  sess sections {a.session}")
        return

    mo = re.fullmatch(r"(\d+)-(\d+)", a.range)
    if not mo:
        sys.exit("sess: range must look like START-END, e.g. 12-27")
    lo, hi = int(mo.group(1)), int(mo.group(2))
    if not (1 <= lo <= hi <= len(turns)):
        sys.exit(f"sess: range out of bounds (1-{len(turns)})")

    chunk = turns[lo - 1:hi]
    lines = [
        f"# Context handed off from a Claude Code session: {label(m)}",
        f"# Project: {m['project']}  |  session id: {m['id']}  |  turns {lo}-{hi} of {len(turns)}",
        f"# Extracted {datetime.now().strftime('%b %d %H:%M')}",
        "",
    ]
    for role, ts, t in chunk:
        who = "YOU" if role == "user" else "CLAUDE"
        lines.append(f"--- {who} {local(ts)} ---")
        lines.append(t)
        lines.append("")
    out = "\n".join(lines)

    if a.out:
        with open(a.out, "w") as f:
            f.write(out)
        print(f"# Written to {a.out}")
    else:
        print(out)

    if not a.no_copy:
        try:
            copier = ["pbcopy"] if sys.platform == "darwin" else ["xclip", "-selection", "clipboard"]
            subprocess.run(copier, input=out.encode(), check=True)
            print(f"\n# Copied {hi - lo + 1} turns to clipboard — paste as the opening message of a new session.", file=sys.stderr)
        except (OSError, subprocess.CalledProcessError):
            pass


def session_turns(path):
    """Text turns of one session, numbered exactly like `sess chop` (1-based, summaries skipped).
    Each turn: (n, role, ts, text, uuid, images)."""
    out = []
    for d in records(path):
        t = text_of(d)
        if not t or is_summary(t):
            continue
        c = (d.get("message") or {}).get("content")
        imgs = sum(1 for b in c if isinstance(b, dict) and b.get("type") == "image") if isinstance(c, list) else 0
        out.append((len(out) + 1, d["type"], d.get("timestamp", ""), t, d.get("uuid", ""), imgs))
    return out


def cmd_thread(a):
    """Every turn matching a pattern, across sessions, VERBATIM and in time order, with context.
    Locates and slices only: nothing is summarized, and the table of contents is the first
    line of YOUR turns, so no framing is added on top of the conversation."""
    rx = re.compile(a.pattern, re.I)
    paths = [p for p in sessions() if not a.project or a.project.lower() in meta(p)["project"].lower()]
    if a.session:
        paths = [p for p in paths if any(os.path.basename(p).startswith(s) for s in a.session)]
    if not paths:
        sys.exit("sess: no sessions match --project/--session")
    seen, dup, blocks, info = set(), 0, [], []
    loaded = [(p, session_turns(p)) for p in paths]
    # oldest session first: a continued/resumed session replays earlier turns with the same
    # uuid, and the turn must stay with the session where it was originally said
    loaded.sort(key=lambda x: x[1][0][2] if x[1] else "")
    for p, turns in loaded:
        m = meta(p)
        keep = []
        for tr in turns:  # resumed sessions can replay earlier turns; keep each message once
            if tr[4] and tr[4] in seen:
                dup += 1
                continue
            seen.add(tr[4])
            keep.append(tr)
        hits = {i for i, tr in enumerate(keep) if (a.who in ("any", tr[1])) and rx.search(tr[3])}
        if not hits:
            continue
        info.append((m, keep, len(hits)))
        want = sorted({j for i in hits for j in range(i - a.context, i + a.context + 1) if 0 <= j < len(keep)})
        run = [want[0]]
        for j in want[1:]:  # contiguous runs of wanted turns become blocks
            if j == run[-1] + 1:
                run.append(j)
            else:
                blocks.append((m, keep, run, hits)); run = [j]
        blocks.append((m, keep, run, hits))
    if not blocks:
        sys.exit(f"sess: no turn matches /{a.pattern}/ in {len(paths)} sessions")
    blocks.sort(key=lambda b: b[1][b[2][0]][2])  # by timestamp of the block's first turn

    L = [f"# THREAD /{a.pattern}/",
         "",
         f"- Query: regex `{a.pattern}` (case-insensitive) · context ±{a.context} turns · who: {a.who}"
         + (f" · project contains `{a.project}`" if a.project else ""),
         f"- Generated {datetime.now().strftime('%Y-%m-%d %H:%M')} by `sess thread`. Turns are VERBATIM text_of() output "
         "(tool calls/output, system tags and continuation summaries removed; nothing summarized or reworded).",
         f"- Turn numbers match `sess chop <session>`. ● = matched the query, ○ = context."
         + (f" {dup} replayed duplicate turns skipped." if dup else ""),
         "- Sessions (in time order):"]
    for m, keep, nh in sorted(info, key=lambda x: x[1][0][2]):
        L.append(f"  - `{m['id'][:8]}` {m['project']} · {local(keep[0][2])} → {local(keep[-1][2])} · {nh} matching turns of {len(keep)}")
    L += ["", "## Your turns (first line, verbatim)", ""]
    for m, keep, run, hits in blocks:
        for j in run:
            n, role, ts, t, _, _ = keep[j]
            if role == "user":
                first = next((ln.strip() for ln in t.splitlines() if ln.strip()), "")
                L.append(f"- {'●' if j in hits else '○'} {local(ts)} · `{m['id'][:8]}:t{n}` — {first[:160]}")
    L += ["", "---", ""]
    prev = {}
    for m, keep, run, hits in blocks:
        sid = m["id"]
        last = prev.get(sid)
        start_n, end_n = keep[run[0]][0], keep[run[-1]][0]
        if last is not None and start_n > last + 1:
            L.append(f"> … {start_n - last - 1} turns of `{sid[:8]}` not shown (t{last + 1}–t{start_n - 1}) — `sess chop {sid[:8]} {last + 1}-{start_n - 1}`\n")
        elif last is None and start_n > 1:
            L.append(f"> … `{sid[:8]}` t1–t{start_n - 1} not shown\n")
        L.append(f"## `{sid[:8]}` · {local(keep[run[0]][2])} · t{start_n}–t{end_n}\n")
        for j in run:
            n, role, ts, t, uuid, imgs = keep[j]
            who = "YOU" if role == "user" else "CLAUDE"
            mark = "●" if j in hits else "○"
            img = f" · (+{imgs} image{'s' if imgs > 1 else ''} not shown)" if imgs else ""
            L.append(f"### {mark} {who} · {local(ts)} · `{sid[:8]}:t{n}`{img}\n<!-- uuid:{uuid} -->\n")
            L.append(t)
            L.append("")
        prev[sid] = end_n
    out = "\n".join(L) + "\n"
    if a.out:
        os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
        with open(a.out, "w") as f:
            f.write(out)
        nturns = sum(len(b[2]) for b in blocks)
        print(f"# {sum(x[2] for x in info)} matching turns, {nturns} turns shown in {len(blocks)} blocks "
              f"from {len(info)} sessions → {a.out}")
    else:
        print(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    l = sub.add_parser("ls"); l.add_argument("-n", type=int, default=15)
    l.add_argument("--all", action="store_true", help="every session, incl. history-only ones with no transcript")
    l.set_defaults(f=cmd_ls)
    t = sub.add_parser("tail"); t.add_argument("session", help="@N, id prefix, or name/project text")
    t.add_argument("-n", type=int, default=6, help="turns to show (default 6)")
    t.add_argument("--chars", type=int, default=900, help="max chars per turn (default 900)")
    t.add_argument("--match", help="show the turns around the last turn containing this text, instead of the end")
    t.set_defaults(f=cmd_tail)
    f = sub.add_parser("find", help="full-text search across all sessions")
    f.add_argument("terms", nargs="+", help="words that must all appear in one turn")
    f.add_argument("-n", type=int, default=8, help="sessions to show (default 8)")
    f.add_argument("--who", choices=["any", "user", "assistant"], default="any", help="whose turns to search")
    f.add_argument("--any", action="store_true", help="match a turn containing ANY term (for synonyms and spelling variants)")
    f.set_defaults(f=cmd_find)
    c = sub.add_parser("chop", help="extract a turn range as a self-contained seed for a new session")
    c.add_argument("session", help="@N, id prefix, or name/project text")
    c.add_argument("range", nargs="?", help="START-END turn numbers (1-based, inclusive); omit to list all turns, numbered")
    c.add_argument("--out", help="write to this file instead of stdout")
    c.add_argument("--no-copy", action="store_true", help="don't copy the extracted range to the clipboard")
    c.set_defaults(f=cmd_chop)
    r = sub.add_parser("resolve", help="internal: print PROJECT_PATH<TAB>ID for a selector (used by the `sess resume` shell wrapper)")
    r.add_argument("session", help="@N, id prefix, or name/project text")
    r.set_defaults(f=cmd_resolve)
    s = sub.add_parser("sections", help="table of contents: list only the § Section markers in a session")
    s.add_argument("session", help="@N, id prefix, or name/project text")
    s.set_defaults(f=cmd_sections)
    th = sub.add_parser("thread", help="every matching turn across sessions, verbatim, in time order, with context")
    th.add_argument("pattern", help="regex, case-insensitive, e.g. 'sudoku|LC ?37|isValid'")
    th.add_argument("--project", help="only sessions whose project path contains this text")
    th.add_argument("--session", nargs="+", help="only these session id prefixes")
    th.add_argument("--context", type=int, default=3, help="turns shown before/after each match (default 3)")
    th.add_argument("--who", choices=["any", "user", "assistant"], default="any", help="whose turns can match")
    th.add_argument("--out", help="write to this file instead of stdout")
    th.set_defaults(f=cmd_thread)
    a = ap.parse_args(); a.f(a)


if __name__ == "__main__":
    main()
