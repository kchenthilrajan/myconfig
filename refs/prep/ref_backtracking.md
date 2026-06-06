# Backtracking Reference

> **Four lines before every backtracking problem:**
> ```
> I am standing at: ______  (what position am I at?)
> I know:           ______  (what is already built / what's left?)
> I do:             ______  (what decision do I make here?)
> I hand off:       recurse(______)
> ```

---

## LC 22 — Generate Parentheses

Given n, generate all combinations of n pairs of well-formed parentheses.

**Input:** `n = 3`
**Output:** `["((()))","(()())","(())()","()(())","()()()"]`

**Signal → Shape:** build all valid strings one character at a time → backtracking

**Vantage point:** I am placing one character at the current position
**Base case:** `open === n && close === n` — string is complete
**Rules:**
- place `(` when `open < n` — budget remains
- place `)` when `close < open` — there is an unmatched open to close

**Key:** `close < open` is the invariant for "every prefix is valid"

```javascript
const resultArr = [];
function parenthesis(open, close, n, result) {
  if (open === n && close === n) { resultArr.push(result); return; }
  if (open < n)    parenthesis(open + 1, close, n, result + "(");
  if (close < open) parenthesis(open, close + 1, n, result + ")");
}
parenthesis(0, 0, 3, "");
console.log(resultArr);
```

---

## LC 17 — Letter Combinations of a Phone Number

Given a digit string (2–9), return all letter combinations the phone pad could represent.

**Input:** `digits = "23"`
**Output:** `["ad","ae","af","bd","be","bf","cd","ce","cf"]`

**Signal → Shape:** pick one letter per digit, no reuse → backtracking, pass `index + 1`

**Vantage point:** I am at digit `index`, choosing which letter to append
**Base case:** `index === digits.length` — one complete combination built
**Key:** pass `index + 1` (not `index`) — each digit consumed exactly once, no reuse

```javascript
const map = {2:"abc",3:"def",4:"ghi",5:"jkl",6:"mno",7:"pqrs",8:"tuv",9:"wxyz"};
const digits = "23";
const result = [];
function generateCombination(index, current) {
  if (index === digits.length) { result.push(current); return; }
  for (let i = 0; i < map[digits[index]].length; i++) {
    generateCombination(index + 1, current + map[digits[index]][i]);
  }
}
generateCombination(0, "");
console.log(result);
```

---

## LC 39 — Combination Sum

Given distinct integers, return all combinations that sum to target. The same number may be used multiple times.

**Input:** `candidates = [2,3,5], target = 8`
**Output:** `[[2,2,2,2],[2,3,3],[3,5]]`

**Signal → Shape:** build all combinations summing to target with reuse allowed → backtracking

**Vantage point:** I am at index `i`, deciding whether to use `candidates[i]`
**Base case:** `remaining === 0` — valid combination found
**Key:** pass `i` not `i + 1` — allows reuse of the same element AND prevents revisiting earlier candidates (no duplicates)

```javascript
const candidates = [2,3,5], target = 8;
const result = [];
function recurse(index, remaining, current) {
  if (remaining === 0) { result.push(current); return; }
  for (let i = index; i < candidates.length; i++) {
    if (remaining >= candidates[i])
      recurse(i, remaining - candidates[i], [...current, candidates[i]]);
  }
}
recurse(0, target, []);
console.log(result);
```

---

## LC 46 — Permutations

Given distinct integers, return all possible permutations.

**Input:** `nums = [1,2,3]`
**Output:** `[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]`

**Signal → Shape:** build all orderings of all elements → backtracking, no index needed

**Vantage point:** I have built `current` so far, picking the next unused element
**Base case:** `current.length === nums.length` — full permutation built
**Key:** `current.length` replaces index — position is implicit in what's been built; use `current.includes()` to skip used elements

```javascript
const nums = [1,2,3];
const result = [];
function permutate(current) {
  if (current.length === nums.length) { result.push(current); return; }
  for (let i = 0; i < nums.length; i++) {
    if (!current.includes(nums[i])) permutate([...current, nums[i]]);
  }
}
permutate([]);
console.log(result);
```
