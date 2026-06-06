# Binary Search Reference

> **Template:** `while (left <= right)` — single-element window is valid
> **Boundary search:** record `boundary = mid` on match, keep searching in one direction

---

## LC 33 — Search in Rotated Sorted Array

Given a rotated sorted array with distinct values and a target, return its index or -1.

**Input:** `nums = [4,5,6,7,0,1,2], target = 0`
**Output:** `4`

**Signal → Shape:** find one value in a sorted (rotated) array → binary search

**Key insight:** after any rotation, exactly one of the two halves is always fully sorted. Identify which half is sorted, check if target is inside it, narrow to that half or the other.

**Invariant:** if target exists, it lies within `nums[left..right]`
**Postcondition:** `left > right` — search exhausted, return -1

```javascript
function search(nums, target) {
  let left = 0, right = nums.length - 1;
  while (left <= right) {
    const mid = Math.floor((left + right) / 2);
    if (nums[mid] === target) return mid;
    if (nums[left] <= nums[mid]) {
      if (nums[left] <= target && target < nums[mid]) right = mid - 1;
      else left = mid + 1;
    } else {
      if (nums[mid] < target && target <= nums[right]) left = mid + 1;
      else right = mid - 1;
    }
  }
  return -1;
}
```

---

## LC 34 — Find First and Last Position of Element in Sorted Array

Given a sorted array and a target, return `[first index, last index]`. Return `[-1,-1]` if not found.

**Input:** `nums = [5,7,7,8,8,10], target = 7`
**Output:** `[1,2]`

**Signal → Shape:** find boundary (first or last occurrence) in sorted array → binary search + boundary variable

**Key insight:** when `nums[mid] === target`, record `boundary = mid` but keep searching. To find first: go left (`right = mid - 1`). To find last: go right (`left = mid + 1`).

**Invariant:** `boundary` holds the most extreme match found so far; target still lies in `[left..right]`
**Postcondition:** `boundary` is first/last occurrence or -1

```javascript
function search(nums, target) {
  return [findBoundary(nums, target, "first"), findBoundary(nums, target, "last")];
}

function findBoundary(nums, target, direction) {
  let left = 0, right = nums.length - 1, boundary = -1;
  while (left <= right) {
    const mid = Math.floor((left + right) / 2);
    if (nums[mid] === target) {
      boundary = mid;
      if (direction === "first") right = mid - 1;
      else left = mid + 1;
    } else if (nums[mid] < target) left = mid + 1;
    else right = mid - 1;
  }
  return boundary;
}
```
