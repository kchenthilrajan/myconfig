# Shell Commands Reference

## File & Directory Navigation
| Command | Description |
|---|---|
| `ls -la` | List all files with details |
| `ls -lh` | List with human readable sizes |
| `pwd` | Print current directory |
| `cd -` | Go to previous directory |
| `mkdir -p a/b/c` | Create nested directories |
| `tree` | Show directory tree (brew install tree) |

## File Search (find)
| Command | Description |
|---|---|
| `find . -name "*.js"` | Find files by name pattern |
| `find . -type f -name "*.log"` | Find only files |
| `find . -type d -name "src"` | Find only directories |
| `find . -mtime -1` | Files modified in last 1 day |
| `find . -size +10M` | Files larger than 10MB |
| `find . -name "*.log" -delete` | Find and delete files |
| `find . -name "*.js" -exec wc -l {} \;` | Find and run command on each |

## File Operations
| Command | Description |
|---|---|
| `cp -r src/ dest/` | Copy directory recursively |
| `mv file.txt newname.txt` | Rename or move file |
| `rm -rf folder/` | Delete folder recursively |
| `ln -s /path/to/file link` | Create symlink |
| `wc -l file.txt` | Count lines in file |
| `wc -w file.txt` | Count words in file |
| `du -sh folder/` | Disk usage of folder |
| `df -h` | Disk usage of filesystem |

## Viewing Files
| Command | Description |
|---|---|
| `cat file.txt` | Print file contents |
| `less file.txt` | Scroll through file (q to quit) |
| `head -20 file.txt` | Show first 20 lines |
| `tail -20 file.txt` | Show last 20 lines |
| `tail -f file.log` | Follow file in real-time |

