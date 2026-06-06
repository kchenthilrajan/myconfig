# Shell Command Exercises

Practice these in your terminal. Each exercise builds on the previous.

---

## Setup — create practice files first

Run this to create a practice directory:

```bash
mkdir -p ~/practice && cd ~/practice

# Create some files
echo -e "apple\nbanana\nApple\ncherry\nbanana\napricot" > fruits.txt
echo -e "name,age,city\nAlice,30,NYC\nBob,25,LA\nCharlie,35,NYC\nDave,25,Chicago" > people.csv
echo -e "ERROR: disk full\nINFO: started\nWARN: low memory\nERROR: timeout\nINFO: done" > app.log
echo '{"users":[{"name":"Alice","age":30},{"name":"Bob","age":25}],"count":2}' > data.json
mkdir -p src/components src/utils
echo "const fetch = require('fetch')" > src/utils/api.js
echo "import React from 'react'" > src/components/App.jsx
echo "import { fetch } from './api'" > src/components/Home.jsx
echo "// TODO: fix this\nconst x = 1" > src/utils/helpers.js
```

---

## Exercise 1 — find

**Goal:** Learn to find files by name, type, and date.

```bash
cd ~/practice

# 1a. Find all .js files
find . -name "*.js"

# 1b. Find only directories
find . -type d

# 1c. Find files modified in last 1 day
find . -mtime -1

# 1d. Find files larger than 1KB
find . -size +1k
```

**Challenge:** Find all files inside `src/` that end in `.jsx`

<details>
<summary>Answer</summary>

```bash
find src/ -name "*.jsx"
```
</details>

---

## Exercise 2 — grep basics

**Goal:** Search text inside files.

```bash
cd ~/practice

# 2a. Find "banana" in fruits.txt
grep "banana" fruits.txt

# 2b. Case insensitive search for "apple"
grep -i "apple" fruits.txt

# 2c. Show line numbers
grep -n "ERROR" app.log

# 2d. Invert match — lines WITHOUT "ERROR"
grep -v "ERROR" app.log

# 2e. Count matches
grep -c "ERROR" app.log
```

**Challenge:** Find all lines in `app.log` that are NOT INFO, and show line numbers.

<details>
<summary>Answer</summary>

```bash
grep -vn "INFO" app.log
```
</details>

---

## Exercise 3 — grep recursive & context

```bash
cd ~/practice

# 3a. Search across all files recursively
grep -r "fetch" .

# 3b. Show only filenames
grep -rl "fetch" .

# 3c. Whole word match (won't match "fetching")
grep -rw "fetch" .

# 3d. Show 1 line of context around match
grep -rn -C 1 "fetch" .
```

**Challenge:** Find all files that contain "import" but only in `.jsx` files.

<details>
<summary>Answer</summary>

```bash
grep -rl "import" --include="*.jsx" .
```
</details>

---

## Exercise 4 — ripgrep (rg)

**Goal:** Same as grep but faster, smarter defaults (ignores .git, node_modules).

```bash
cd ~/practice

# 4a. Basic search
rg "fetch"

# 4b. Case insensitive
rg -i "FETCH"

# 4c. Whole word
rg -w "fetch"

# 4d. Only in .js files
rg "fetch" --glob="*.js"

# 4e. Exclude .jsx files
rg "import" --glob="!*.jsx"

# 4f. Show only filenames
rg -l "TODO"

# 4g. Count matches per file
rg -c "import"
```

**Challenge:** Find all files containing "ERROR" or "WARN" in app.log using regex.

<details>
<summary>Answer</summary>

```bash
rg "ERROR|WARN" app.log
```
</details>

---

## Exercise 5 — sed (find & replace)

**Goal:** Replace text in files or streams.

