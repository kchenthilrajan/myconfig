# ref_go_idioms.md — Go Hands-On for Coding (the JS/Java-refugee's reflex kit)

> For **coding live in Go** (CoreWeave hands-on round, Tue 2026-08-18). The gap is **wiring/reflex**, not
> concepts — mental model + pattern recognition are already there. This sheet makes the SYNTAX reflexive so
> it doesn't eat working memory. **RUN everything** (go.dev/play or `go run f.go`) — fingers build the reflex.
> Built 2026-08-15. Keep it open while drilling.

## THE 10-SECOND MENTAL MODEL (coming from JS/Java)
> **Find it by:** model, basics, types, coming from JS, coming from Java
- **No classes** — `struct` (data) + methods hung on it. **No exceptions** — return an `error`, check it.
- **`for` is the only loop** (no `while`, no `do`). **No ternary.** **Capitalized = public/exported**, lowercase = private.
- **Zero values, not null:** `int`→0, `string`→`""`, `bool`→false, slice/map/pointer→`nil`. Vars are never "undefined."
- **`:=` declares + infers (inside funcs only); `var` anywhere.** `append` and map-writes are the two syntax traps.

---

## PROGRAM SKELETON (what you type first, every time)
> **Find it by:** skeleton, main, package, hello world, entry point, imports, template
```go
package main

import "fmt"

func main() {
    fmt.Println("hello")
}
// run:  go run file.go   (or paste into go.dev/play)
```
Multiple imports:
```go
import (
    "fmt"
    "sort"
    "strings"
    "strconv"
)
```

## DECLARE / ASSIGN
> **Find it by:** declare, variable, var, := short declaration, assign, zero value, initialize, init
```go
x := 5                 // short declare + infer (inside functions ONLY)
var y int              // zero value (0)
var z = "hi"           // inferred, works at package level too
const Pi = 3.14
a, b := 1, 2           // multiple
a, b = b, a            // swap (no temp)
```
`:=` needs at least one NEW var on the left; otherwise use `=`.

## FUNCTIONS
> **Find it by:** function, multiple return values, variadic, closure, defer, signature
```go
func add(a, b int) int { return a + b }          // shared type: (a, b int)
func divmod(a, b int) (int, int) { return a/b, a%b }   // multiple returns
q, r := divmod(17, 5)

func find(s []int, t int) (int, bool) {          // value + "found" flag (very common)
    for i, v := range s { if v == t { return i, true } }
    return -1, false
}
```

## ERROR HANDLING — the #1 Go idiom (no try/catch)
> **Find it by:** error, err, if err, wrap, errors.Is, errors.As, panic, return error, try catch
```go
n, err := strconv.Atoi("42")
if err != nil {
    return err            // or: log, or: return fmt.Errorf("bad input: %w", err)
}
// use n
```
**Reflex:** any call that can fail returns `(value, error)`. You write `if err != nil` immediately. That's the rhythm.

## SLICES — the array/list (your `[]`/ArrayList)
> **Find it by:** slice, append, make, initialize, allocate, preallocate, length, capacity, array, list, copy
```go
s := []int{1, 2, 3}          // literal
s := make([]int, 0)          // empty, len 0
s := make([]int, n)          // n zeros
s := make([]int, 0, n)       // len 0, cap n (preallocate)

s = append(s, 4)             // ★ MUST reassign — append may return a new slice
s = append(s, 5, 6)          // multiple
s = append(s, other...)      // spread another slice

len(s)                       // length
s[1:3]  s[:2]  s[2:]         // sub-slice (half-open, like JS slice)
last := s[len(s)-1]          // no negative indexing
s = s[:len(s)-1]             // pop last

// iterate
for i, v := range s { fmt.Println(i, v) }
for i := 0; i < len(s); i++ { }
for _, v := range s { }      // _ = ignore index

// 2D
grid := make([][]int, rows)
for i := range grid { grid[i] = make([]int, cols) }
```

