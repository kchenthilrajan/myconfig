# JavaScript commands reference (Node + npm)

Checked against `node v24.19.0` and `npm 11.17.0`.

**Running code**
| Command | Does |
|---|---|
| `node app.js` | run a script |
| `node -e "console.log(1+1)"` | run an inline snippet |
| `node -c app.js` / `node --check app.js` | syntax-check only, don't run |
| `node --watch app.js` | restart the script when it changes |
| `node --watch-path=./src app.js` | watch a specific path instead |
| `node --env-file=.env app.js` | load env vars from a file |
| `node --inspect app.js` | start with the debugger listening (open `chrome://inspect`) |
| `node --inspect-brk app.js` | same, but pause on the first line |

**Built-in test runner** (`node --test`)
| Command | Does |
|---|---|
| `node --test` | run test files matching the default patterns |
| `node --test --watch` | rerun tests on change |
| `node --test path/to/file.test.js` | run one file |

**npm: packages and scripts**
| Command | Does |
|---|---|
| `npm init -y` | create `package.json` with defaults |
| `npm install` | install everything in `package.json` |
| `npm install lodash` | add a runtime dependency |
| `npm install -D vitest` | add a dev dependency |
| `npm uninstall lodash` | remove a dependency |
| `npm ci` | clean install from the lockfile (use in CI) |
| `npm update` | update within semver ranges |
| `npm outdated` | list packages with newer versions |
| `npm ls --depth=0` | list top-level installed packages |
| `npm explain lodash` | why a package is installed |
| `npm audit` | known-vulnerability report |
| `npm info lodash version` | look up registry metadata |
| `npm run build` | run the `build` script from `package.json` |
| `npm test` | run the `test` script (shortcut, no `run` needed) |
| `npm run` | list the available scripts |
| `npm pkg get scripts` | read a `package.json` field |

**npx** (run a package's binary without installing it globally)
| Command | Does |
|---|---|
| `npx prettier --check .` | run a package's CLI |
| `npx -y create-vite@latest` | skip the install prompt |
| `npm exec -- eslint .` | same as npx, explicit form |

**Gotchas**
- `npm install` updates the lockfile; `npm ci` refuses to run if `package.json` and the lockfile disagree.
- `node --test` with no arguments uses default file patterns (`*.test.js`, `test/` dir); pass a path to be explicit.
