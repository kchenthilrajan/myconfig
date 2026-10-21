# JS Collection & Utility Cheatsheet

Every entry: what it does, then a concrete input → output. Skim once, keep open
during practice, and eventually during the real thing if it allows doc lookup.

---

## Array — transform / query (return new value, don't mutate)

| Method | Example |
|---|---|
| `.filter(fn)` — keep matches | `[1,-2,3].filter(x=>x>0)` → `[1,3]` |
| `.map(fn)` — transform 1:1 | `[1,2,3].map(x=>x*10)` → `[10,20,30]` |
| `.find(fn)` — first match or `undefined` | `[{id:1},{id:2}].find(x=>x.id===2)` → `{id:2}` |
| `.findIndex(fn)` — index or `-1` | `[10,20,30].findIndex(x=>x===20)` → `1` |
| `.findLast(fn)` / `.findLastIndex(fn)` | `[1,2,1].findLastIndex(x=>x===1)` → `2` |
| `.some(fn)` / `.every(fn)` → boolean | `[1,2,3].some(x=>x>2)` → `true` |
| `.reduce(fn, init)` — fold to one value | `[1,2,3].reduce((s,x)=>s+x,0)` → `6` |
| `.slice(start,end)` — copy a range, `end` exclusive | `[10,20,30,40].slice(1,3)` → `[20,30]` |
| `.flat(depth)` / `.flatMap(fn)` | `[[1,2],[3]].flat()` → `[1,2,3]` |
| `.includes(val)` / `.indexOf(val)` | `[1,2,3].includes(2)` → `true` |
| `.join(sep)` | `[1,2,3].join('-')` → `"1-2-3"` |
| `.at(i)` — supports negative index | `[1,2,3].at(-1)` → `3` |
| `Array.from(iterable, fn?)` | `Array.from({length:3}, (_,i)=>i*2)` → `[0,2,4]` |
| `Array.isArray(x)` | `Array.isArray([1])` → `true` |

**`.sort(fn)`** mutates — always pass a comparator, copy first if you need the original:
```js
[...arr].sort((a,b) => a - b)          // ascending numbers
[...arr].sort((a,b) => a.date.localeCompare(b.date))  // ISO date strings
```

## Array — mutating (change the array itself, be deliberate)

| Method | Example |
|---|---|
| `.splice(start, deleteCount, ...items)` — remove/insert, returns removed | `const a=[1,2,3,4]; a.splice(1,2)` → `a` is `[1,4]`, returns `[2,3]` |
| `.push(x)` / `.pop()` | add/remove at end |
| `.unshift(x)` / `.shift()` | add/remove at start |

**The "match two lists" pattern** (reconciliation-shaped problems): `filter` down to
candidates → `find`/`findIndex` the best one → `splice` it out of the remaining pool so
it can't be reused → repeat.

---

## Object

| Task | Example |
|---|---|
| Keys / values / pairs | `Object.keys({a:1,b:2})` → `['a','b']`; `Object.values(...)` → `[1,2]`; `Object.entries(...)` → `[['a',1],['b',2]]` |
| Build object from pairs | `Object.fromEntries([['a',1],['b',2]])` → `{a:1,b:2}` |
| Shallow copy / merge | `{...obj, extra: 1}` |
| Copy with one field changed (common in "don't mutate" tasks) | `{...tx, matched: true}` |
| Deep clone (no functions/dates as-is) | `JSON.parse(JSON.stringify(obj))` |
| Safe optional access | `obj?.nested?.field` → `undefined` instead of throwing |
| Default if null/undefined | `value ?? 'default'` (only null/undefined trigger default, unlike `\|\|`) |

---

## Map — when keys aren't strings, or insertion order / size matters

```js
const m = new Map();
m.set('a', 1).set('b', 2);
m.get('a')            // → 1
m.has('c')            // → false
m.delete('a')
m.size                // → 1
[...m.entries()]      // → [['b', 2]]
[...m.keys()]         // → ['b']
```

**Grouping/lookup-by-key pattern** (e.g. "index ledger entries by id" — beats `reduce`
when you want `.get`/`.has` semantics):
```js
const byId = new Map(ledgerEntries.map(e => [e.id, e]));
byId.get('L1')         // → that entry, O(1) instead of scanning with .find
```

**Group into buckets** (e.g. "group transactions by date"):
```js
const byDate = new Map();
for (const tx of transactions) {
  if (!byDate.has(tx.date)) byDate.set(tx.date, []);
  byDate.get(tx.date).push(tx);
}
```

---

