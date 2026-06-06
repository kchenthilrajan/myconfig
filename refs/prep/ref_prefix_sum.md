# Prefix Sum + HashMap Reference

> **Core insight:** same prefix sum at index i and j means subarray nums[i+1..j] sums to zero.
> **Signal:** exact subarray sum problem where negatives are possible, or equal counts of two things.

| | LC 560 | LC 525 | LC 974 |
|--|--|--|--|
| **Goal** | count subarrays summing to k | longest subarray equal 0s and 1s | count subarrays divisible by k |
| **Transform** | none | 0 → -1 | none |
| **Map key** | prefix sum | prefix sum | prefix sum % k |
| **Map value** | count of occurrences | first index seen | count of occurrences |
| **Map start** | `{0: 1}` | `{0: -1}` | `{0: 1}` |
| **On match** | `count += map[key]` | `maxLen = max(maxLen, i - map[key])` | `count += map[key]` |
| **Update map** | always | only if not seen | always |

---

## LC 560 — Subarray Sum Equals K

Given an array and integer k, return the total number of subarrays whose sum equals k.

**Input:** `nums = [1,2,3], k = 3`

**Signal → Shape:** exact subarray sum, negatives possible → prefix sum + hashmap

**Invariant:** `map[currentSum - k]` = number of earlier indices where a valid subarray starts

```javascript
const nums = [1,2,3], k = 3;
let sum = 0, count = 0;
const map = {0: 1};
for (const num of nums) {
  sum += num;
  count += map[sum - k] || 0;
  map[sum] = (map[sum] || 0) + 1;
}
console.log(count); // 2
```

---

## LC 525 — Contiguous Array

Given a binary array, return the max length of a subarray with equal number of 0s and 1s.

**Input:** `nums = [0,1,0,1,1,0]`

**Signal → Shape:** equal count of two values → treat 0 as -1, prefix sum + hashmap (first index)

**Invariant:** same prefix sum at two indices = equal 0s and 1s between them; store first index to maximize length

```javascript
const nums = [0,1,0,1,1,0];
let sum = 0, maxLength = 0;
const map = {0: -1};
for (let i = 0; i < nums.length; i++) {
  sum += nums[i] === 0 ? -1 : 1;
  if (map[sum] !== undefined) {
    maxLength = Math.max(maxLength, i - map[sum]);
  } else {
    map[sum] = i;
  }
}
console.log(maxLength); // 6
```

---

## LC 974 — Subarray Sums Divisible by K

Given an array and integer k, return the number of subarrays whose sum is divisible by k.

**Input:** `nums = [4,5,0,-2,-3,1], k = 5`

**Signal → Shape:** divisibility condition on subarray sum → prefix sum % k + hashmap

**Key math:** `(prefix[j] - prefix[i]) % k === 0` ↔ `prefix[j] % k === prefix[i] % k`

```javascript
const nums = [4,5,0,-2,-3,1], k = 5;
let sum = 0, count = 0;
const map = {0: 1};
for (const num of nums) {
  sum += num;
  const remainder = sum % k;
  count += map[remainder] || 0;
  map[remainder] = (map[remainder] || 0) + 1;
}
console.log(count); // 7
```
