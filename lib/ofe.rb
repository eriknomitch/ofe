# ================================================
# OFE ============================================
# ================================================
#require "bundler"
require "json"
require "shellwords"
require "tsort"
require "readline"

require "active_support/core_ext/module"
require "active_support/core_ext/object/blank"

require "ofe/t_sorted_files"

require "pry"

#binding.pry

# ------------------------------------------------
# MODULE->OFE ------------------------------------
# ------------------------------------------------
module Ofe

  # ----------------------------------------------
  # CONSTANTS ------------------------------------
  # ----------------------------------------------
  VERSION = ::Gem.loaded_specs["ofe"].version.to_s

  # ----------------------------------------------
  # ATTRIBUTES -----------------------------------
  # ----------------------------------------------
  mattr_accessor :configuration

  # ----------------------------------------------
  # UTILITY --------------------------------------
  # ----------------------------------------------
  def self.current_file_basename
    File.basename $0
  end

  def self.parse_and_execute_special_arguments
    case ARGV.first
    when "--list", "-l"
      list ARGV[1..ARGV.length-1]
      exit

    when "--groups", "-g"
      list_group_names
      exit

    when "--mk-example-config", "-m"
      make_example_config_file
      exit
    
    when "--self", "-s"
      open_self
      exit
    
    when "--help", "-h"
      help
      exit

    end
  end

  # ----------------------------------------------
  # UTILITY->ERRORS ------------------------------
  # ----------------------------------------------
  def self.raise_group_not_found(group)
    raise "Group '#{group}' not found in ofe.json.  Try '#{current_file_basename} --list' to list groups or '#{current_file_basename} --help'."
  end

  # ----------------------------------------------
  # HELP/USAGE -----------------------------------
  # ----------------------------------------------
  def self.help
    puts "usage: #{current_file_basename} [--version|-v] [--list|-l] [--groups|-g]"
    puts "           [--mk-example-config|-m] [--self|-s] [--help|-h]"
  end

  # ----------------------------------------------
  # LISTING --------------------------------------
  # ----------------------------------------------
  def self.list(argv)
    require_and_parse_config_file

    # Support and check for "--list <group>"
    if group = argv.first
      to_puts = configuration[group]

      raise_group_not_found group unless to_puts

    # <group> was not passed
    else
      to_puts = configuration
    end

    puts JSON.pretty_generate(to_puts)
  end

  def self.group_names
    require_and_parse_config_file

    configuration.keys
  end

  def self.list_group_names
    puts group_names
  end

  def self.make_example_config_file
    raise "Cannot make config file because ofe.json already exists in this directory." if config_file_exists?

    empty_config_file = <<-EOS
{
  "default": {
    "extensions": [],
    "files":      ["ofe.json"]
  },
  "docs": {
    "extensions": [".md"]
  },
  "git": {
    "files": [".git/config", ".gitignore"]
  }
}
    EOS

    File.open(config_file_filename, "w") do |file|
      file.puts empty_config_file
    end

    puts "Example ofe.json file:"
    puts "--------------------------------------------------"
    puts empty_config_file
    puts "--------------------------------------------------"
    puts "Wrote example config file to ofe.json"

  end

  def self.open_self
    require_config_file

    system "#{editor} #{config_file_filename}"
  end

  def self.require_editor_env_variable
    unless ENV["EDITOR"]
      raise "EDITOR environment variable is not set."
    end
  end

  def self.editor
    ENV["EDITOR"]
  end

  def self.ensure_group_key_is_class_if_exists(group, group_config, key, compare_class)
    if group_config[key] and group_config[key].class != compare_class
      raise "Config key '#{key}' is not class #{compare_class} for group '#{group}'."
    end
  end

  def self.file_should_be_excluded?(file, exclusions)
    exclusions.each do |exclusion|
      return true if file.start_with?(exclusion)
    end
    false
  end
  
  # ----------------------------------------------
  # CONFIG-FILE ----------------------------------
  # ----------------------------------------------
  def self.config_file_filename
    "ofe.json"
  end

  def self.config_file_exists?
    File.exist? config_file_filename
  end

  def self.require_config_file
    return true if config_file_exists?

    raise "fatal: No ofe.json config file found in this directory."
  end

  def self.require_and_parse_config_file
    require_config_file

    begin

      self.configuration = JSON.parse(File.open(config_file_filename).read)
    
    rescue => exception
      raise "Cannot parse ofe.json because its JSON is invalid."
    end

  end

  def self.find_group_config(group)
    configuration[group.to_s]
  end

  # ----------------------------------------------
  # GROUP ----------------------------------------
  # ----------------------------------------------
  def self.get_group
    return :default if ARGV.count == 0

    group_match = ARGV.first

    # Return the group if we have an exact match
    return group_match.to_sym if group_names.member? group_match

    # Otherwise, try to fuzzy match
    group_names.each do |group_name|
      if group_name.start_with? group_match
        printf "Fuzzy matched group '#{group_name}'. Press ENTER to open: "
        begin
          Readline.readline
          return group_name.to_sym
        rescue Interrupt
          exit 0
        end
      end
    end

    raise_group_not_found group_match
  end

  def self.format_files_to_open(files)
    Shellwords.join(files)
  end

  def self.files_to_open_for_group(group, formatted: false)
    group_config = find_group_config(group)

    raise_group_not_found group unless group_config

    files      = group_config["files"]
    extensions = group_config["extensions"]
    exclusions = group_config["exclusions"]
    first_file = group_config["first_file"]
    command    = group_config["command"]
    topology   = group_config["topology"]

    to_open    = []

    # Check that at least one definition exists
    raise "Neither files: nor extensions: is defined for group '#{group}'." if !files and !group

    # Check that they're the right type if they exist
    ["files", "extensions", "exclusions"].each do |key|
      ensure_group_key_is_class_if_exists group, group_config, key, Array
    end

    ["first_file", "command"].each do |key|
      ensure_group_key_is_class_if_exists group, group_config, key, String
    end
    
    ["topology"].each do |key|
      ensure_group_key_is_class_if_exists group, group_config, key, Hash
    end

    # Add full path/glob files
    # --------------------------------------------
    if files
      files.each do |file|

        # This will support globbing and make sure the file exists
        to_open.concat Dir[file]
      end
    end

    # Add files by extension
    # --------------------------------------------
    if extensions
      extensions.each do |extension|

        # Glob the extension in current directory and all subdirectories
        files_found = Dir["**/*#{extension}"]
        to_open.concat files_found
      end
    end
    
    # Add files by command
    # --------------------------------------------
    if command
      to_open.concat(`#{command}`.split("\n"))
    end

    # Check for exclusions and exclude
    # --------------------------------------------
    if exclusions
      to_open = to_open.collect do |file|
        file unless file_should_be_excluded?(file, exclusions)
      end.compact
    end

    # Uniqify
    # --------------------------------------------
    to_open.uniq!
    
    # Remove any matches that are directories
    # --------------------------------------------
    to_open.delete_if {|file| Dir.exist? file }

    # Topologically sort files
    # --------------------------------------------
    if topology
      to_open = TSortedFiles.new(to_open, topology).sorted
    end
    
    # Move "first_file" to front
    # --------------------------------------------
    if first_file

      if to_open.member? first_file

        # Move to beginning of array
        to_open.delete first_file
        to_open.unshift first_file

      else
        puts "#{current_file_basename}: warning: Specified first file '#{first_file}' is not included in the list of files to open in group '#{group}'."
      end
      
    end
    
    # Ensure files were found
    # --------------------------------------------
    raise "No files found for group '#{group}'." if to_open.empty?

    # Return formatted or as-is
    # --------------------------------------------
    return format_files_to_open(to_open) if formatted

    to_open
  end

  # ----------------------------------------------
  # OPENING --------------------------------------
  # ----------------------------------------------
  def self.open_group(group=get_group)
    system "#{editor} #{files_to_open_for_group(group, formatted: true)}"
  end

  # ----------------------------------------------
  # MAIN -----------------------------------------
  # ----------------------------------------------
  def self.main()

    begin

      require_editor_env_variable

      parse_and_execute_special_arguments
      require_and_parse_config_file

      open_group

    rescue => exception

      puts "#{current_file_basename}: fatal: #{exception}"
      exit 1

    end
  end
  
end

