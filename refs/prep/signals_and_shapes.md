# Signals, Shapes, Vocabulary and Idioms

> The goal is not to memorize these.
> The goal is to use them so many times they become automatic —
> the way "don't beat around the bush" comes out without thinking.

---

## The Decision Tree — run this before every problem

```
Step 1: What am I doing?
  just finding one thing?       → single loop or binary search
  keeping some, discarding some → go to Step 2
  finding a pair or triplet?    → inward pointers
  finding a subarray?           → go to Step 3

Step 2: Does order matter?
  yes                           → writer / reader (same direction)
  no                            → inward swap

Step 3: Fixed size or variable?
  fixed size k                  → fixed sliding window
  variable, maximize/minimize   → variable sliding window
  exact sum, has negatives      → prefix sum + hashmap
```

---

## Signal → Shape Map

```
SIGNAL                                       SHAPE
────────────────────────────────────────────────────────────────

find one thing in unsorted array             single loop
find one thing in sorted array, O(log n)     binary search
keep some discard some, order matters        writer / reader
two groups, order does NOT matter            inward swap
find a pair that sums/multiplies to target   inward pointers
find best subarray of fixed size k           fixed sliding window
find longest/shortest subarray (variable)    variable sliding window
exact subarray sum, array has negatives      prefix sum + hashmap
overlapping intervals                        sort by start + scan
next greater/smaller element                 monotonic stack
top K elements                               heap
grid traversal, shortest path                BFS
grid traversal, flood fill / explore         DFS
tree problems, value bubbles up              recursion
count ways / min cost / max value            dynamic programming
```

---

## Vocabulary

```
writer        next empty slot to write a kept value into
              passive — never checked, only written to

reader        current element being inspected
              active — makes all decisions

invariant     what is always true about arr[0..writer-1] at any point in the loop

left          pointer at index 0, moves rightward →

right         pointer at last index, moves leftward ←

anchor        fixed element (outer loop i in 3Sum)
              left and right reset fresh for every anchor

window        the subarray between two same-direction pointers

expand        move right pointer forward → window grows

shrink        move left pointer forward → window contracts

boundary      last known valid match index in binary search
              starts at -1 (not found), updated on every match

pivot         the value used to split array into two groups

signal        the property of the problem that tells you which shape fits

shape         the pointer/loop structure that solves this class of problem

idiom         a code structure so commonly reused it should come out automatically
              like a proverb — not invented fresh each time, just reached for
```

---

## Code Idioms — the reusable phrases of array problems

These are the "don't beat around the bush" of code.
You do not derive them. You recognize the situation and they come out.

```javascript
// ── Inward pointers ──────────────────────────────────────────
let left = 0, right = arr.length - 1;
while (left < right) {
  // ... decide, then:
  left++;
  right--;
}

// ── Inward pointers with skip (palindrome, partition) ────────
while (left < right && !isValid(arr[left]))  left++;
while (left < right && !isValid(arr[right])) right--;
// inner while always inherits the same left < right guard

// ── Writer / reader ──────────────────────────────────────────
let writer = 0, reader = 0;   // both 0 when index 0 is unknown
// OR
let writer = 1, reader = 1;   // both 1 when index 0 is always kept
while (reader < arr.length) {
  if (shouldKeep(arr[reader])) {
    arr[writer] = arr[reader];
    writer++;
  }
  reader++;
}

// ── Writer / reader with duplicate check ─────────────────────
if (arr[reader] === arr[writer - 1]) {
  reader++;          // duplicate — skip
} else {
  arr[writer] = arr[reader];
  writer++;
  reader++;
}
// arr[writer] is empty — NEVER check it
// arr[writer-1] is last kept value — compare against this

// ── Binary search ─────────────────────────────────────────────
let left = 0, right = arr.length - 1;
while (left <= right) {        // <= not < (single element window is valid)
  const mid = Math.floor((left + right) / 2);
  if (arr[mid] === target) return mid;
  else if (arr[mid] < target) left = mid + 1;
  else right = mid - 1;
}
return -1;

// ── Binary search — find boundary (first or last position) ───
let boundary = -1;
if (arr[mid] === target) {
  boundary = mid;              // record but keep searching
  if (findFirst) right = mid - 1;
  else           left  = mid + 1;
}

// ── 3Sum — anchor + inward pointers ──────────────────────────
for (let i = 0; i < nums.length - 2; i++) {
  if (i > 0 && nums[i] === nums[i-1]) continue;  // skip duplicate anchor
  let left = i + 1;            // left always resets to i+1
  let right = nums.length - 1; // right always resets to end
  while (left < right) { ... }
}

// ── Merge intervals ───────────────────────────────────────────
intervals.sort((a, b) => a[0] - b[0]);
let current = intervals[0];
for (let i = 1; i < intervals.length; i++) {
  if (intervals[i][0] <= current[1]) {
    current[1] = Math.max(current[1], intervals[i][1]);
  } else {
    result.push(current);
    current = intervals[i];
  }
}
result.push(current);  // always push last — easy to forget

// ── Micro-idioms — one-liners that trip you up ────────────────

// max value in a frequency object
const maxFreq = Math.max(...Object.values(freq));
// Math.max takes spread args, NOT an array — Math.max([...arr]) is wrong

// increment frequency (handles missing key)
freq[char] = (freq[char] || 0) + 1;

// decrement frequency when shrinking window
freq[char]--;

// object keys as array
Object.keys(obj)

// object values as array
Object.values(obj)

// sort comparator (ascending)
arr.sort((a, b) => a - b);

// sort comparator (descending)
arr.sort((a, b) => b - a);

// swap two elements in place
[arr[i], arr[j]] = [arr[j], arr[i]];

// check if char is in current path (permutations)
current.includes(char)

// word → sorted anagram key
word.split("").sort().join("")
```

