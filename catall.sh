#!/bin/bash

# catall.sh - Recursively concatenate all files in current directory
# Proof of Concept

# Default values
INCLUDE_EXTS=""
EXCLUDE_EXTS=""
USE_GITIGNORE=false
PIPE_CMD=""
FILES=()

# Function to show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Recursively concatenate all files in the current directory and subdirectories.

OPTIONS:
    -h          Show this help message
    -f FILE     Specific file to display (can be used multiple times)
    -inc EXTS   List of extensions to include (comma-separated, e.g., "txt,md,sh")
    -exc EXTS   List of extensions to exclude (comma-separated, e.g., "log,tmp")
    -gitignore  Respect .gitignore patterns and exclude ignored files
    -pipe CMD   Pipe each file through a command (e.g., "bat", "pygmentize -g")

EXAMPLES:
    $(basename "$0")                    # Cat all files
    $(basename "$0") -inc "txt,md"      # Only .txt and .md files
    $(basename "$0") -exc "log,tmp"     # Exclude .log and .tmp files
    $(basename "$0") -inc "sh" -exc "bak"   # Only .sh files, but exclude .bak files
    $(basename "$0") -gitignore         # Exclude files matching .gitignore patterns
    $(basename "$0") -pipe "bat --paging=never --style=numbers,grid"  # Display with bat
    $(basename "$0") -pipe "pygmentize -g"  # Display with pygmentize
    $(basename "$0") -f "src/main.py" -f "README.md"  # Only specific files
    $(basename "$0") -f "config.json" -pipe bat  # Single file with bat

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h)
            show_help
            exit 0
            ;;
        -f)
            FILES+=("$2")
            shift 2
            ;;
        -inc)
            INCLUDE_EXTS="$2"
            shift 2
            ;;
        -exc)
            EXCLUDE_EXTS="$2"
            shift 2
            ;;
        -gitignore)
            USE_GITIGNORE=true
            shift
            ;;
        -pipe)
            PIPE_CMD="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# If specific files are provided, process only those
if [ ${#FILES[@]} -gt 0 ]; then
    for file in "${FILES[@]}"; do
        if [ ! -f "$file" ]; then
            echo "Error: File not found: $file" >&2
            continue
        fi
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "▶ File: $file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if [ -n "$PIPE_CMD" ]; then
            eval "$PIPE_CMD \"$file\""
        else
            cat "$file"
        fi
        echo ""
    done
    exit 0
fi

# Build find command
FIND_CMD="find . -type f"

# Add include extensions if specified
if [ -n "$INCLUDE_EXTS" ]; then
    IFS=',' read -ra EXTS <<< "$INCLUDE_EXTS"
    FIND_CMD="$FIND_CMD \("
    for i in "${!EXTS[@]}"; do
        if [ $i -gt 0 ]; then
            FIND_CMD="$FIND_CMD -o"
        fi
        FIND_CMD="$FIND_CMD -name \"*.${EXTS[$i]}\""
    done
    FIND_CMD="$FIND_CMD \)"
fi

# Add exclude extensions if specified
if [ -n "$EXCLUDE_EXTS" ]; then
    IFS=',' read -ra EXTS <<< "$EXCLUDE_EXTS"
    for ext in "${EXTS[@]}"; do
        FIND_CMD="$FIND_CMD ! -name \"*.${ext}\""
    done
fi

# Handle gitignore filtering if requested
if [ "$USE_GITIGNORE" = true ]; then
    if command -v git &> /dev/null && git rev-parse --git-dir &> /dev/null 2>&1; then
        # We're in a git repo, use git ls-files
        echo "Using git to respect .gitignore patterns"
        echo "---"
        
        # Get all tracked and untracked files, excluding ignored ones
        git ls-files --cached --others --exclude-standard | while read -r file; do
            # Apply our extension filters
            SKIP=false
            
            # Check include extensions
            if [ -n "$INCLUDE_EXTS" ]; then
                IFS=',' read -ra EXTS <<< "$INCLUDE_EXTS"
                MATCH=false
                for ext in "${EXTS[@]}"; do
                    if [[ "$file" == *."$ext" ]]; then
                        MATCH=true
                        break
                    fi
                done
                if [ "$MATCH" = false ]; then
                    SKIP=true
                fi
            fi
            
            # Check exclude extensions
            if [ -n "$EXCLUDE_EXTS" ]; then
                IFS=',' read -ra EXTS <<< "$EXCLUDE_EXTS"
                for ext in "${EXTS[@]}"; do
                    if [[ "$file" == *."$ext" ]]; then
                        SKIP=true
                        break
                    fi
                done
            fi
            
            if [ "$SKIP" = false ] && [ -f "$file" ]; then
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "▶ File: $file"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                if [ -n "$PIPE_CMD" ]; then
                    eval "$PIPE_CMD \"$file\""
                else
                    cat "$file"
                fi
                echo ""
            fi
        done
        exit 0
    else
        echo "Warning: Not in a git repository or git not installed. Ignoring -gitignore flag." >&2
    fi
fi

# Execute and cat files with headers
echo "Executing: $FIND_CMD"
echo "---"

eval "$FIND_CMD" | while read -r file; do
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "▶ File: $file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ -n "$PIPE_CMD" ]; then
        eval "$PIPE_CMD \"$file\""
    else
        cat "$file"
    fi
    echo ""
done
