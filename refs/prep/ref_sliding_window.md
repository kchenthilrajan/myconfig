# Sliding Window Reference

> **Longest window:** shrink when INVALID, record when VALID (after shrink restores invariant)
> **Shortest window:** shrink while VALID, record before shrinking breaks it

---

## LC 3 — Longest Substring Without Repeating Characters

Given a string, return the length of the longest substring with no repeating characters.

**Input:** `s = "abcabcbb"`
**Output:** `3`

**Signal → Shape:** longest substring satisfying a condition → variable sliding window + Set

**Failure mode:** window contains a duplicate character
**Invariant:** window `s[left..right]` contains only unique characters
**Postcondition:** `maxLength` is the answer

```javascript
const s = "abcabcbb";
let left = 0, maxLength = 0;
const seen = new Set();
for (let right = 0; right < s.length; right++) {
  while (seen.has(s[right])) { seen.delete(s[left]); left++; }
  seen.add(s[right]);
  maxLength = Math.max(maxLength, right - left + 1);
}
console.log(maxLength); // 3
```

---

## LC 424 — Longest Repeating Character Replacement

You may replace at most k characters. Return the length of the longest substring containing the same letter after replacements.

**Input:** `s = "AABABBA", k = 1`
**Output:** `4`

**Signal → Shape:** longest window where `windowSize - maxFreq <= k` → variable sliding window + freq map

**Failure mode:** window needs more than k replacements
**Invariant:** `windowSize - maxFreq <= k`
**Key:** when invariant breaks, shrink by exactly 1 (using `if`, not `while`) — window slides forward, size stays or grows

```javascript
let s = "AABABBA", k = 1;
let left = 0, freq = {}, maxLength = 0;
for (let right = 0; right < s.length; right++) {
  freq[s[right]] = (freq[s[right]] || 0) + 1;
  const maxFreq = Math.max(...Object.values(freq));
  if (right - left + 1 - maxFreq > k) { freq[s[left]]--; left++; }
  maxLength = Math.max(maxLength, right - left + 1);
}
console.log(maxLength); // 4
```

---

## LC 209 — Minimum Size Subarray Sum

Given an array of positive integers and a target, return the length of the smallest subarray whose sum ≥ target. Return 0 if none.

**Input:** `nums = [2,3,1,2,4,3], target = 7`
**Output:** `2`

**Signal → Shape:** shortest window satisfying a condition → variable sliding window, shrink while valid

**Failure mode:** `if` instead of `while` — stops shrinking too early and misses smaller valid windows
**Invariant:** shrink while `sum >= target` — record minimum each time before shrinking
**Postcondition:** `min === Infinity` means no solution → return 0

```javascript
const nums = [2,3,1,2,4,3], target = 7;
let left = 0, sum = 0, min = Infinity;
for (let right = 0; right < nums.length; right++) {
  sum += nums[right];
  while (sum >= target) {
    min = Math.min(min, right - left + 1);
    sum -= nums[left];
    left++;
  }
}
console.log(min === Infinity ? 0 : min); // 2
```

---

## LC 76 — Minimum Window Substring

Given strings s and t, return the minimum window substring of s that contains every character in t (including duplicates). Return "" if none.

**Input:** `s = "ADOBECODEBANC", t = "ABC"`
**Output:** `"BANC"`

**Signal → Shape:** shortest window containing all of another string → variable sliding window + two freq maps + formed counter

**Key insight:** `formed` compresses two-map comparison to O(1).
- `formed++` only when `windowFreq[c] === tFreq[c]` (exact equality, not above)
- `formed--` only when `windowFreq[c] < tFreq[c]` (dropping below required, not just any decrement)

**Invariant:** `formed === required` means window contains all characters of t
**Postcondition:** `minLen`/`start` point to the shortest valid window

```javascript
let s = "ADOBECODEBANC", t = "ABC";
let left = 0, formed = 0, minLen = Infinity, start = 0;
const tFreq = {}, windowFreq = {};
for (const c of t) tFreq[c] = (tFreq[c] || 0) + 1;
const required = Object.keys(tFreq).length;
for (let right = 0; right < s.length; right++) {
  windowFreq[s[right]] = (windowFreq[s[right]] || 0) + 1;
  if (tFreq[s[right]] && windowFreq[s[right]] === tFreq[s[right]]) formed++;
  while (formed === required) {
    if (right - left + 1 < minLen) { minLen = right - left + 1; start = left; }
    windowFreq[s[left]]--;
    if (windowFreq[s[left]] < tFreq[s[left]]) formed--;
    left++;
  }
}
console.log(minLen === Infinity ? "" : s.slice(start, start + minLen)); // "BANC"
```
