#!/usr/bin/env python3
"""
Flip the two sides of a single left/right (vertical) split in the current
tmux window, moving each side's whole pane group -- including any panes
stacked on top of each other within that side -- to the opposite side.

Hardcoded rules:
  1. Only works if exactly one vertical (left/right) split exists in the
     window (i.e. panes fall into exactly two columns, each internally a
     plain top/bottom stack -- no other split shape).
  2. Flips the panes on each side of that split; every pane nested under
     one side moves together with it.
  3. Any other layout shape -> print "flip not supported for this layout"
     and change nothing.
"""
import subprocess
import sys

TARGET = sys.argv[1] if len(sys.argv) > 1 else None


def tmux(*args):
    cmd = ["tmux", *args]
    return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout


def unsupported():
    subprocess.run(["tmux", "display-message", "flip not supported for this layout"])
    sys.exit(0)


def get_panes():
    fmt = "#{pane_id}\t#{pane_left}\t#{pane_top}\t#{pane_width}\t#{pane_height}"
    args = ["list-panes"]
    if TARGET:
        args += ["-t", TARGET]
    args += ["-F", fmt]
    out = tmux(*args)
    result = []
    for line in out.strip().splitlines():
        pid, left, top, w, h = line.split("\t")
        result.append({"id": pid, "left": int(left), "top": int(top), "w": int(w), "h": int(h)})
    return result


def validate_column(col):
    w = col[0]["w"]
    if any(p["w"] != w for p in col):
        unsupported()
    expected_top = col[0]["top"]
    for p in col:
        if p["top"] != expected_top:
            unsupported()
        expected_top = p["top"] + p["h"] + 1


def main():
    ps = get_panes()
    if len(ps) < 2:
        unsupported()

    lefts = sorted(set(p["left"] for p in ps))
    if len(lefts) != 2:
        unsupported()

    col_a = sorted([p for p in ps if p["left"] == lefts[0]], key=lambda p: p["top"])
    col_b = sorted([p for p in ps if p["left"] == lefts[1]], key=lambda p: p["top"])
    validate_column(col_a)
    validate_column(col_b)

    left_ids = [p["id"] for p in col_a]
    right_ids = [p["id"] for p in col_b]

    if len(left_ids) >= len(right_ids):
        big, small = left_ids, right_ids
    else:
        big, small = right_ids, left_ids

    k = len(small)

    # Move the excess panes from the bigger side onto the bottom of the
    # smaller side's stack, one at a time (each join targets the current
    # bottom-most pane, which is always a plain leaf, so this never
    # disturbs the other side's structure).
    anchor = small[-1]
    for pid in big[k:]:
        tmux("join-pane", "-v", "-s", pid, "-t", anchor)
        anchor = pid

    # Swap content for the first k positions between the two physical
    # sides -- pure content exchange, no geometry change.
    for i in range(k):
        tmux("swap-pane", "-s", big[i], "-t", small[i])


if __name__ == "__main__":
    main()
