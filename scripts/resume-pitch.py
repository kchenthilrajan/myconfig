#!/usr/bin/env python3
"""resume-pitch - write pitch_<slug>.txt for a JD + the tailored resume that was sent for it.

Follows one fixed method for every company:
  1. Pull the JD's concrete problems ("what you'll do" / "problems you'll tackle").
  2. Match each one to a resume bullet.
  3. Write the intro from the top 2 matches.
  4. Write "why leaving" as forward-looking.
  5. Write "why us" as their problem -> your matching experience.

An LLM (`claude -p`, no tools) does the reading and writing; this script keeps it honest:
  - resume bullets are numbered (E1.B3); the model answers with IDs and the script pastes the
    bullet's EXACT text, so the model can't reword your experience
  - every JD problem must be a verbatim quote from the JD (checked)
  - any number in the prose that isn't in the resume or the JD is flagged (invented metrics)
  - unmatched problems are reported as gaps, not forced onto a bullet
Style: the "rules" section of ~/experience-narrative/bullets/voice-rewrite.md, if present.

usage: resume-pitch.py TAILORED_JSON JD_TXT [-o pitch.txt] [--model MODEL]
       (resume-pull runs it automatically; set RESUME_PULL_NO_PITCH=1 to skip)
"""
import argparse
import json
import os
import re
import subprocess
import sys

VOICE = os.path.expanduser("~/experience-narrative/bullets/voice-rewrite.md")
# The candidate's own answer to "why leaving" — pasted VERBATIM into every pitch; the model only
# adds a one-sentence tie-in to the JD. Missing file → the model writes a forward-looking answer.
WHY_LEAVING = os.path.expanduser(os.environ.get("RESUME_PITCH_WHY_LEAVING", "~/resume/why_leaving.txt"))

STEP4_FIXED = """4. "why_leaving" is FIXED - the candidate's own words, pasted by the script (do NOT rewrite it):
   "{text}"
   Return "why_leaving_tiein": ONE sentence (max 30 words) linking that reason to this JD's concrete
   problems (e.g. what they are building that is still at the build-and-ship stage). Add NO new facts
   about the candidate or their employer."""
STEP4_FREE = """4. Write "why_leaving" (2-3 sentences) FORWARD-LOOKING: what the candidate wants to do next and why
   this role fits. State NO facts about the current employer or the reason for leaving."""


def numbered_resume(resume):
    """[(id, company, title, text)] for every bullet, plus the summary as S0."""
    out = []
    if resume.get("personal", {}).get("summary"):
        out.append(("S0", "", "summary", resume["personal"]["summary"]))
    for e, exp in enumerate(resume.get("experience", []), 1):
        for b, text in enumerate(exp.get("bullets", []), 1):
            out.append((f"E{e}.B{b}", exp.get("company", ""), exp.get("title", ""), text))
    return out


def voice_rules():
    try:
        t = open(VOICE, encoding="utf-8").read()
    except OSError:
        return ""
    m = re.search(r"^## The rules.*?(?=^## )", t, re.S | re.M)
    return m.group(0).strip() if m else ""


PROMPT = """You are preparing a candidate's interview pitch. Use ONLY the JD and the resume below.
Follow this method exactly:
1. Pull the JD's concrete problems (from "what you'll do" / "problems you'll tackle" style sections).
   Each problem's "jd_quote" MUST be copied verbatim from the JD (a phrase or sentence, max ~25 words).
   Take the 4-7 most concrete ones; skip generic culture/values lines.
2. Match each problem to the single best resume bullet by its ID (e.g. "E1.B3"). If nothing in the
   resume genuinely matches, use null - do NOT force a match.
3. Write "intro" (60-90 words, first person, spoken) from the TOP 2 matches only.
{step4}
5. Write "why_us" (3-5 sentences): each sentence = one of THEIR problems -> the candidate's matching
   experience (from a matched bullet).
Rules: never invent experience, employers, tools or numbers; only use numbers that appear in the
resume or JD. Write in the candidate's voice per the style rules (plain verbs, concrete nouns,
no intensifiers, no "spearheaded/leveraged/orchestrated").

Return ONLY a JSON object, no prose, no code fence:
{"company": str, "role": str,
 "problems": [{"jd_quote": str, "bullet_id": str|null, "why": str (one short line: the overlap)}],
 "top2": [bullet_id, bullet_id],
 "intro": str, "why_leaving": str (only if step 4 asks for it), "why_leaving_tiein": str (only if
 step 4 asks for it), "why_us": str}

STYLE RULES:
{voice}

JD:
<<<
{jd}
>>>

RESUME (as sent for this role; bullet IDs in brackets):
<<<
{resume}
>>>
"""


def ask_llm(prompt, model):
    cmd = ["claude", "-p", "--tools", "", "--output-format", "json"]
    if model:
        cmd += ["--model", model]
    r = subprocess.run(cmd, input=prompt, capture_output=True, text=True, timeout=600)
    if r.returncode != 0:
        sys.exit(f"resume-pitch: claude -p failed: {r.stderr.strip()[:300]}")
    text = json.loads(r.stdout).get("result", "")
    m = re.search(r"\{.*\}", text, re.S)
    if not m:
        sys.exit(f"resume-pitch: no JSON in model output:\n{text[:500]}")
    return json.loads(m.group(0))


