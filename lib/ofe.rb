# ================================================
# OFE ============================================
# ================================================
require "json"
require "shellwords"
require "tsort"

require "ofe/t_sorted_files"

# ------------------------------------------------
# MODULE->OFE ------------------------------------
# ------------------------------------------------
module Ofe

  # ----------------------------------------------
  # MODULE->VARIABLES ----------------------------
  # ----------------------------------------------
  @@config_json = nil
  
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

    end
  end

  def self.list(argv)
    require_and_parse_config_file

    # Support and check for "--list <group>"
    if group = argv.first
      to_puts = @@config_json[group]
      raise "Group '#{group}' not found in ofe.json." unless to_puts

    # <group> was not passed
    else
      to_puts = @@config_json
    end

    puts JSON.pretty_generate(to_puts)
  end

  def self.list_group_names
    require_and_parse_config_file

    puts @@config_json.keys
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

      @@config_json = JSON.parse(File.open(config_file_filename).read)
    
    rescue => exception
      raise "Cannot parse ofe.json because its JSON is invalid."
    end

  end

  def self.find_group_config(group)
    @@config_json[group.to_s]
  end

  # ----------------------------------------------
  # GROUP ----------------------------------------
  # ----------------------------------------------
  def self.get_group
    return :default if ARGV.count == 0

    ARGV.first.to_sym
  end

  def self.format_files_to_open(files)
    Shellwords.join(files)
  end

  def self.files_to_open_for_group(group, formatted: false)
    group_config = find_group_config(group)

    raise "Group '#{group}' is not defined in your ofe.json config file." unless group_config

    files      = group_config["files"]
    extensions = group_config["extensions"]
    exclusions = group_config["exclusions"]
    first_file = group_config["first_file"]
    command    = group_config["command"]

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

