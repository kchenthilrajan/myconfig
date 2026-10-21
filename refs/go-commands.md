# Go commands reference

Checked against `go version go1.26.5` (`go help <command>` for full details).

**Core workflow**
| Command | Does |
|---|---|
| `go run .` | compile and run the package in the current dir |
| `go run ./cmd/app` | run a specific package path |
| `go build -o bin/app ./cmd/app` | compile to a named binary |
| `go install ./cmd/app` | compile and put the binary in `$GOBIN` |
| `go test ./...` | test every package under the module |
| `go vet ./...` | report likely mistakes (static check, ships with Go) |
| `go fmt ./...` | rewrite sources with gofmt in place (`gofmt -l .` only lists unformatted files) |
| `go doc fmt.Println` | show docs for a package or symbol in the terminal |
| `go fix ./...` | apply fixes suggested by static checkers |

**Testing flags** (`go help testflag`)
| Flag | Does |
|---|---|
| `-run '^TestName$'` | run only tests matching a regex |
| `-v` | print each test as it runs |
| `-race ./...` | race detector (goes on `go test` and `go build`) |
| `-count=1` | disable test caching; forces a real run |
| `-cover` | print coverage percentage |
| `-bench .` | run benchmarks (`-benchmem` adds allocation stats) |
| `-fuzz FuzzName` | run a fuzz target |
| `-short` | skip long tests that check `testing.Short()` |
| `-shuffle on` | randomize test order (catches hidden ordering dependencies) |
| `-timeout 30s` | fail a test binary that runs longer than this |
| `-json` | machine-readable output |

Example: `go test -race -count=1 -run TestWorkerPool -v ./...`

**Modules** (`go help mod`)
| Command | Does |
|---|---|
| `go mod init example.com/app` | create `go.mod` |
| `go mod tidy` | add missing and drop unused deps (run before committing) |
| `go get github.com/x/y@v1.2.3` | add or upgrade a dependency |
| `go mod why -m github.com/x/y` | explain why a dependency is needed |
| `go mod graph` | print the dependency graph |
| `go mod vendor` | copy deps into `vendor/` |
| `go mod download` | pre-fetch modules into the cache |
| `go list -m all` | list every module in the build |

**Inspection and cleanup**
| Command | Does |
|---|---|
| `go env GOPATH GOMODCACHE` | print specific Go env values |
| `go version` | print the Go version |
| `go list ./...` | list package import paths |
| `go clean -testcache` | clear cached test results |
| `go tool pprof ...` | profile tool (after capturing a profile with `-cpuprofile`) |

**Concurrency-sensitive runs**
- `go test -race ./...` is the first thing to try on any goroutine bug.
- `go build -race` builds a binary that reports races at runtime.
