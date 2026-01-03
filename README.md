# 🐱 catree

A powerful bash utility for recursively displaying file contents with style. Think of it as rescuing a cat from a tree – walking down the directory structure and collecting all your files.

<img width="1463" height="776" alt="image" src="https://github.com/user-attachments/assets/8b7c4e66-3024-4931-bacb-dccecff2e2db" />

## ✨ Features

- 📁 Recursive file traversal through directories
- 🎨 Syntax highlighting support (bat, pygmentize, etc.)
- 🔍 Filter by file extensions (include/exclude)
- 🚫 Respect `.gitignore` patterns
- 📄 Display specific files or entire directory trees
- 🔒 Automatically excludes `.git` directory

## 📦 Installation

### Download with curl or wget
```bash
# Using curl
curl -o catall.sh https://raw.githubusercontent.com/luislve17/catree/main/catall.sh
chmod +x catall.sh

# Using wget
wget https://raw.githubusercontent.com/luislve17/catree/main/catall.sh
chmod +x catall.sh
```

### Install to system PATH
```bash
# Move to a directory accessible by all users
sudo mv catall.sh /usr/local/bin/catall
```

**Note:** Check the [Releases](https://github.com/luislve17/catree/releases) page for stable versions.

## 🚀 Quick Start
```bash
# Display all files
catall

# Show version
catall -v

# With syntax highlighting
catall -pipe "bat --paging=never --style=numbers,grid"

# Filter by extension
catall -inc "py,js,md"

# Respect .gitignore
catall -gitignore

# Specific files or folders
catall -f "README.md" -f "config.json"
catall -f src -f tests
```

## 📖 Options
```
-h              Show help
-v              Show version
-f PATH         Specific file or folder (repeatable)
-inc EXTS       Include extensions (comma-separated)
-exc EXTS       Exclude extensions (comma-separated)
-gitignore      Respect .gitignore patterns
-pipe CMD       Pipe through command (e.g., bat, pygmentize)
```

## 📝 License

MIT License

---

Made with ❤️ for clean terminal output

<a href='https://ko-fi.com/Q5Q0P976H' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi6.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
