# js-idioms.md — JavaScript idioms and traps for coding practice

Companion to `go-idioms.md`. Every "trap" below was run in Node v24 to confirm the output shown.
Collection methods and Date rules live in `js-cheatsheet.md`; this file is about *how to write it*.

## THE 10-SECOND MODEL
> **Find it by:** basics, model, types, primitives, const, let, var, mental model
- Values are `undefined`, `null`, booleans, numbers (all IEEE-754 doubles), BigInt, strings, symbols, objects. Arrays and functions are objects.
- Use `const` by default, `let` when you reassign, never `var`.
- `const` stops *rebinding*, not mutation. `const arr = []; arr.push(1)` is fine.

## EQUALITY AND FALSY VALUES
> **Find it by:** equality, compare, ===, ==, falsy, truthy, coercion, default, fallback, null, undefined, nullish
- Always `===` / `!==`. `==` coerces types (`0 == ''` and `null == undefined` are both true).
- Falsy: `false`, `0`, `-0`, `0n`, `''`, `null`, `undefined`, `NaN`. Everything else is truthy, including `[]` and `{}`.
- Default with `??` (only `null`/`undefined` trigger it). `||` also replaces `0` and `''`:
  ```js
  const port = 0;
  port || 8080   // 8080  (wrong: 0 is a real value)
  port ?? 8080   // 0
  ```
- `typeof null === 'object'` is a language bug kept for compatibility. Check `x === null` explicitly.

## OPTIONAL ACCESS AND DESTRUCTURING
> **Find it by:** optional chaining, safe access, destructure, unpack, default value, rename, rest, spread, ?.
- `obj?.a?.b` returns `undefined` instead of throwing. `fn?.()` calls only if it exists.
- Destructure with defaults and renaming:
  ```js
  const { name = 'anon', address: { city } = {} } = user;
  const [first, , third = 0, ...rest] = arr;
  ```
- Spread copies one level only (see the freeze/clone traps below).

## NUMBERS
> **Find it by:** float, precision, decimal, money, parse, parseInt, NaN, number conversion, radix, Number()
- `0.1 + 0.2 → 0.30000000000000004`. Money: store integer cents, never floats.
- Parse with an explicit radix and never pass `parseInt` straight into `map`:
  ```js
  ['1','2','3'].map(parseInt)          // [1, NaN, NaN]  (map passes (value, index); index became the radix)
  ['1','2','3'].map(s => parseInt(s, 10))  // [1, 2, 3]
  ```
- `Number('')` is `0`, `Number(' ')` is `0`, `Number('12px')` is `NaN`, `parseInt('12px')` is `12`. Pick deliberately.

## ARRAYS: MUTATION TRAPS
> **Find it by:** mutate, mutation, sort, comparator, reverse, immutable, toSorted, groupBy, forEach, async loop, iterate, for of, for in
- Default `.sort()` compares strings: `[10, 9, 1].sort() → [1, 10, 9]`. Always pass a comparator.
- `.sort()` and `.reverse()` mutate. Non-mutating versions: `.toSorted()`, `.toReversed()`, `.with()`, `.toSpliced()` (all verified in Node 24).
- `Object.groupBy(items, fn)` builds an object of arrays (verified in Node 24).
- `.forEach` ignores what its callback returns, so `async` callbacks are not awaited:
  ```js
  // BUG: returns before any wait finishes (verified)
  arr.forEach(async x => { await work(x) });

  // Sequential:
  for (const x of arr) await work(x);
  // Parallel, results in order:
  await Promise.all(arr.map(x => work(x)));
  ```
- `for...of` iterates values; `for...in` iterates enumerable keys (and inherited ones). Use `for...of` on arrays.

## OBJECTS: COPY AND FREEZE
> **Find it by:** clone, copy, deep copy, shallow copy, freeze, immutable, structuredClone, JSON clone, spread copy
- `Object.freeze` is shallow. Nested objects stay mutable (verified: `o.n.x` became `2` after freezing `o`).
- Deep copy: `structuredClone(obj)` keeps `Date` as a `Date` (verified). `JSON.parse(JSON.stringify(obj))` turns a `Date` into an ISO string and drops `undefined` fields (verified). Use `structuredClone` by default. It throws on functions.
- Copy with one change: `{ ...obj, field: next }`. Never `obj.field = next` on shared data.
- Keys: `Map` for non-string keys, insertion-ordered iteration, and a `.size` (see the cheatsheet).

## CLOSURES AND `this`
> **Find it by:** closure, this, arrow function, bind, scope, let vs var, loop variable, callback
- `let` in a loop gives each iteration its own binding. `var` shares one (classic `setTimeout` trap).
- Arrow functions take `this` from where they are written. Regular functions take it from the call site. Passing `obj.method` as a callback loses `this`; wrap it: `() => obj.method()`.

## ASYNC
> **Find it by:** promise, await, async, parallel, Promise.all, allSettled, race, timeout, error, reject, try catch, unhandled
- `async` functions always return a Promise, even on a plain `return`.
- Independent work runs in parallel with `Promise.all([...])`. Awaiting in sequence serializes it.
- `Promise.allSettled` when one failure should not hide the others. `Promise.race` for a timeout.
- Errors: wrap `await` in `try/catch`. An un-awaited rejected Promise is an unhandled rejection, and in Node it crashes the process by default.

## PREALLOCATE / INITIALIZE AN ARRAY OF OBJECTS (fixed length, one object per slot)
> **Find it by:** initialize, allocate, preallocate, create array, make array, fill, Array.from, new Array, length, array of maps, array of objects
- `new Array(n)` makes *holes*, and `.map` skips holes, so `new Array(3).map(() => new Map())` returns three holes:
  ```js
  new Array(3).map(() => new Map())        // [ <3 empty items> ]  (BUG)
  ```
- Use `Array.from` (calls the function once per index):
  ```js
  const maps = Array.from({ length: 3 }, () => new Map());   // 3 separate Maps
  const objs = Array.from({ length: 3 }, () => ({}));         // 3 separate objects
  const nums = Array.from({ length: 3 }, (_, i) => i * 2);    // [0, 2, 4]
  ```
- Or `fill` first (fills the holes), then `map` to build one object per slot:
  ```js
  const maps2 = new Array(3).fill(null).map(() => new Map());
  ```
- **Trap:** `fill` with an object shares one object across all slots (verified: `new Array(3).fill(new Map())` gives three references to one Map). Always use the function form for objects.
- A plain value per slot is fine with `fill`: `new Array(3).fill(0)`.

## CLONE-AND-PATCH CHECKLIST (the "don't mutate" tasks)
> **Find it by:** don't mutate, immutable update, copy then change, pure function, not mutate, update object
1. Copy the array with `[...arr]` before any in-place method.
2. Use `.map` / `.filter` / `.toSorted` instead of push/splice when the input must stay the same.
3. Copy nested objects you change: `{ ...order, items: [...order.items, next] }`.
4. Confirm by logging the original after the call.

## THE 3 THAT BITE MOST
> **Find it by:** traps, gotchas, pitfalls, mistakes, bugs, bite
1. `forEach` with `async` does not wait. Use `for...of` or `Promise.all`.
2. `||` replaces `0` and `''`. Use `??` for defaults.
3. `.sort()` mutates and sorts as strings. Pass a comparator, or copy first.
