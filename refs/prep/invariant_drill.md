# Invariant Drill Protocol

The skill to build is not "remember the invariant for this problem."
It is: given any loop, derive the invariant from scratch by asking what goes wrong.

That's a thinking habit, not a memorization task.

---

## Before Touching Code — Write These Three Lines

```javascript
// Failure modes: ______  (how can the partial solution become wrong?)
// Invariant:     ______  (negate the failure modes)
// Guards:        ______  (invariant projected one step forward)
```

Only after filling these in do you write a single line of code.
If you can't fill them in, you don't understand the problem yet — go back and think, don't start coding.

---

## The Universal Move

```
1. Ask: how does a partial solution become wrong?
2. List all failure modes
3. Drop redundant ones (implied by others)
4. Negate → invariant
5. Project one step forward → guards
```

---

## Phase 1 — One failure mode, obvious invariant
Goal: get comfortable with the failure → invariant → guard move

| Problem | The failure mode to find |
|---|---|
| Find max in array | `max` holds wrong value mid-loop |
| Running sum | sum includes elements not yet seen |
| Valid Palindrome (LC 125) | comparing past the middle |
| Binary Search (LC 704) | answer eliminated by moving wrong boundary |
| Remove Duplicates (LC 26) | checking `arr[writer]` instead of `arr[writer-1]` |

---

## Phase 2 — Two independent failure modes
Goal: learn to check if failure modes are redundant

| Problem | The two failure modes to find |
|---|---|
| Two Sum II (LC 167) | sum too big AND sum too small handled wrong |
| Container With Most Water (LC 11) | moving taller wall AND not updating max |
| Longest Substring No Repeat (LC 3) | duplicate in window AND shrink removes wrong char |
| Generate Parentheses (LC 22) | `open > n` AND `close > open` |
| Merge Intervals (LC 56) | unsorted input AND last interval never pushed |

---

## Phase 3 — Nested invariants (outer loop + inner loop each need one)
Goal: identify that compound loops have compound invariants

| Problem | Outer invariant | Inner invariant |
|---|---|---|
| 3Sum (LC 15) | all triplets for anchor `< i` recorded | valid pair in `[left..right]` |
| Longest Repeating Char Replacement (LC 424) | window valid when `windowSize - maxFreq <= k` | freq map always reflects current window |
| Minimum Window Substring (LC 76) | window contains all required chars | shrink while still valid |

---

## Phase 4 — Generation and backtracking
Goal: apply failure mode thinking to recursive state, not loop state

Use the four lines before every problem:
```
I am standing at: ______
I know: ______
I do: ______
I hand off to next call: ______
```

| Problem | Failure modes | Key insight | Status |
|---|---|---|---|
| Generate Parentheses (LC 22) | `open > n` AND `close > open` | `open-close > 0` means something is open | ✅ cycle 1 done 2026-05-12 |
| Letter Combinations (LC 17) | index past end of digits | loop letters for ONE digit only, recurse with index+1 | ✅ cycle 1 done 2026-05-12 |
| Combination Sum (LC 39) | remaining < 0; duplicate combos from going backward | pass `i` not `i+1` to allow reuse AND prevent duplicates | ✅ cycle 1 done 2026-05-12 |
| Permutations (LC 46) | same element used twice in one path | `current.includes()` replaces index AND remaining | ✅ cycle 1 done 2026-05-12 |
| Subsets (LC 78) | duplicate subsets from same starting index | — | ⬜ todo |

---

## Phase 5 — DP (invariant is about subproblem correctness)
Goal: see that dp[i] always holding the correct answer IS the invariant

| Problem | Failure mode to find |
|---|---|
| Climbing Stairs (LC 70) | `dp[i]` computed before `dp[i-1]` and `dp[i-2]` |
| House Robber (LC 198) | adjacent houses both robbed |
| Coin Change (LC 322) | `dp[i]` initialized to wrong sentinel value |
| Longest Increasing Subsequence (LC 300) | `dp[j]` compared without checking `nums[j] < nums[i]` |

---

## The Progression Rule

Don't move to the next phase until you can write the failure modes
before reading any hints or solution structure — just from reading the problem statement.

The test is not "can you code this?"
The test is: can you fill in the three comment lines in under two minutes, from the problem statement alone?

When Phase 1 feels automatic, move to Phase 2.
Each phase should take about a week of daily drilling.

---

## Constraints → Invariant Reference

### Two Pointers — Inward
Failure modes: `left crosses right`
Invariant: answer still lies in `arr[left..right]`
Guard: `left < right`

### Two Pointers — Writer/Reader
Failure modes: writer checks its own slot; reader skips an element
Invariant: `arr[0..writer-1]` contains only valid kept values
Guard: compare `arr[writer-1]` not `arr[writer]`; reader visits every element

### Binary Search
Failure modes: search space empty; answer eliminated by wrong boundary move
Invariant: if target exists, it lies within `arr[left..right]`
Guard: `left <= right` (single element window is still valid)

### Binary Search — Boundary
Failure modes: stop at first match; lose best known match
Invariant: `boundary` holds most extreme valid match; target still in `[left..right]`
Guard: on match, record then keep searching — never return immediately

### Sliding Window — Longest valid
Failure modes: window contains invalid state; record before restoring invariant
Invariant: window always satisfies required property
Guard: shrink while invalid; record after invariant restored

### Sliding Window — Shortest valid
Failure modes: record before window is valid; stop shrinking too early
Invariant: window satisfies required property; shrink while still valid
Guard: record before shrinking, not after

### Generate Parentheses
Failure modes: `open > n`; `close > open` (note: `close > n` is redundant)
Invariant: `close <= open <= n`
Guards: `open < n` to add `(`; `close < open` to add `)`

### 3Sum
Failure modes: duplicate anchor; duplicate pair after match; left starts at 0
Invariant: all unique triplets for anchor `< i` recorded; valid pair in `[left..right]`
Guards: skip anchor if `i > 0 && nums[i] === nums[i-1]`; post-match skip for left/right

### Merge Intervals
Failure modes: non-adjacent overlap check (unsorted); last interval never pushed
Invariant: `current` is furthest-reaching merged interval; `result` holds all finalized
Guard: sort by start first; always push `current` after the loop

### Monotonic Stack
Failure modes: larger element sits below smaller on stack
Invariant: stack always contains elements in monotonically increasing/decreasing order
Guard: pop while `stack.top` violates monotonic condition before pushing

### BFS — Shortest Path
Failure modes: revisit a node; same node queued multiple times
Invariant: all nodes at distance `d` processed before distance `d+1`; visited prevents reprocessing
Guard: mark visited when enqueued, not when dequeued

### Backtracking / Permutations
Failure modes: reuse element in same path; exceed constraint; prune valid branch
Invariant: current path is always a valid partial solution; `used[]` tracks what's in path
Guard: check constraint before recursing; undo after recursing

### Dynamic Programming
Failure modes: subproblem uses result not yet computed; `dp[i]` defined incorrectly; base case missing
Invariant: `dp[i]` holds correct answer for subproblem of size `i`; all smaller subproblems solved
Guard: define `dp[i]` precisely before writing recurrence; fill in dependency order