## Set — uniqueness and membership, fast `.has()`

```js
const s = new Set([1,2,2,3]);
[...s]                 // → [1, 2, 3]   (dedupe an array)
s.has(2)                // → true
s.add(4); s.delete(1)
s.size                  // → 3
```

**Diffing two lists** (e.g. "ids in ledger but not in bank feed" — this is the reverse
of a `.find()`-based match and much faster for large lists):
```js
const bankIds = new Set(bankTransactions.map(b => b.id));
const onlyInLedger = ledgerEntries.filter(e => !bankIds.has(e.id));
```

**Intersection / union**:
```js
const a = new Set([1,2,3]), b = new Set([2,3,4]);
const intersection = [...a].filter(x => b.has(x));   // → [2, 3]
const union = new Set([...a, ...b]);                  // → {1,2,3,4}
```

---

## Date — what it actually is, and the sharp edges

**A `Date` is just one number**: milliseconds since the Unix epoch (1970-01-01 UTC).
Nothing else is stored — no timezone, no separate year/month/day fields. Every getter
(`getFullYear()`, `getHours()`, ...) *computes* its answer from that one number, through
either UTC or the system's local zone depending on which method you call. "Only showing
the date" (`toDateString()`, slicing an ISO string) is a display choice, not a lower-
precision object — the full millisecond value is always there underneath.

**Parsing rules — this is the actual trap, and it's inconsistent by design:**

| Input | Parsed as | Example |
|---|---|---|
| Date-only ISO, zero-padded (`'YYYY-MM-DD'`) | **UTC** midnight | `new Date('2026-05-04')` → `2026-05-04T00:00:00.000Z` |
| Date-only, NOT zero-padded (`'YYYY-M-D'`) | Lenient fallback, **local** time, implementation-defined | `new Date('2026-5-4')` → `...T07:00:00.000Z` on a UTC-7 machine |
| Datetime, no zone (`'YYYY-MM-DDTHH:mm:ss'`) | **local** time | `new Date('2026-05-04T00:00:00')` → `...T07:00:00.000Z` on a UTC-7 machine |
| Datetime + explicit offset (`...Z` or `...-07:00`) | that exact instant, unambiguous | `new Date('2026-05-04T00:00:00Z')` → itself |
| Datetime, non-padded month/day + offset | **`Invalid Date`** — strict grammar required once a time part is present | `new Date('2026-5-4T00:00:00Z')` → `Invalid Date` |
| Component constructor `new Date(y, m, d)` | always **local** time (and `m` is 0-indexed!) | `new Date(2026, 2, 5)` → March 5 local |

So the same "no explicit zone" input parses as UTC or local **depending on whether a
time part is present** — genuinely not guessable, verify on real data rather than assume.

**A `Date` built from a date-only string can display as the *previous* local day.**
`new Date('2026-05-04')` is UTC midnight — on a UTC-7 machine, its *local* getters
(`.getDate()`, `.toString()`) show **May 3rd, 5pm**, not May 4th. If you call local
getters on a date-only-string `Date`, you can silently be off by one calendar day.

**Comparing dates** — never `===` on two `Date` objects (always false, different
instances); use `.getTime()`, or subtract (works via implicit `valueOf()`):
```js
new Date(a) - new Date(b)                          // → difference in ms
new Date(a).getTime() === new Date(b).getTime()    // equality
```

**Explicit offsets normalize the *representation*, but same wall-clock time ≠ same
instant** — what matters is offset + clock time together:
```js
new Date('2026-05-04T00:00:00Z').getTime()      // 1777852800000
new Date('2026-05-04T00:00:00-07:00').getTime() // 1777878000000  ← different instant!
new Date('2026-05-03T17:00:00-07:00').getTime() // 1777852800000  ← same instant as the first
```

**No timezone-name parameter exists.** `new Date(dateString, 'America/Los_Angeles')` is
not a thing — passing a 2nd argument switches the constructor to the *component* form
(`year, month, day, ...`), coerces your string to a number, gets `NaN`, and produces
`Invalid Date`. The only way to attach a zone during construction is an offset baked
into the string itself (`Z`, `-07:00`). For formatting an instant *in* a named zone
(DST-aware), use `Intl.DateTimeFormat`, not `Date`:
```js
const d = new Date('2026-05-04T12:00:00Z');
new Intl.DateTimeFormat('en-US', { timeZone: 'America/Los_Angeles', dateStyle:'full', timeStyle:'long' }).format(d)
// → "Monday, May 4, 2026 at 5:00:00 AM PDT"
```

