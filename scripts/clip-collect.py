#!/usr/bin/env python3
"""clip-collect - append several clipboard copies into one, then paste them all at once.

    clip-collect start [--sep TEXT] [--include-current]
                          start watching: every NEW copy (⌘C anywhere) is appended to a buffer
    clip-collect show     print what has been collected so far (numbered)
    clip-collect stop     stop watching; put all pieces on the clipboard, joined → one ⌘V pastes all
    clip-collect status   is it running, how many pieces
    clip-collect clear    discard the collected pieces (keeps watching if running)

A background watcher polls the clipboard twice a second. A copy identical to the previous piece
is skipped. What was already on the clipboard at `start` is not included unless --include-current.
Separator defaults to a blank line between pieces (--sep '---' for a rule, --sep '' for none).
macOS uses pbcopy/pbpaste; Linux uses xclip. State lives in ~/.cache/clip-collect/.
"""
import argparse
import json
import os
import signal
import subprocess
import sys
import time

STATE = os.path.expanduser(os.environ.get("CLIP_COLLECT_DIR", "~/.cache/clip-collect"))
PIECES, PIDF, CONF = (os.path.join(STATE, n) for n in ("pieces.jsonl", "watcher.pid", "conf.json"))
# testing hook: a plain file stands in for the system clipboard, so tests never touch the real one
FAKE = os.environ.get("CLIP_COLLECT_FAKE_CLIPBOARD")
ENV = {**os.environ, "LANG": os.environ.get("LANG") or "en_US.UTF-8"}  # pbcopy/pbpaste need a UTF-8 locale


def clip_get():
    if FAKE:
        try:
            return open(FAKE, encoding="utf-8").read()
        except OSError:
            return ""
    cmd = ["pbpaste"] if sys.platform == "darwin" else ["xclip", "-o", "-selection", "clipboard"]
    r = subprocess.run(cmd, capture_output=True, env=ENV)
    return r.stdout.decode("utf-8", "replace") if r.returncode == 0 else ""


def clip_set(text):
    if FAKE:
        open(FAKE, "w", encoding="utf-8").write(text)
        return
    cmd = ["pbcopy"] if sys.platform == "darwin" else ["xclip", "-selection", "clipboard"]
    subprocess.run(cmd, input=text.encode("utf-8"), env=ENV, check=True)


def pieces():
    try:
        return [json.loads(l) for l in open(PIECES, encoding="utf-8") if l.strip()]
    except OSError:
        return []


def running_pid():
    try:
        pid = int(open(PIDF).read().strip())
        os.kill(pid, 0)
        return pid
    except (OSError, ValueError):
        return None


def watch(interval):
    """Background loop: append every new clipboard value."""
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    conf = json.load(open(CONF))
    # baseline was captured by `start` BEFORE this process launched, so a copy made while the
    # watcher is still starting up counts as new (it differs from the baseline)
    last = conf.get("baseline", "")
    if conf.get("include_current") and last.strip():
        append(last)
    while True:
        cur = clip_get()
        if cur != last:
            last = cur
            if cur.strip():
                append(cur)
        time.sleep(interval)


def append(text):
    ps = pieces()
    if ps and ps[-1] == text:         # same thing copied twice in a row → keep once
        return
    with open(PIECES, "a", encoding="utf-8") as f:
        f.write(json.dumps(text, ensure_ascii=False) + "\n")


def cmd_start(a):
    os.makedirs(STATE, exist_ok=True)
    if running_pid():
        print(f"clip-collect: already running ({len(pieces())} pieces so far) — `clip-collect stop` to finish")
        return
    open(PIECES, "w").close()
    json.dump({"sep": a.sep, "include_current": a.include_current, "baseline": clip_get()}, open(CONF, "w"))
    p = subprocess.Popen([sys.executable, os.path.abspath(__file__), "_watch", str(a.interval)],
                         stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                         start_new_session=True, env=os.environ)
    open(PIDF, "w").write(str(p.pid))
    print("clip-collect: collecting — copy (⌘C) as many things as you like, then `clip-collect stop`")


def joined():
    sep = json.load(open(CONF)).get("sep", "\n\n") if os.path.exists(CONF) else "\n\n"
    sep = sep.replace("\\n", "\n")
    if sep and sep.strip() and not sep.startswith("\n"):
        sep = "\n" + sep + "\n"           # a rule like '---' sits on its own line
    return sep.join(p.rstrip("\n") for p in pieces())


def cmd_stop(a):
    pid = running_pid()
    if pid:
        os.kill(pid, signal.SIGTERM)
        for _ in range(20):
            if not running_pid():
                break
            time.sleep(0.05)
    try:
        os.remove(PIDF)
    except OSError:
        pass
    ps = pieces()
    if not ps:
        print("clip-collect: nothing collected" + ("" if pid else " (it wasn't running)"))
        return
    text = joined()
    clip_set(text)
    print(f"clip-collect: {len(ps)} piece(s), {len(text)} chars → on the clipboard. ⌘V to paste them all.")


def cmd_show(a):
    ps = pieces()
    if not ps:
        print("clip-collect: nothing collected yet")
    for i, p in enumerate(ps, 1):
        print(f"── {i} ──\n{p.rstrip()}")


def cmd_status(a):
    pid = running_pid()
    print(f"clip-collect: {'collecting (pid ' + str(pid) + ')' if pid else 'not running'}, {len(pieces())} piece(s)")


def cmd_clear(a):
    if os.path.exists(PIECES):
        open(PIECES, "w").close()
    print("clip-collect: cleared")


def main():
    if len(sys.argv) > 2 and sys.argv[1] == "_watch":
        return watch(float(sys.argv[2]))
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("start", help="start collecting new clipboard copies")
    s.add_argument("--sep", default="\n\n", help="text between pieces (default: blank line)")
    s.add_argument("--include-current", action="store_true", help="also keep what is on the clipboard now")
    s.add_argument("--interval", type=float, default=0.5, help=argparse.SUPPRESS)
    s.set_defaults(f=cmd_start)
    for name, fn, h in (("stop", cmd_stop, "stop and put everything on the clipboard"),
                        ("show", cmd_show, "print collected pieces"),
                        ("status", cmd_status, "running? how many pieces"),
                        ("clear", cmd_clear, "discard collected pieces")):
        sub.add_parser(name, help=h).set_defaults(f=fn)
    argv = sys.argv[1:]
    if "--sep" in argv and argv.index("--sep") + 1 < len(argv):   # let --sep '---' (dash-leading) through
        i = argv.index("--sep")
        argv[i:i + 2] = ["--sep=" + argv[i + 1]]
    a = ap.parse_args(argv)
    a.f(a)


if __name__ == "__main__":
    main()