## MAPS — the hashmap (your `{}`/HashMap)
> **Find it by:** map, make, initialize, hashmap, lookup, nil map, comma ok, delete, range
```go
m := map[string]int{}            // empty
m := make(map[string]int)        // same
m := map[string]int{"a": 1}      // literal

m["b"] = 2                       // set
v := m["a"]                      // get (ZERO value if absent — 0 here, not nil)
v, ok := m["a"]                  // ★ comma-ok: ok=true if key exists
if _, ok := m["a"]; ok { }       // membership check
delete(m, "a")                   // remove
len(m)

for k, v := range m { }          // iterate (NO order guarantee)

m["x"]++                         // count: works even if "x" absent (starts at 0) ★ handy
```

## SETS — no built-in; use a map
> **Find it by:** set, struct{}, unique, membership, dedupe, map as set
```go
set := map[int]bool{}
set[5] = true
if set[5] { }                    // present?
delete(set, 5)
// memory-lean variant: map[int]struct{}{}, add: set[5]=struct{}{}, check: _,ok:=set[5]
```

## STRINGS — immutable, UTF-8
> **Find it by:** string, rune, bytes, utf-8, strings.Builder, concat, index
```go
len(s)                           // BYTE length (not char count for non-ASCII)
s[i]                             // a BYTE, not a char
for i, r := range s { }          // r is a RUNE (Unicode char) — use for real chars
chars := []rune(s)               // to index characters
bytes := []byte(s)               // to mutate then string(bytes) back

// build (never += in a loop for big strings)
var sb strings.Builder
sb.WriteString("a"); sb.WriteByte('b'); sb.WriteRune('c')
result := sb.String()

// strings package
strings.Split("a,b,c", ",")      // []string
strings.Join(parts, "-")
strings.Contains(s, "x")  strings.HasPrefix(s, "x")  strings.HasSuffix(s, "x")
strings.ToLower(s)  strings.ToUpper(s)  strings.TrimSpace(s)  strings.Replace(s, "a", "b", -1)
strings.Fields(s)                // split on any whitespace (great for parsing)

// strconv (number <-> string)
n, err := strconv.Atoi("42")     // string -> int
str := strconv.Itoa(42)          // int -> string
f, err := strconv.ParseFloat("3.14", 64)
```

## STRUCTS + METHODS — the class/object
> **Find it by:** struct, method, receiver, class, object, constructor, initialize, new, embedding
```go
type Point struct { X, Y int }

p := Point{1, 2}                 // positional
p := Point{X: 1, Y: 2}          // named (prefer)
p.X = 5

// method: VALUE receiver (read-only copy)
func (p Point) Dist() int { return p.X*p.X + p.Y*p.Y }
// method: POINTER receiver (to MUTATE the struct)
func (p *Point) MoveX(d int) { p.X += d }

d := p.Dist()
p.MoveX(3)                       // Go auto-takes &p

// struct in a slice/map
pts := []Point{{1,2}, {3,4}}
byName := map[string]Point{}
```

## SORTING
> **Find it by:** sort, slices.Sort, sort.Slice, comparator, order
```go
sort.Ints(nums)                  // ascending ints
sort.Strings(strs)
sort.Slice(xs, func(i, j int) bool { return xs[i] < xs[j] })       // custom (i,j are INDICES)
sort.Slice(people, func(i, j int) bool { return people[i].Age < people[j].Age })
// descending: return xs[i] > xs[j]
```

## CONTROL FLOW
> **Find it by:** if, for, switch, loop, range, break, continue
```go
if x > 0 { } else if x < 0 { } else { }
if v, ok := m[k]; ok { }         // if with a short statement (very idiomatic)

for i := 0; i < n; i++ { }       // classic
for cond { }                     // this IS "while"
for { break }                    // infinite
for i, v := range coll { }       // range

switch x {                       // no break needed; cases don't fall through
case 1: ...
case 2, 3: ...                   // multiple values
default: ...
}
switch {                         // switch true — like if/else chain
case x < 0: ...
case x == 0: ...
}
```

## POINTERS (light — no arithmetic)
> **Find it by:** pointer, &, *, nil, address, dereference
```go
x := 10
p := &x          // pointer to x
*p = 20          // deref + set  → x is now 20
// used mostly for pointer receivers (mutation) and optional/nil semantics
```