**Date arithmetic** (days between, add N days — no built-in, this is the standard idiom):
```js
const msPerDay = 24 * 60 * 60 * 1000;
const daysBetween = (a, b) => Math.abs(new Date(a) - new Date(b)) / msPerDay;   // fine for days/hours/min/weeks — fixed-length units

function addDays(dateStr, n) {
  const d = new Date(dateStr);
  d.setDate(d.getDate() + n);           // setDate handles month/year rollover for you
  return d.toISOString().slice(0, 10);
}
addDays('2026-03-30', 3)               // → '2026-04-02'
```
**Months/years are NOT fixed-length** (28-31 day months, leap years) — dividing ms by
`30 * msPerDay` for "months between" is quietly wrong. Use calendar-aware math instead:
```js
const monthsBetween = (a, b) => {
  const d1 = new Date(a), d2 = new Date(b);
  return (d2.getFullYear()-d1.getFullYear())*12 + (d2.getMonth()-d1.getMonth());
};
```

**The practical rule that sidesteps almost all of the above**: if you only care about
calendar dates (true for most bookkeeping/ledger data — no time-of-day), skip `Date`
objects entirely. Keep dates as plain `'YYYY-MM-DD'` strings and compare them directly —
lexicographic order matches chronological order *only when every string is the same
width with consistent zero-padding*:
```js
'2026-03-05' < '2026-03-07'            // → true — correct, both zero-padded
'2026-5-4' > '2026-5-14'               // → true — WRONG, day 4 vs day 14, unpadded breaks it
```

**If input padding is inconsistent, normalize with plain string ops — not `Date`**
(avoids every parsing gotcha above entirely, since there's no timezone interpretation
involved at all):
```js
function normalizeDateString(s) {
  const [y, m, d] = s.trim().split('-');
  return `${y}-${m.padStart(2,'0')}-${d.padStart(2,'0')}`;
}
normalizeDateString('2026-5-4')        // → '2026-05-04'
normalizeDateString('2026-05-04')      // → '2026-05-04'  (idempotent, safe on clean input too)
```

---

## Number / Math — and the money-specific gotcha

```js
Math.max(1, 5, 3)      // → 5      Math.min/max don't take an array directly — use ...arr
Math.max(...[1,5,3])   // → 5
Math.round(4.5)        // → 5
Number.isInteger(4.0)  // → true
parseInt('42px', 10)   // → 42     always pass the radix
```

**Never use floats for money.** `0.1 + 0.2 === 0.30000000000000004`. Store amounts as
integer cents (`amountCents`) and only convert to dollars for display:
```js
const dollars = (cents / 100).toFixed(2)   // → '12.00' — string, for display only
```

---

## String

```js
'a,b,,c'.split(',')                 // → ['a','b','','c']
'  hi  '.trim()                     // → 'hi'
'5'.padStart(3, '0')                // → '005'
'Invoice #482'.includes('482')      // → true
`Total: ${amount}`                  // template literal
'abc'.replace('b', 'X')             // → 'aXc'   (first match only; use /g for all)
```

---

## Quick lookup: "I need to..."

| Need | Reach for |
|---|---|
| Keep only items matching a condition | `.filter()` |
| Transform every item | `.map()` |
| Find one item | `.find()` / `.findIndex()` |
| Check if any/all match | `.some()` / `.every()` |
| Total, count, or build a lookup from a list | `.reduce()` or a `Map` |
| Fast repeated lookup by id | `new Map(list.map(x => [x.id, x]))` |
| Remove duplicates | `new Set(arr)` → spread back to array |
| Find what's in A but not B | `Set` of B's keys, `.filter()` on A with `!set.has(...)` |
| Remove/insert in the middle of an array | `.splice()` |
| Copy a sub-range | `.slice()` |
| Days between two dates | `Math.abs(new Date(a) - new Date(b)) / 86400000` |
| Months between two dates | calendar-aware subtraction — NOT ms division, see Date section |
| Compare same-format date strings | plain `<` / `>` / `===`, no `Date` needed |
| Date strings with inconsistent zero-padding | `normalizeDateString()` — plain string ops, no `Date` |
| Format an instant in a specific named timezone | `Intl.DateTimeFormat(locale, {timeZone})`, not `Date` |
| Avoid mutating a shared object | `{...obj, field: newValue}` |
| Money math | integer cents, never floats |
| Initialize / preallocate an array of objects | `Array.from({length:n}, () => new Map())` (not `fill(new Map())`, which shares one object). Full notes: `js-idioms.md` |
