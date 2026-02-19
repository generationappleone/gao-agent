---
name: Shell Script (Bash/Zsh)
description: Skill for writing Unix/Linux shell scripts — covering Bash syntax, variables, control flow, functions, file operations, text processing (grep, awk, sed), process management, and automation patterns.
---

# Shell Script (Bash/Zsh) Skill

## Overview
Bash (Bourne Again SHell) is the standard shell for Linux/macOS automation. This skill covers POSIX-compatible shell scripting and Bash-specific features.

**Reference**: [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)

## Standard Template
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# Script: script-name.sh
# Description: Brief description
# Author: Your Name
# Version: 1.0.0
# ============================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/logs/script.log"

main() {
    log "INFO" "Starting script..."
    validate_prerequisites
    run_process "$@"
    log "INFO" "Completed successfully."
}

validate_prerequisites() {
    command -v node >/dev/null 2>&1 || { log "ERROR" "Node.js not found"; exit 1; }
    command -v npm >/dev/null 2>&1 || { log "ERROR" "npm not found"; exit 1; }
}

run_process() {
    local input="${1:?Usage: $0 <input-file>}"
    log "INFO" "Processing: ${input}"
}

log() {
    local level="$1"; shift
    local msg="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${msg}" | tee -a "${LOG_FILE}"
}

main "$@"
```

## Core Syntax
```bash
# Variables
NAME="John"               # No spaces around =
readonly VERSION="1.0.0"  # Constant
export PATH="/usr/local/bin:$PATH"
echo "${NAME}"             # Always use braces

# String operations
str="Hello World"
echo "${str,,}"      # lowercase: hello world
echo "${str^^}"      # UPPERCASE: HELLO WORLD
echo "${str:0:5}"    # Substring: Hello
echo "${str/World/Bash}"  # Replace: Hello Bash
echo "${#str}"       # Length: 11

# Arrays
arr=("apple" "banana" "cherry")
echo "${arr[0]}"     # First element
echo "${arr[@]}"     # All elements
echo "${#arr[@]}"    # Array length
arr+=("date")        # Append

# Associative arrays (Bash 4+)
declare -A config
config[host]="localhost"
config[port]="5432"
echo "${config[host]}"

# Arithmetic
count=$((10 + 5))
((count++))
```

## Control Flow
```bash
# If/elif/else
if [[ -f "$file" ]]; then
    echo "File exists"
elif [[ -d "$file" ]]; then
    echo "Directory exists"
else
    echo "Not found"
fi

# String comparison
[[ "$str" == "value" ]]    # Equal
[[ "$str" != "value" ]]    # Not equal
[[ "$str" =~ ^[0-9]+$ ]]   # Regex match
[[ -z "$str" ]]            # Empty
[[ -n "$str" ]]            # Not empty

# Numeric comparison
(( num > 10 ))
(( num == 10 ))

# File tests
[[ -f "$path" ]]  # Is file
[[ -d "$path" ]]  # Is directory
[[ -r "$path" ]]  # Is readable
[[ -w "$path" ]]  # Is writable
[[ -x "$path" ]]  # Is executable

# Case
case "$action" in
    start)  start_service ;;
    stop)   stop_service ;;
    *)      echo "Usage: $0 {start|stop}" ;;
esac

# For loop
for item in "${arr[@]}"; do echo "$item"; done
for file in *.txt; do echo "$file"; done
for i in {1..10}; do echo "$i"; done

# While loop
while IFS= read -r line; do
    echo "$line"
done < input.txt
```

## Functions
```bash
greet() {
    local name="${1:?Error: name required}"
    local greeting="${2:-Hello}"
    echo "${greeting}, ${name}!"
    return 0
}

# Call
greet "John" "Hi"
result=$(greet "Jane")
```

## Text Processing
```bash
# grep
grep -r "pattern" ./src/          # Recursive search
grep -rn "TODO" --include="*.ts"  # With line numbers
grep -E "error|warning" app.log   # OR pattern

# awk
awk '{print $1, $3}' data.txt           # Print columns
awk -F',' '{print $2}' data.csv         # CSV column
awk '/error/ {count++} END {print count}' app.log

# sed
sed 's/old/new/g' file.txt              # Replace all
sed -i 's/old/new/g' file.txt           # In-place edit
sed -n '10,20p' file.txt                # Print lines 10-20

# sort & uniq
sort file.txt | uniq -c | sort -rn      # Count unique, sort by frequency

# xargs
find . -name "*.log" | xargs rm -f
find . -name "*.ts" | xargs grep "TODO"

# jq (JSON processing)
curl -s https://api.example.com/users | jq '.data[].name'
echo '{"name":"John"}' | jq '.name'
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **`set -euo pipefail`** | Exit on error, undefined vars, pipe failures |
| **`#!/usr/bin/env bash`** | Portable shebang |
| **Quote variables** | Always: `"${VAR}"` to prevent word splitting |
| **`local` in functions** | Prevent variable leaking to global scope |
| **`readonly`** | For constants that should not change |
| **`[[ ]]`** | Preferred over `[ ]` (no word splitting/globbing) |
| **`$()` over backticks** | Command substitution: `$(cmd)` not `` `cmd` `` |
| **`shellcheck`** | Lint all scripts with ShellCheck |
| **Trap for cleanup** | `trap cleanup EXIT` for cleanup on exit |
| **Logging** | Use structured log function with level + timestamp |
