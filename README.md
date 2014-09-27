# Open For Editing (ofe)

CLI Gem which opens specified files (ofe.json) for editing in your text editor

## Installation

Not a published gem yet.

## Configuration

Add an `ofe.json` configuration file in any directory. 

The primary keys define "groups" which you can pass to `ofe` (see Usage).

Within groups, you can define keys:
* `"extensions":` Searches your entire current directory for files with that extension to edit.
* `"files":` Either relative paths to files you want to open for editing or paths with globbing.

**Example ofe.json:**

```Json
{
  "default": {
    "extensions": [".rb", ".gem", ".md"],
    "files":      ["Rakefile", "Gemfile", "bin/*", "ofe.json", ".gitignore", "foo bar"]
  },
  "docs": {
    "extensions": [".md"]
  },
  "git": {
    "files": [".git/config", ".gitignore"]
  }
}
```

## Usage

```Shell

# Opens the 'default' group in your editor (e.g., executes: vim Gemfile README.md [...])
$ ofe

# Opens the 'docs' group in your editor
$ ofe docs

# Lists all groups configured in ofe.json
$ ofe --groups

# Parses and pretty prints ofe.json
$ ofe --list

# Parses and pretty prints group 'git' in ofe.json
$ ofe --list git

# Writes an example config file to ./ofe.json
$ ofe --mk-example-config

```

## Tips

Alias `ofe` for quicker access:

```Shell
alias o="ofe"
```

## Credits
Erik Nomitch: erik@nomitch.com
