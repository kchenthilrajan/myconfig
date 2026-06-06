# Two Pointers Reference

---

## LC 125 — Valid Palindrome

A phrase is a palindrome if, after converting to lowercase and removing all non-alphanumeric characters, it reads the same forward and backward.

**Input:** `s = "A man, a plan, a canal: Panama"`
**Output:** `true`

**Signal → Shape:** check matching pairs from both ends, skip noise → inward pointers with skip

**Failure mode:** comparing non-alphanumeric characters gives wrong results
**Invariant:** every valid (alphanumeric) pair seen so far has matched; answer still lies in `[left..right]`
**Postcondition:** `left >= right` — all pairs matched

```javascript
function isPalindrome(s) {
  let left = 0, right = s.length - 1;
  while (left < right) {
    while (left < right && !isAlphaNum(s[left]))  left++;
    while (left < right && !isAlphaNum(s[right])) right--;
    if (s[left].toLowerCase() !== s[right].toLowerCase()) return false;
    left++;
    right--;
  }
  return true;
}

function isAlphaNum(c) {
  const code = c.charCodeAt(0);
  return (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || (code >= 48 && code <= 57);
}
```

---

## LC 167 — Two Sum II

Given a 1-indexed sorted array, find two numbers that add up to target. Return their 1-based indices.

**Input:** `numbers = [2,7,11,15], target = 9`
**Output:** `[1,2]`

**Signal → Shape:** sorted array, find pair summing to target → inward pointers

**Failure mode:** moving the wrong pointer skips the valid pair
**Invariant:** if a solution exists, it lies within `numbers[left..right]`
**Postcondition:** pair found or `left >= right` (no solution)

```javascript
function twoSum(numbers, target) {
  let left = 0, right = numbers.length - 1;
  while (left < right) {
    const sum = numbers[left] + numbers[right];
    if (sum === target) return [left + 1, right + 1];
    else if (sum < target) left++;
    else right--;
  }
  return [];
}
```

---

## LC 15 — 3Sum

Given an integer array, return all unique triplets that sum to zero.

**Input:** `nums = [-1,0,1,2,-1,-4]`
**Output:** `[[-1,-1,2],[-1,0,1]]`

**Signal → Shape:** find all triplets summing to zero → sort + anchor outer loop + inward pointers

**Failure mode:** duplicate anchor or duplicate pair produces duplicate triplets
**Invariant:** for each anchor `nums[i]`, the valid pair (if any) lies within `nums[left..right]`
**Postcondition:** all anchors exhausted; `result` holds all unique zero-sum triplets

```javascript
function threeSum(nums) {
  nums.sort((a, b) => a - b);
  const result = [];
  for (let i = 0; i < nums.length - 2; i++) {
    if (nums[i] > 0) break;
    if (i > 0 && nums[i] === nums[i - 1]) continue;
    let left = i + 1, right = nums.length - 1;
    while (left < right) {
      const sum = nums[i] + nums[left] + nums[right];
      if (sum === 0) {
        result.push([nums[i], nums[left], nums[right]]);
        left++; right--;
        while (left < right && nums[left] === nums[left - 1]) left++;
        while (left < right && nums[right] === nums[right + 1]) right--;
      } else if (sum < 0) left++;
      else right--;
    }
  }
  return result;
}
```

---

## LC 11 — Container With Most Water

Given n vertical lines represented by heights, find two lines that hold the most water.

**Input:** `height = [1,8,6,2,5,4,8,3,7]`
**Output:** `49`

**Signal → Shape:** maximize area between two bars → inward pointers, always move shorter wall

**Failure mode:** moving the taller wall can only shrink area (width always decreases)
**Invariant:** `maxWater` holds the best area seen so far; shorter wall always moves inward
**Postcondition:** `left >= right` — all useful pairs evaluated

```javascript
function maxArea(height) {
  let left = 0, right = height.length - 1, maxWater = 0;
  while (left < right) {
    maxWater = Math.max(maxWater, (right - left) * Math.min(height[left], height[right]));
    if (height[left] <= height[right]) left++;
    else right--;
  }
  return maxWater;
}
```

---

## LC 26 — Remove Duplicates from Sorted Array

Given a sorted array, remove duplicates in-place. Return the count of unique elements.

**Input:** `nums = [1,1,2,3,3,3,4]`
**Output:** `4` (first 4 elements are `[1,2,3,4]`)

**Signal → Shape:** keep some discard some in sorted array, order matters → writer/reader

**Failure mode:** `writer=0` skips index 0 which is always kept; checking `arr[writer]` instead of `arr[writer-1]`
**Invariant:** `nums[0..writer-1]` contains only unique values in order
**Postcondition:** `writer` = count of unique elements

```javascript
function removeDuplicates(nums) {
  let writer = 1;
  for (let reader = 1; reader < nums.length; reader++) {
    if (nums[reader] !== nums[reader - 1]) {
      nums[writer] = nums[reader];
      writer++;
    }
  }
  return writer;
}
```
