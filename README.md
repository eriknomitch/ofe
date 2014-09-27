# Open For Editing (ofe)

CLI Gem which opens specified files (ofe.json) for editing in your text editor

## Installation

```Shell
git clone https://github.com/eriknomitch/ofe.git
cd ofe
rake
```

## Configuration

Add an `ofe.json` configuration file in any directory. 

The primary keys define "groups" which you can pass to `ofe` (see Usage).

Within groups, you can define keys:
* `"extensions":` Recursively searches your entire current directory for files with that extension to edit.
* `"files":` Either relative paths to files you want to open for editing or paths with globbing.
* `"exclusions":` Exclude any files starting with the exclusion paths specified.
* `"first_file":` Ensure that this file path is the first argument to your editor.

**Example ofe.json:**

```Json
{
  "default": {
    "extensions": [".rb", ".gem", ".md"],
    "files":      ["Rakefile", "Gemfile", "bin/*", "ofe.json", ".gitignore"],
    "exclusions": ["test/", "spec/"],
    "first_file": "Gemfile"
  },
  "docs": {
    "extensions": [".md"]
  },
  "git": {
    "files": [".git/config", ".gitignore"]
  },
  "test": {
    "files": ["test/**/*.rb", "spec/**/*.rb"]
  }
}
```

Match all files recursively in a directory and its subdirectories with:

```Json
{
  "my_group": {
    "files": ["my_directory/**/**"]
  }
}
```

Match all files with an extension recursively in a directory and its subdirectories with:

```Json
{
  "my_group": {
    "files": ["my_directory/**/*.ext"]
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
$ ofe --groups|-g

# Parses and pretty prints ofe.json
$ ofe --list|-l

# Parses and pretty prints group from ofe.json
$ ofe --list|-l git

# Writes an example config file to ./ofe.json
$ ofe --mk-example-config|-m

# Opens ofe.json in your editor
$ ofe --self|-s

```

## Credits
Erik Nomitch: erik@nomitch.com