## CONCURRENCY (in case it's systems-flavored — you know the model)
> **Find it by:** goroutine, go, channel, concurrency, concurrent, threads
```go
go doWork()                      // launch a goroutine (cheap thread)

ch := make(chan int, 5)          // buffered channel = a BlockingQueue
ch <- 42                         // send (blocks if full)
v := <-ch                        // receive (blocks if empty)
close(ch)                        // signal "no more"
for v := range ch { }            // receive until closed
// DEEP (CoreWeave Q: buffered vs unbuffered — answer at the real depth):
//   "blocked" = the goroutine is PARKED (descheduled, zero CPU) on the channel's
//     sendq; a receiver's drain frees a slot & wakes exactly one parked sender (handoff).
//     Same park-cheap/wake-instant idea as network long-polling, inside one process.
//   unbuffered (cap 0) = pure RENDEZVOUS — sender parks until a receiver is EXACTLY
//     ready; zero tolerance → backpressure on every item.
//   buffered (cap N)   = sender can get N AHEAD before parking; absorbs a burst of N,
//     THEN paces to the consumer. Buffer size = the KNOB for "how much burst before
//     backpressure" (= Kafka retention at nanosecond scale).
//   BACKPRESSURE CHAINS: a producer blocked on send isn't reading its OWN input →
//     that upstream fills & blocks too → ripples back to the true source, throttling
//     it to the slowest stage's pace. (Pipeline = a microcosm of Kafka-lag→scale→
//     front-door-throttle.) See [[ref_dataflow_patterns]] BACKPRESSURE.

var wg sync.WaitGroup            // = join / CountDownLatch
wg.Add(1); go func(){ defer wg.Done(); work() }(); wg.Wait()

var mu sync.Mutex                // = synchronized/lock
mu.Lock(); count++; mu.Unlock()
```

## SELECT — wait on multiple channels (distributed-systems staple)
> **Find it by:** select, channel, timeout, wait multiple channels
```go
select {
case v := <-ch1:       fmt.Println("from ch1:", v)
case v := <-ch2:       fmt.Println("from ch2:", v)
case ch3 <- x:         fmt.Println("sent to ch3")
case <-time.After(2 * time.Second):  fmt.Println("timeout")   // ★ timeout pattern
default:               fmt.Println("nothing ready")           // non-blocking
}
// loop until a done signal:
for {
    select {
    case job := <-jobs:  process(job)
    case <-done:         return
    }
}
```

## CONTEXT — cancellation / timeout / deadline (THE distributed-systems Go idiom)
> **Find it by:** context, cancel, timeout, deadline, cancellation
```go
import "context"

ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
defer cancel()                       // always cancel to free resources

// a worker respects cancellation:
func worker(ctx context.Context, jobs <-chan int) {
    for {
        select {
        case <-ctx.Done():           // canceled or timed out → stop
            return                    // ctx.Err() tells which
        case j := <-jobs:
            process(j)
        }
    }
}
// manual cancel: ctx, cancel := context.WithCancel(context.Background()); cancel()
```
**Reflex for this role:** any long/blocking/networked op takes a `ctx` and selects on `ctx.Done()`. That's how Go does timeouts and graceful shutdown — expect it.

## WORKER POOL — the canonical Go concurrency shape (likely to be asked)
> **Find it by:** worker pool, goroutine, waitgroup, fan out, concurrency shape
```go
func pool(numWorkers int, jobs <-chan int, results chan<- int) {
    var wg sync.WaitGroup
    for w := 0; w < numWorkers; w++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for j := range jobs {        // each worker pulls until jobs closed
                results <- j * j
            }
        }()
    }
    go func() { wg.Wait(); close(results) }()   // close results when all workers done
}
// caller: send jobs, close(jobs), range over results
```

---

## ★ CONCURRENCY PRIMITIVES — PARTITIONED BY PURPOSE (the storage map)
> **Find it by:** mutex, sync, WaitGroup, atomic, once, RWMutex, primitives
*Each solves a DIFFERENT problem. Partition by the question it answers.*
**Mnemonic: Communicate · Protect · Wait · Choose · Cancel.**

| Primitive | Question it answers | Core API |
|---|---|---|
| **Channel** | how do goroutines **pass data**? | `ch <- x` · `<-ch` · `close` · `range` |
| **Mutex** | how do I **protect shared state**? | `Lock` · `Unlock` |
| **WaitGroup** | how do I **wait until all finish**? | `Add` · `Done` · `Wait` |
| **select** | how do I **wait on several channels / timeout**? | `select { case ... }` |
| **context** | how do I **cancel/deadline a whole tree**? | `WithCancel/Timeout` · `Done()` · `cancel()` |

