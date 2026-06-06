# Algorithm Patterns — Mechanical Summary

> Updated as we progress. Each pattern captures the exact coding mechanics —
> initialization, loop structure, skip conditions, edge cases, gotchas.

---

## 1. Two Pointers

**Problems drilled:** 125 (Valid Palindrome), 15 (3Sum)
**Next:** 167 (Two Sum II)

```
INITIALIZE
  let left  = 0;
  let right = s.length - 1;
  ─ left always starts at 0
  ─ right always starts at last index (length - 1)

OUTER LOOP — runs until pointers cross
  while (left < right) { ... }
  ─ condition is < not <=
  ─ when they meet, every pair has been checked, stop

SKIP LOOP (only when input has noise — e.g. palindrome)
  while (left < right && !isValid(s[left]))  left++;
  while (left < right && !isValid(s[right])) right--;
  ─ inner while, same boundary guard (left < right) repeated
  ─ always check boundary BEFORE accessing s[left] or s[right]
  ─ the ! is the skip — move past what you DON'T want

COMPARE / DECIDE
  if (mismatch)        → return false immediately
  if (sum too small)   → left++   (need bigger number, move left right)
  if (sum too big)     → right--  (need smaller number, move right left)
  if (match/zero sum)  → record result, then move BOTH inward

MOVE INWARD after a match
  left++;
  right--;
  ─ always both, never just one, after a successful pair

SKIP DUPLICATES (only when result must be unique — e.g. 3Sum)
  while (left < right && nums[left]  === nums[left - 1])  left++;
  while (left < right && nums[right] === nums[right + 1]) right--;
  ─ skip AFTER moving inward, not before
  ─ same boundary guard again

OUTER LOOP for fixed anchor (3Sum pattern)
  for (let i = 0; i < nums.length - 2; i++) {
    if (i > 0 && nums[i] === nums[i-1]) continue;  // skip duplicate anchor
    left  = i + 1;            // reset left to just after anchor
    right = nums.length - 1;  // reset right to far end
    // inner while loop here
  }
  ─ anchor moves forward one step at a time
  ─ left and right RESET fresh for every anchor position

SORTING — prerequisite for sum problems, not needed for palindrome
  nums.sort((a, b) => a - b);
  ─ always do this BEFORE setting left/right
  ─ without sort, moving left/right has no predictable effect on sum

EDGE CASES
  ─ empty / single character → while(left < right) never enters → correct by default
  ─ all noise characters → skip loops exhaust, pointers meet → returns true
  ─ duplicate anchors in 3Sum → guard with i > 0 before comparing to i-1

COMMON BUGS
  ─ missing ! in skip condition → skips valid chars, stops on noise
  ─ missing boundary guard in inner while → left/right go out of bounds
  ─ passing array instead of string → s.split("") not needed, s[i] works directly
  ─ left = i instead of left = i+1 in 3Sum → anchor and left share same index
```

---

## 2. Sliding Window
*Not started yet*

---

## 3. Prefix Sum + Hashmap
*Not started yet*

---

## 4. Binary Search

**Problems drilled:** 33 (Search in Rotated Sorted Array), 34 (Find First and Last Position)

```
INITIALIZE
  let left  = 0;
  let right = nums.length - 1;

OUTER LOOP
  while (left <= right) { ... }
  ─ condition is <= not <  (unlike two pointers)
  ─ left === right is still a valid single-element window to check

FIND MID
  const mid = Math.floor((left + right) / 2);
  ─ always recalculate mid at the top of every iteration
  ─ Math.floor ensures whole index

STANDARD BINARY SEARCH DECIDE
  if (nums[mid] === target) → found, return mid
  if (nums[mid] < target)   → go right → left = mid + 1
  if (nums[mid] > target)   → go left  → right = mid - 1

ROTATED ARRAY VARIANT — figure out which half is cleanly sorted
  if (nums[left] <= nums[mid]) {
    // left half [left..mid] is sorted
    if (nums[left] <= target && target < nums[mid])
      right = mid - 1;   // target inside sorted left half
    else
      left = mid + 1;    // target outside, must be in right half
  } else {
    // right half [mid..right] is sorted
    if (nums[mid] < target && target <= nums[right])
      left = mid + 1;    // target inside sorted right half
    else
      right = mid - 1;   // target outside, must be in left half
  }
  ─ one half always cleanly sorted after any rotation cut
  ─ check if target fits inside the sorted half's range
  ─ if yes go there, if no go to the other side

BOUNDARY SEARCH VARIANT (find first / last position)
  let boundary = -1;
  if (nums[mid] === target) {
    boundary = mid;           // record candidate, but don't stop
    if (findFirst) right = mid - 1;  // keep going left
    else           left  = mid + 1;  // keep going right
  }
  ─ -1 as default means not found
  ─ key insight: don't return immediately on match, keep narrowing

NOT FOUND
  return -1;  // left > right, target does not exist

EDGE CASES
  ─ single element array → left=right=0, one iteration, works correctly
  ─ target smaller than all → left keeps moving right until left > right
  ─ target larger than all → right keeps moving left until left > right
```

---

## 5. Intervals

**Problems drilled:** 56 (Merge Intervals)

```
INITIALIZE
  intervals.sort((a, b) => a[0] - b[0]);  // sort by start value
  let current = intervals[0];              // first interval in hand
  const result = [];

  ─ MUST sort first — overlapping intervals must be neighbors
  ─ current is the interval being actively extended

OUTER LOOP — walk through remaining intervals
  for (let i = 1; i < intervals.length; i++) {
    const next = intervals[i];
    ...
  }
  ─ starts at 1 because index 0 is already in current

OVERLAP CHECK
  if (next[0] <= current[1]) {
    // overlap — merge by stretching end
    current[1] = Math.max(current[1], next[1]);
  } else {
    // no overlap — save current, pick up next
    result.push(current);
    current = next;
  }
  ─ overlap condition: next START <= current END (touching counts)
  ─ merge by taking Math.max of ends (next might be fully inside current)
  ─ no overlap: push and move on

AFTER LOOP
  result.push(current);  // last interval never gets pushed inside the loop
  ─ easy to forget — always push current after loop ends

EDGE CASES
  ─ single interval → loop never runs → current pushed after → correct
  ─ fully contained interval [1,10] + [2,5] → max(10,5)=10, end stays 10
  ─ touching intervals [1,4] + [4,7] → 4 <= 4 → treated as overlap → [1,7]
  ─ unsorted input → sort handles it, no special case needed

COMMON BUGS
  ─ forgetting result.push(current) after the loop
  ─ using min instead of max when merging ends
  ─ using < instead of <= in overlap check → misses touching intervals
```

---

## 6. Monotonic Stack
*Not started yet*

---

## 7. Trees
*Not started yet*

---

## 8. BFS/DFS Grid
*Not started yet*

---

## 9. Heap / Top K
*Not started yet*

---

## 10. DP
*Not started yet*