---

## The One Line to Write Before Every Problem

```javascript
// Signal: ______  →  Shape: ______
```

e.g.
```javascript
// Signal: keep non-zeros, order matters        →  Shape: writer/reader
// Signal: find pair that sums to target        →  Shape: inward pointers
// Signal: two groups, order doesn't matter     →  Shape: inward swap
// Signal: just find one duplicate in sorted    →  Shape: single loop
```

This line forces you to read the problem before reaching for a pattern.
Write it for every single problem until it becomes automatic.

---

## Invariant Thinking — from Simulation to System

> Simulation thinking: "let me do what the problem says step by step"
> Invariant thinking:  "what single condition must always be true for my state to be valid?"
>
> Invariant thinking is what turns O(n²) brute force into O(n) elegant solutions.
> You do not simulate replacing characters. You find the condition that captures validity.

### What is an invariant?

```
The invariant is the single condition that must be TRUE
for your current window/state to be considered VALID.

It is like a speed limit:
  your window can be any size
  the invariant just says: whatever size you are, you must obey this rule

  rule holds  → valid, expand, record answer
  rule breaks → invalid, shrink until rule holds again
```

### The three lines to write before every problem

```javascript
// Precondition: ______  (what is true about the setup before we start)
// Invariant:    ______  (what stays true throughout every iteration)
// Constraint:   ______  (what we check and act on each step)
```

### Formal terms (from computer science / Hoare logic)

```
Precondition   →  what must be true BEFORE the algorithm starts
                  (array is sorted, left=0, right=end)
                  we called this "premise" — same thing

Invariant      →  what stays true THROUGHOUT every iteration
                  the condition that is never violated
                  this is the standard term, used everywhere

Postcondition  →  what is guaranteed AFTER the algorithm ends
                  (we found the answer, or proved it does not exist)
                  we did not name this explicitly before
```

### Invariants for problems already solved

```
Valid Palindrome
  Precondition:  string may contain noise (spaces, punctuation)
  Invariant:     every alphanumeric pair (left, right) processed so far has matched
  Postcondition: if loop completes, string is a palindrome

Two Sum II
  Precondition:  array is sorted, left=0, right=end
  Invariant:     the answer always lies within [left..right] if it exists
  Postcondition: either found the pair or left===right (does not exist)

Remove Duplicates
  Precondition:  array is sorted (duplicates are neighbors)
  Invariant:     arr[0..writer-1] contains only unique values in order
  Postcondition: writer = count of unique elements

Merge Intervals
  Precondition:  intervals sorted by start value
  Invariant:     current always represents the furthest-reaching merged interval so far
  Postcondition: result contains all non-overlapping merged intervals

Container With Most Water
  Precondition:  left=0, right=end
  Invariant:     maxWater holds the best area seen so far, shorter wall always moves
  Postcondition: maxWater is the answer

Longest Substring No Repeating (LC 3)
  Precondition:  left=0, right=0, seen=empty Set
  Invariant:     window always contains unique characters only
  Postcondition: maxLength is the answer

Longest Repeating Character Replacement (LC 424)
  Precondition:  left=0, right=0, freq=empty Map
  Invariant:     windowSize - maxFreq <= k  (replacements needed never exceeds k)
  Postcondition: maxLength is the answer
```

### Sliding window invariant template

```
Every variable sliding window problem fits this shape:

  Invariant:   windowProperty <= limit
  Constraint:  if windowProperty > limit → shrink left

  windowProperty changes per problem:
    sum of elements          → running number
    distinct character count → Map size
    zero count               → running count
    replacements needed      → windowSize - maxFreq
```

### Longest vs Shortest — the recording logic flips

```
LONGEST window satisfying condition:
  expand freely
  shrink when INVALID       (condition breaks)
  record when VALID         (after shrinking restores invariant)

SHORTEST window satisfying condition:
  expand until VALID        (condition first met)
  shrink while still VALID  (keep recording, keep shrinking)
  record when VALID         (before shrinking breaks it)
```

### Phase 2 — Invariant drill answers

```
1. Longest subarray where sum <= target
   input:  [2,1,5,2,3,2], target=7,  output: 3  ([2,3,2])
   Invariant:   window sum <= target
   windowProperty: running sum

2. Longest subarray with at most 2 distinct characters
   input:  "eceba",  output: 3  ("ece")
   Invariant:   distinct chars in window <= 2
   windowProperty: Map size

3. Smallest subarray whose sum >= target
   input:  [2,3,1,2,4,3], target=7,  output: 2  ([4,3])
   Invariant:   window sum >= target  (logic flips — shrink while valid)
   windowProperty: running sum

4. Longest subarray with at most k zeros
   input:  [1,1,0,1,1,0,1], k=1,  output: 5
   Invariant:   zero count in window <= k
   windowProperty: running zero count

5. Maximum 1s after flipping at most k zeros
   input:  [0,0,1,1,0,0,1,1,1,0,1,1,1], k=2,  output: 6
   Invariant:   windowSize - maxFreq <= k
   windowProperty: windowSize - maxFreq
```

### Phase 3 — Express invariant as code condition

```
"no duplicate characters"               → !seen.has(s[right])
"at most k replacements needed"         → windowSize - maxFreq <= k
"at most 2 distinct characters"         → freq.size <= 2
"sum does not exceed target"            → sum <= target
"at most k zeros in window"             → zeroCount <= k
```

### Phase 4 — Full problem, invariant first then code

For every new problem write these three lines before touching code:
```javascript
// Precondition: ______
// Invariant:    window is valid when ______
// Constraint:   if ______ → shrink left
// Summary:      ______  (Set / Map / Number / nothing)
```