**① Channel — COMMUNICATE** (pass data): `ch := make(chan int, 5); ch <- 42; v := <-ch`. Buffered=queue, unbuffered=handoff.
**② Mutex — PROTECT** (guard shared state, one-at-a-time): `mu.Lock(); balance += x; mu.Unlock()`. Use when goroutines touch the SAME var.
**③ WaitGroup — WAIT for completion** (counter): `wg.Add(1); go func(){ defer wg.Done(); work() }(); wg.Wait()`.
**④ select — CHOOSE** (first-ready of several channels / timeout): `select { case v:=<-ch: ; case <-time.After(t): }`.
**⑤ context — CANCEL** (propagate stop/deadline down a tree): `ctx,cancel := context.WithTimeout(ctx,t); defer cancel(); select { case <-ctx.Done(): return ctx.Err(); ... }`.

**The 3 people confuse:**
- **WaitGroup vs Mutex:** WaitGroup = *"are they done yet?"* (waits for completion). Mutex = *"one at a time"* (guards data). Different jobs (both are `sync.`).
- **Channel vs Mutex** (both handle shared state): Channel = *"don't share — pass ownership"* (Go-preferred). Mutex = *"share, but guard."*
- **Channel vs select:** Channel = the pipe. select = wait on SEVERAL pipes at once (or add timeout).

**Where each slots in a worker pool:** channels (pass jobs/results) ① + WaitGroup (know when done) ③ + select-on-`ctx.Done()` (bail if canceled) ④⑤; a Mutex ② appears only if workers share a counter/map instead of using channels.