## grep
| Command | Description |
|---|---|
| `grep "pattern" file.txt` | Search in file |
| `grep -r "pattern" src/` | Search recursively |
| `grep -i "pattern" file.txt` | Case insensitive |
| `grep -n "pattern" file.txt` | Show line numbers |
| `grep -w "word" file.txt` | Whole word match |
| `grep -l "pattern" *.js` | Show only filenames |
| `grep -v "pattern" file.txt` | Invert match — show lines that do NOT contain pattern |
| `grep -v "^#" file.txt` | Hide comment lines (lines starting with #) |
| `grep -v "^$" file.txt` | Hide blank lines |
| `grep -v "^#\|^$" file.txt` | Hide both comment and blank lines |
| `grep -v -e "^#" -e "DEBUG" file.txt` | Exclude multiple patterns with -e |
| `docker logs app \| grep -v "DEBUG\|INFO"` | Filter noise from logs in a pipe |
| `grep -A 2 "pattern" file.txt` | Show 2 lines after match |
| `grep -B 2 "pattern" file.txt` | Show 2 lines before match |
| `grep -C 2 "pattern" file.txt` | Show 2 lines context |
| `grep -E "foo\|bar" file.txt` | Extended regex (OR) |

## ripgrep (rg) — faster grep with better defaults

### Basics
| Command | Description |
|---|---|
| `rg "pattern"` | Search recursively in current directory |
| `rg "pattern" ~/some/other/folder` | Search in a specific folder (from anywhere) |
| `rg "pattern" ~/folder -d 1` | Search only in that folder, NOT subdirectories (`-d 1` = max depth 1) |
| `rg "pattern" file.txt` | Search in a single file |
| `rg "pattern" file1.txt file2.txt` | Search in multiple specific files |
| `rg -i "pattern"` | Case insensitive |
| `rg -w "pattern"` | Whole word only |
| `rg -F "pattern"` | Literal string — no regex (useful for dots, brackets, etc.) |
| `rg -v "pattern"` | Invert match — lines that do NOT match |

### Output control
| Command | Description |
|---|---|
| `rg -l "pattern"` | Show only filenames with matches |
| `rg --files-without-match "pattern"` | Show files with NO match |
| `rg -n "pattern"` | Show line numbers (on by default) |
| `rg -c "pattern"` | Count matching lines per file |
| `rg --count-matches "pattern"` | Count individual matches per file (not lines) |
| `rg -o "pattern"` | Print only the matched part, not the whole line |
| `rg -p "pattern"` | Pretty output with color + line numbers (good for piping) |
| `rg --no-heading "pattern"` | Print filename on each line (grep-style, no grouping) |
| `rg -H "pattern"` | Always show filename per line |

### Context lines
| Command | Description |
|---|---|
| `rg -C 2 "pattern"` | Show 2 lines before AND after match |
| `rg -A 2 "pattern"` | Show 2 lines after match |
| `rg -B 2 "pattern"` | Show 2 lines before match |

### Filtering by file type / glob
| Command | Description |
|---|---|
| `rg -t js "pattern"` | Only JS files (built-in type) |
| `rg -T js "pattern"` | Exclude JS files |
| `rg --type-list` | List all supported file type names |
| `rg -g "*.ts" "pattern"` | Only `.ts` files (glob) |
| `rg -g "!*.test.js" "pattern"` | Exclude test files |
| `rg -g "!node_modules/**" "pattern"` | Exclude a folder via glob |
| `rg -g "!{node_modules,dist}/**" "pattern"` | Exclude multiple folders |

### Depth / directory control
| Command | Description |
|---|---|
| `rg "pattern" ~/folder -d 1` | Only direct children of folder, no subdirectories |
| `rg "pattern" ~/folder -d 2` | Up to 2 levels deep |
| `rg "pattern" ~/folder --max-depth 1` | Same as `-d 1`, long form |

### Hidden & ignored files
| Command | Description |
|---|---|
| `rg -. "pattern"` | Include hidden files/folders (dotfiles) |
| `rg --no-ignore "pattern"` | Ignore .gitignore / .rgignore rules |
| `rg -u "pattern"` | Unrestricted — same as `--no-ignore` |
| `rg -uu "pattern"` | Also include hidden files |
| `rg -uuu "pattern"` | Also include binary files |

### Replace / transform output
| Command | Description |
|---|---|
| `rg "pattern" -r "replacement"` | Print with matches replaced (does NOT edit files) |
| `rg "(foo)" -r '$1_bar'` | Backreference in replacement |
| `rg "pattern" -o -r "[$0]"` | Wrap each match in brackets |

### Multiline
| Command | Description |
|---|---|
| `rg -U "start.*end"` | Multiline match (`.` matches newline too with `--multiline-dotall`) |
| `rg -U --multiline-dotall "start.*end"` | Dot matches newlines in multiline mode |

### Useful combos
| Command | Description |
|---|---|
| `rg "pattern" -l \| xargs wc -l` | Count lines in all matching files |
| `rg "pattern" -l \| xargs rg "other"` | Chain searches — find files, search again |
| `rg "TODO" ~/project -g "!node_modules/**" -n` | Find TODOs, skip node_modules |
| `rg "pattern" ~/folder -d 1 -l` | Files in specific folder (no recursion) that match |
| `rg "pattern" -t js -t ts` | Search in both JS and TS files |
| `rg -w -i "pattern"` | Whole word + case insensitive |
| `rg "pattern" --json \| jq '.data.lines.text'` | JSON output for scripting |

## sed (stream editor — find & replace)
| Command | Description |
|---|---|
| `sed 's/foo/bar/' file.txt` | Replace first match per line |
| `sed 's/foo/bar/g' file.txt` | Replace all matches |
| `sed -i 's/foo/bar/g' file.txt` | Replace in-place — edits and saves the file with the same name (Linux) |
| `sed -i '' 's/foo/bar/g' file.txt` | Same but macOS requires empty string `''` after `-i`, else it errors |
| `sed -i.bak 's/foo/bar/g' file.txt` | In-place but saves original as `file.txt.bak` before replacing |
| `sed -n '5,10p' file.txt` | Print lines 5 to 10 |
| `sed '/pattern/d' file.txt` | Delete lines matching pattern |
| `sed 's/^/# /' file.txt` | Add `# ` to start of every line |

## awk (column-based text processing)
| Command | Description |
|---|---|
| `awk '{print $1}' file.txt` | Print first column |
| `awk '{print $1, $3}' file.txt` | Print columns 1 and 3 |
| `awk -F: '{print $1}' /etc/passwd` | Use `:` as delimiter |
| `awk '/pattern/ {print}' file.txt` | Print lines matching pattern |
| `awk '{sum += $1} END {print sum}' file.txt` | Sum first column |
| `awk 'NR==5' file.txt` | Print line number 5 |
| `awk 'NR>=5 && NR<=10' file.txt` | Print lines 5 to 10 |

## Pipes & Redirection
| Command | Description |
|---|---|
| `cmd1 \| cmd2` | Pipe output of cmd1 to cmd2 |
| `cmd > file.txt` | Redirect output to file (overwrite) |
| `cmd >> file.txt` | Append output to file |
| `cmd 2>&1` | Redirect stderr to stdout |
| `cmd 2>/dev/null` | Suppress error output |
| `cmd &> file.txt` | Redirect both stdout and stderr to file |
| `cmd < file.txt` | Use file as stdin input |

## tee (split output to screen + file)
| Command | Description |
|---|---|
| `cmd \| tee file.txt` | Print to screen AND save to file |
| `cmd \| tee -a file.txt` | Print to screen AND append to file |
| `cmd \| tee file.txt \| grep "error"` | Save full output, filter what's shown |
| `cmd \| tee file1.txt file2.txt` | Write to multiple files simultaneously |
| `cmd \| tee >(other-cmd)` | Pipe to another command via process substitution |

### Real examples
| Command | Description |
|---|---|
| `./run-tests.sh \| tee test.log` | Watch tests live + save full log |
| `npm run build \| tee build.log` | See build output + keep a log |
| `curl -s url \| tee response.json \| jq '.'` | Save raw JSON + pretty print it |
| `cmd \| tee output.txt \| wc -l` | Save output and count lines at once |

## watch (repeat a command on interval)
| Command | Description |
|---|---|
| `watch -n 2 "ls -lh"` | Re-run command every 2 seconds |
| `watch -n 1 "df -h"` | Monitor disk usage live |
| `watch -d "ls -l"` | Highlight what changed between runs |
| `watch -n 5 "ps aux \| grep node"` | Watch a process every 5s |

## xargs (build commands from stdin)
| Command | Description |
|---|---|
| `find . -name "*.log" \| xargs rm` | Delete all found files |
| `cat list.txt \| xargs mkdir` | Create directories from a list |
| `find . -name "*.js" \| xargs wc -l` | Count lines across many files |
| `echo "a b c" \| xargs -n1 echo` | One argument per line |
| `cat urls.txt \| xargs -I{} curl -s {}` | Use `{}` as placeholder per line |
| `find . -name "*.txt" \| xargs -P4 gzip` | Run 4 parallel gzip jobs |

## Useful Combos
| Command | Description |
|---|---|
| `rg "TODO" -l \| xargs wc -l` | Count lines in files with TODOs |
| `find . -name "*.log" \| xargs rm` | Delete all log files |
| `grep -r "pattern" . \| awk -F: '{print $1}' \| sort -u` | Unique files with match |
| `cat file.txt \| sort \| uniq -c \| sort -rn` | Count + sort unique lines |
| `ls -la \| awk '{print $5, $9}'` | Show size and filename only |

## Archive & Compression (zip / tar / gzip)

### zip
| Command | Description |
|---|---|
| `zip -r archive.zip folder/` | Zip a folder recursively |
| `zip archive.zip file1 file2` | Zip specific files |
| `zip -r archive.zip folder/ -x "*.DS_Store"` | Zip folder, exclude a pattern |
| `zip -rj archive.zip folder/` | Zip folder but flatten (no directory structure) |
| `zip -r -9 archive.zip folder/` | Max compression (1=fast, 9=best) |

### unzip
| Command | Description |
|---|---|
| `unzip archive.zip` | Extract to current directory |
| `unzip archive.zip -d /path/to/dest/` | Extract to specific directory |
| `unzip -l archive.zip` | List contents without extracting |
| `unzip -o archive.zip` | Overwrite files without prompting |
| `unzip -n archive.zip` | Never overwrite existing files |
| `unzip archive.zip "folder/*"` | Extract only files matching pattern |

### tar (tape archive)
| Command | Description |
|---|---|
| `tar -czf archive.tar.gz folder/` | Create gzip-compressed archive |
| `tar -cjf archive.tar.bz2 folder/` | Create bzip2-compressed archive |
| `tar -xzf archive.tar.gz` | Extract .tar.gz to current directory |
| `tar -xzf archive.tar.gz -C /dest/` | Extract to specific directory |
| `tar -tzf archive.tar.gz` | List contents without extracting |
| `tar -xzf archive.tar.gz file.txt` | Extract single file from archive |
| `tar -czf archive.tar.gz --exclude="node_modules" folder/` | Exclude a folder |

### gzip / gunzip
| Command | Description |
|---|---|
| `gzip file.txt` | Compress file (replaces original with file.txt.gz) |
| `gzip -k file.txt` | Compress and keep original |
| `gunzip file.txt.gz` | Decompress .gz file |
| `gzip -d file.txt.gz` | Same as gunzip |
| `gzip -l file.txt.gz` | Show compression info |

## SSH & System Admin
| Command | Description |
|---|---|
| `passwd` | Change current user's password |
| `/etc/rc.d/init.d/sshd restart` | Restart SSH daemon (SysV init) |
| `cat > .ssh/authorized_keys` | Write SSH public key (paste then Ctrl+D) |
| `vi .ssh/authorized_keys` | Edit authorized SSH keys |
| `chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys` | Fix SSH key permissions |
| `ssh-keygen -t ed25519 -C "email"` | Generate new SSH keypair |
| `ssh-copy-id user@host` | Copy public key to remote host |

## jq (JSON processing)
| Command | Description |
|---|---|
| `cat file.json \| jq '.'` | Pretty print JSON |
| `cat file.json \| jq '.key'` | Extract a key |
| `cat file.json \| jq '.items[]'` | Iterate array |
| `cat file.json \| jq '.items[].name'` | Extract field from array |
| `cat file.json \| jq 'keys'` | List all top-level keys |
| `cat file.json \| jq 'length'` | Count items in array |
| `cat file.json \| jq '.[] \| select(.status == "running")'` | Filter by field value |
| `cat file.json \| jq '{id: .id, name: .name}'` | Reshape — pick specific fields |
| `cat file.json \| jq '.[] \| {id, name}'` | Shorthand reshape from array |
| `curl -s url \| jq '.data'` | Parse API response |
| `docker inspect myapp \| jq '.[0].NetworkSettings.Ports'` | Docker port mapping |
| `cat package.json \| jq '.dependencies \| keys'` | List dependency names |
| `rg "pattern" --json \| jq '.data.lines.text'` | Parse rg JSON output |

## Process & Port Management
| Command | Description |
|---|---|
| `lsof -i :3000` | What process is using port 3000 |
| `lsof -i :3000 -t` | Just the PID of process on port 3000 |
| `kill $(lsof -ti :3000)` | Kill whatever is on port 3000 |
| `ps aux \| grep node` | Find node processes |
| `ps -p <pid> -o pid,command` | Show command for a specific PID |
| `kill <pid>` | Kill a process by PID |
| `kill -9 <pid>` | Force kill (SIGKILL) |
| `kill %%` | Kill last background job |
| `pkill -f "node server"` | Kill by process name pattern |
| `lsof -i -P \| grep LISTEN` | All listening ports |

## curl (HTTP requests)
| Command | Description |
|---|---|
| `curl -s url` | Silent GET request |
| `curl -s url \| jq '.'` | GET + pretty print JSON response |
| `curl -X POST url -H "Content-Type: application/json" -d '{}'` | POST with JSON body |
| `curl -u "user:password" url` | Basic auth |
| `curl -H "Authorization: Bearer <token>" url` | Bearer token auth |
| `curl -o file.zip url` | Download to file |
| `curl -I url` | Show response headers only |
| `curl -v url` | Verbose — show request + response headers |
| `curl -s url -w "%{http_code}"` | Show only HTTP status code |

## nvm / node version management
| Command | Description |
|---|---|
| `nvm list` | List installed node versions |
| `nvm use v20` | Switch to node v20 |
| `nvm install v20` | Install node v20 |
| `nvm current` | Show active version |
| `node -v` | Show current node version |
| `npm cache clean --force` | Clear npm cache |
| `rm -rf node_modules package-lock.json && npm install` | Full clean reinstall |

## pyenv / python version management
| Command | Description |
|---|---|
| `pyenv install 3.11` | Install Python 3.11 |
| `pyenv shell 3.11.15` | Use version for current shell session |
| `pyenv versions` | List installed versions |
| `python --version` | Show active version |
| `poetry install` | Install dependencies from pyproject.toml |
| `poetry env use 3.11` | Set Python version for poetry env |
| `poetry run python -m app.main` | Run app inside poetry env |
| `poetry config virtualenvs.in-project true` | Keep venv inside project folder |

## AWS CLI
| Command | Description |
|---|---|
| `aws sts get-caller-identity` | Verify current AWS identity |
| `aws configure set region us-east-2 --profile bedrock_api` | Set region for a profile |
| `export AWS_PROFILE=bedrock_api` | Switch active profile for session |
| `cat ~/.aws/credentials` | View stored credentials |
| `cat ~/.aws/config` | View config profiles |
| `duo-sso` | Refresh Cisco Duo SSO session |
