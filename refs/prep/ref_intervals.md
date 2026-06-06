# Intervals Reference

---

## LC 56 — Merge Intervals

Given an array of intervals, merge all overlapping intervals and return the result.

**Input:** `intervals = [[1,3],[2,6],[8,10],[15,18]]`
**Output:** `[[1,6],[8,10],[15,18]]`

**Signal → Shape:** overlapping intervals → sort by start, scan with active merger

**Key insight:** after sorting by start, only the current interval and the next one can possibly overlap — no need to look further back.

**Easy miss:** the last `current` never gets pushed inside the loop — always `result.push(current)` after the loop.

**Failure mode:** forgetting to push the final current; not taking `Math.max` (next could be fully inside current)
**Invariant:** `current` is the furthest-reaching merged interval seen so far; `result` holds all finalized (non-extendable) intervals
**Postcondition:** push `current` after loop; `result` contains the complete merged set

```javascript
function merge(intervals) {
  intervals.sort((a, b) => a[0] - b[0]);
  const result = [];
  let current = intervals[0];
  for (let i = 1; i < intervals.length; i++) {
    if (intervals[i][0] <= current[1]) {
      current[1] = Math.max(current[1], intervals[i][1]);
    } else {
      result.push(current);
      current = intervals[i];
    }
  }
  result.push(current);
  return result;
}
```