**Internals (up-the-game):** a `context` is a small struct = one `done chan struct{}` + a `children` set + an `err`, guarded by a `Mutex`. `cancel()` = record err → `close(done)` (a CLOSE broadcasts to ALL listeners, unlike a send) → recursively cancel children (cascade DOWN the tree). No WaitGroup, no job management — context is PASSIVE; goroutines cooperatively `select` on `ctx.Done()`. Cancellation = a doorbell, not a kill switch (Go can't force-stop a goroutine).

---

## TROUBLESHOOTING — the concurrency bugs they may hand you (the "evaluate + fix" leg)
> **Find it by:** race, deadlock, debug, bug, concurrency bug, evaluate, fix
*The invite says "evaluate and troubleshoot." Read Go and spot these — most bugs live here.*

| Bug | Symptom | Fix |
|---|---|---|
| **Data race** — 2+ goroutines write a shared map/var, no lock | random panic ("concurrent map writes") or wrong count | guard with `sync.Mutex`, or use a channel, or `sync/atomic` for a counter |
| **Deadlock** — send on unbuffered chan with no receiver (or all goroutines blocked) | `fatal error: all goroutines are asleep - deadlock!` | buffer the channel, or ensure a receiver runs, or close it |
| **Goroutine leak** — goroutine blocked forever on a channel nobody feeds/closes | memory grows; goroutine never exits | close the channel, or use `ctx.Done()` to signal exit |
| **WaitGroup misuse** — `wg.Add` inside the goroutine (race), or forgot `wg.Done()` | hang or premature exit | `wg.Add(1)` BEFORE `go`, `defer wg.Done()` first line |
| **Loop-var capture** (pre-Go1.22) — `go func(){ use(i) }()` in a loop | all goroutines see the last `i` | pass as arg: `go func(i int){...}(i)` |
| **nil map write** — `var m map[string]int; m["a"]=1` | panic: assignment to entry in nil map | `m := make(map[string]int)` first |
| **Ignored error** — `v, _ := f()` then use `v` blindly | wrong/zero value flows downstream | check `if err != nil` |
| **Unbuffered chan blocks producer** | producer stuck until consumer reads | buffer it, or start the consumer first |

**Debugging reflex:** `go run -race file.go` flags data races. In the room, *say* "I'd run with `-race`."

## PRODUCTION-GRADE HABITS (what "senior" looks like here — say + do these)
> **Find it by:** production, logging, testing, habits, senior
- **Check every error** (`if err != nil`) — never `_` a real error.
- **Validate inputs / handle edge cases** (empty slice, nil map, zero, boundaries) out loud.
- **Name clearly**, small functions, early returns.
- **Concurrency-safe by design** — name what's shared and how it's guarded.
- **Offer a quick test** — `func TestX(t *testing.T){ if got != want { t.Errorf(...) } }` reads as senior.
- **Clarify BEFORE coding** — restate the problem, ask constraints, propose approach, confirm, THEN type. (Pair-programming — the invite asks for this.)

---

## JS / JAVA-REFUGEE GOTCHAS (the reflex traps)
> **Find it by:** gotcha, trap, pitfall, nil, loop variable, coming from JS
| Trap | Right way |
|---|---|
| `while (cond)` | `for cond { }` — `for` is the only loop |
| `arr.push(x)` | `s = append(s, x)` — **reassign**, append can return a new slice |
| ternary `a ? b : c` | none — use a full `if` |
| `map.get(k)` missing → null | returns the **zero value** (0/""/false); use `v, ok := m[k]` to tell absent |
| exceptions / try-catch | `if err != nil { }` — errors are returned values |
| `public`/`private` keywords | **Capitalized name = exported**, lowercase = package-private |
| `s.length` / `s.length()` | `len(s)` (works for slice/map/string/array) |
| `list.get(i)` | `s[i]` (slices index directly) |
| negative index `s[-1]` | `s[len(s)-1]` |
| `==` on structs | works (value equality) for comparable fields; slices/maps NOT comparable with `==` |
| unused variable/import | **compile ERROR** — Go forbids unused vars/imports (use `_` to discard) |
| `i` leaks / `let` | `:=` is block-scoped; declare inside the loop is fine |

## THE 3 THAT BITE MOST (burn these in)
> **Find it by:** traps, gotchas, pitfalls, mistakes, bite
1. **`s = append(s, x)`** — forgetting the reassign is the #1 Go bug for newcomers.
2. **comma-ok for maps** — `v, ok := m[k]` to distinguish "absent" from "zero".
3. **`if err != nil`** — reflexively after every fallible call; it's the Go heartbeat.

## MICRO-DRILL (type these cold, run them, no peeking — ~15 min)
> **Find it by:** drill, practice, type cold
1. Read `[]int`, return the two indices that sum to a target (hashmap two-sum).
2. Count word frequencies in a sentence → `map[string]int`, print sorted by count.
3. Reverse a string correctly (hint: `[]rune`).
4. Struct `Task{Name string; Priority int}`; sort a `[]Task` by priority desc.
5. Producer sends 1..10 on a channel; consumer prints them; use WaitGroup.

## LIVE-CODING FOOTGUNS (banked from Netskope Technical Depth round, 2026-09-30)
> **Find it by:** live coding, footgun, interview, mistakes

| Trap | Mechanism | Fix |
|---|---|---|
| **Typed nil through an interface return** — `var err *CustomError = nil; return err` where the fn returns `error` | An interface is a `(type, value)` pair. The returned interface is `(*CustomError, nil)`, not `(nil, nil)` — the type half is non-nil, so `err != nil` is **true** even though the pointer is nil | Declare the variable as `error`, not the concrete pointer type — or return the literal `nil` directly in the success path, never a variable that might currently hold a typed nil |
| **Goroutine leak via unbuffered channel + context timeout** — a spawned goroutine sleeps then sends on an unbuffered `chan`; caller's `select` races it against `ctx.Done()` | If `ctx` wins the race, the function returns and nobody will ever receive on that channel again. The goroutine's later send **blocks forever** — a permanent leak, every time the timeout fires | Buffer the channel (`make(chan T, 1)`) so a late send can land without a receiver, **or** wrap the sender itself in a `select` against `ctx.Done()` so it can abandon the send |
| **Value receiver on a struct holding a `sync.Mutex`/`RWMutex`** — `func (c MetricsCache) GetTags(...)` on a struct with a `sync.RWMutex` field | A value receiver **copies the whole struct**, including the mutex, before locking — the lock operates on the copy, providing **zero** real protection against a concurrent writer using a pointer receiver | Always use a pointer receiver (`*MetricsCache`) on any method of a struct that embeds a mutex; `go vet`'s copylocks checker exists specifically to catch this |

*Companion to `ref_java_idioms.md` (same structure, Java) and `ref_concurrency.md` (the concurrency concepts).* 
