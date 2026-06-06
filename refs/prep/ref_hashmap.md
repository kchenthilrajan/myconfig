# HashMap Reference

---

## LC 49 — Group Anagrams

Given an array of strings, group all anagrams together.

**Input:** `strs = ["eat","tea","tan","ate","nat","bat"]`
**Output:** `[["eat","tea","ate"],["tan","nat"],["bat"]]`

**Signal → Shape:** group strings by a shared property → HashMap (sorted-letter key → bucket)

**Key insight:** anagrams always produce the same sorted-letter string regardless of original letter order. That sorted string is the canonical key.

**Invariant:** `groups.get(sorted(word))` always contains all original words sharing that anagram signature
**Postcondition:** every word is in exactly one bucket

```javascript
function groupAnagrams(strs) {
  const groups = new Map();
  for (const word of strs) {
    const key = word.split("").sort().join("");
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(word);
  }
  return Array.from(groups.values());
}
```

---

## LC 36 — Valid Sudoku

Determine if a 9×9 Sudoku board is valid. Each row, column, and 3×3 box must contain digits 1–9 with no repeats. Empty cells are `'.'`.

**Input:** a 9×9 board (partially filled)
**Output:** `true` or `false`

**Signal → Shape:** validate uniqueness across 27 independent groups → 27 Sets (9 rows + 9 cols + 9 boxes)

**Key insight:** box index formula — `Math.floor(i/3) * 3 + Math.floor(j/3)` maps any `(i,j)` to one of 9 boxes (0–8).

**Invariant:** for every cell processed, its digit has not been seen yet in its row, column, or box
**Postcondition:** all 81 cells checked; board is valid

```javascript
function isValidSudoku(board) {
  const rows  = Array.from({ length: 9 }, () => new Set());
  const cols  = Array.from({ length: 9 }, () => new Set());
  const boxes = Array.from({ length: 9 }, () => new Set());
  for (let i = 0; i < 9; i++) {
    for (let j = 0; j < 9; j++) {
      const val = board[i][j];
      if (val === '.') continue;
      const boxIndex = Math.floor(i / 3) * 3 + Math.floor(j / 3);
      if (rows[i].has(val) || cols[j].has(val) || boxes[boxIndex].has(val)) return false;
      rows[i].add(val);
      cols[j].add(val);
      boxes[boxIndex].add(val);
    }
  }
  return true;
}
```