def norm(s):
    return re.sub(r"\s+", " ", s.replace("’", "'").replace("“", '"').replace("”", '"')).strip().lower()


def numbers(s):
    return set(re.findall(r"\d[\d,.]*\+?%?", s))


def render(p, by_id, jd, resume_text, fixed_why=None):
    issues = []
    jdn = norm(jd)
    lines = [f"PITCH — {p.get('role', '')} @ {p.get('company', '')}", "=" * 72, "",
             "1. THEIR PROBLEMS → YOUR BULLETS", ""]
    gaps = 0
    for k, pr in enumerate(p.get("problems", []), 1):
        q = pr.get("jd_quote", "").strip()
        ok = norm(q) in jdn
        if not ok:
            issues.append(f"problem {k}: quote not found verbatim in the JD")
        lines.append(f"  {k}. JD: \"{q}\"" + ("" if ok else "   [! not verbatim in JD]"))
        bid = pr.get("bullet_id")
        if bid and bid in by_id:
            _, company, title, text = by_id[bid]
            where = f"{company} — {title}" if company else title
            lines.append(f"     YOU [{bid}, {where}]: {text}")
            lines.append(f"     overlap: {pr.get('why', '')}")
        else:
            gaps += 1
            if bid:
                issues.append(f"problem {k}: bullet id {bid} does not exist")
            lines.append("     YOU: — no direct match in this resume (a gap to prepare for) —")
        lines.append("")
    top2 = [b for b in p.get("top2", []) if b in by_id]
    lines += ["2. INTRO  (from your top 2 matches: " + ", ".join(top2) + ")", "", "  " + p.get("intro", ""), ""]
    if fixed_why:
        tiein = p.get("why_leaving_tiein", "").strip()
        lines += ["3. WHY LEAVING  (your words, verbatim from why_leaving.txt + a tie-in for this role)", "",
                  "  " + fixed_why, ""] + ([f"  For {p.get('company', 'this team')}: {tiein}", ""] if tiein else [])
        if not tiein:
            issues.append("no tie-in sentence for why leaving (your text is still there)")
    else:
        lines += ["3. WHY LEAVING  (forward-looking — add ~/resume/why_leaving.txt to use your own words)", "",
                  "  " + p.get("why_leaving", ""), ""]
    lines += ["4. WHY US  (their problem → your experience)", "", "  " + p.get("why_us", ""), ""]
    prose = " ".join(p.get(k, "") for k in ("intro", "why_leaving", "why_leaving_tiein", "why_us"))
    unknown = sorted(n for n in numbers(prose) if n not in resume_text and n not in jd)
    if unknown:
        issues.append("numbers in the prose that are NOT in the resume or JD: " + ", ".join(unknown))
    if len(top2) < 2:
        issues.append("intro is not backed by 2 valid matched bullets")
    lines += ["-" * 72, "CHECKS",
              f"  JD quotes verbatim: {sum(1 for pr in p.get('problems', []) if norm(pr.get('jd_quote', '')) in jdn)}"
              f"/{len(p.get('problems', []))} · bullets pasted verbatim from the resume · gaps: {gaps}",
              *(["  ✓ no issues"] if not issues else [f"  ! {i}" for i in issues])]
    return "\n".join(lines) + "\n", issues


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("tailored_json")
    ap.add_argument("jd_txt")
    ap.add_argument("-o", "--out")
    ap.add_argument("--model", default=os.environ.get("RESUME_PITCH_MODEL"))
    a = ap.parse_args()
    resume = json.load(open(a.tailored_json, encoding="utf-8"))
    jd = open(a.jd_txt, encoding="utf-8").read()
    bullets = numbered_resume(resume)
    by_id = {b[0]: b for b in bullets}
    resume_block = "\n".join(f"[{i}] ({c} — {t}) {x}" if c else f"[{i}] (summary) {x}" for i, c, t, x in bullets)
    try:
        fixed_why = " ".join(open(WHY_LEAVING, encoding="utf-8").read().split()) or None
    except OSError:
        fixed_why = None
    step4 = STEP4_FIXED.replace("{text}", fixed_why) if fixed_why else STEP4_FREE
    prompt = (PROMPT.replace("{step4}", step4).replace("{voice}", voice_rules() or "(none)")
                    .replace("{jd}", jd).replace("{resume}", resume_block))
    print("resume-pitch: asking claude to match JD problems to resume bullets…", file=sys.stderr)
    p = ask_llm(prompt, a.model)
    resume_text = json.dumps(resume, ensure_ascii=False) + " " + (fixed_why or "")
    text, issues = render(p, by_id, jd, resume_text, fixed_why)
    slug = os.path.basename(a.tailored_json)[len("tailored_"):-len(".json")]
    out = a.out or f"pitch_{slug}.txt"
    open(out, "w", encoding="utf-8").write(text)
    print(f"Wrote: {out}" + (f"  ({len(issues)} check issue(s) — see CHECKS at the end)" if issues else "  (checks passed)"),
          file=sys.stderr)


if __name__ == "__main__":
    main()