```bash
cd ~/practice

# 5a. Replace first match per line (preview only)
sed 's/banana/mango/' fruits.txt

# 5b. Replace ALL matches per line
sed 's/banana/mango/g' fruits.txt

# 5c. Case insensitive replace
sed 's/apple/grape/I' fruits.txt

# 5d. Delete lines matching pattern
sed '/ERROR/d' app.log

# 5e. Print only lines 2 to 4
sed -n '2,4p' fruits.txt

# 5f. Edit file in-place
sed -i '' 's/banana/mango/g' fruits.txt
cat fruits.txt
```

**Challenge:** Replace "INFO" with "DEBUG" in app.log without modifying the original file.

<details>
<summary>Answer</summary>

```bash
sed 's/INFO/DEBUG/g' app.log
```
</details>

---

## Exercise 6 — awk (columns & calculations)

**Goal:** Process structured text by columns.

```bash
cd ~/practice

# 6a. Print first column (name)
awk -F, '{print $1}' people.csv

# 6b. Print name and city (columns 1 and 3)
awk -F, '{print $1, $3}' people.csv

# 6c. Print only rows where age is 25
awk -F, '$2 == 25' people.csv

# 6d. Print rows where city is NYC
awk -F, '$3 == "NYC"' people.csv

# 6e. Count total rows (excluding header)
awk -F, 'NR > 1 {count++} END {print count}' people.csv

# 6f. Sum the age column
awk -F, 'NR > 1 {sum += $2} END {print "Total age:", sum}' people.csv
```

**Challenge:** Print only the names of people older than 25.

<details>
<summary>Answer</summary>

```bash
awk -F, 'NR > 1 && $2 > 25 {print $1}' people.csv
```
</details>

---

## Exercise 7 — jq (JSON)

**Goal:** Parse and extract data from JSON.

```bash
cd ~/practice

# 7a. Pretty print
cat data.json | jq '.'

# 7b. Get count field
cat data.json | jq '.count'

# 7c. Get users array
cat data.json | jq '.users'

# 7d. Get all names
cat data.json | jq '.users[].name'

# 7e. Get first user
cat data.json | jq '.users[0]'

# 7f. Filter users older than 25
cat data.json | jq '.users[] | select(.age > 25)'
```

**Challenge:** Extract just the names of all users as a plain list.

<details>
<summary>Answer</summary>

```bash
cat data.json | jq -r '.users[].name'
```
(`-r` removes quotes)
</details>

---

## Exercise 8 — Pipes & Combos

**Goal:** Chain commands together.

```bash
cd ~/practice

# 8a. Sort fruits and remove duplicates
cat fruits.txt | sort | uniq

# 8b. Count occurrences of each fruit
cat fruits.txt | sort | uniq -c | sort -rn

# 8c. Find all ERROR lines and count them
grep "ERROR" app.log | wc -l

# 8d. Find .js files and count lines in each
find . -name "*.js" | xargs wc -l

# 8e. Search with rg and show only unique filenames
rg "import" -l | sort
```

**Challenge:** Find all unique cities from people.csv (excluding header).

<details>
<summary>Answer</summary>

```bash
tail -n +2 people.csv | awk -F, '{print $3}' | sort | uniq
```
</details>

---

## New Tools to Install

```bash
brew install fd bat fzf eza
```

| Tool | What it does | Example |
|---|---|---|
| `fd` | Faster, friendlier `find` | `fd "*.js" src/` |
| `bat` | `cat` with syntax highlighting | `bat file.js` |
| `fzf` | Fuzzy finder for anything | `history \| fzf` |
| `eza` | Better `ls` with colors/icons | `eza -la` |

### fd examples
```bash
fd "*.js"               # find JS files
fd -t f "*.log"         # only files
fd -t d src             # only directories
fd --exclude node_modules "*.ts"
```

### bat examples
```bash
bat file.js             # syntax highlighted view
bat -n file.js          # with line numbers
bat --diff file.js      # show git diff inline
```

### fzf examples
```bash
history | fzf           # fuzzy search history
fzf                     # fuzzy find files
cat fruits.txt | fzf    # fuzzy pick a line
```

### eza examples
```bash
eza -la                 # detailed list with icons
eza --tree              # tree view
eza -la --sort=size     # sort by size
```
