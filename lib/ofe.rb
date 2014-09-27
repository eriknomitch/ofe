# ================================================
# OFE ============================================
# ================================================
require "json"
require "shellwords"

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
    when "--list"

      ARGV.shift

      # Support "--list <group>"
      if group = ARGV.first
        to_puts = @@config_json[group]
        raise "Group '#{group}' not found in ofe.json." unless to_puts
      else
        to_puts = @@config_json
      end

      puts JSON.pretty_generate(to_puts)
      exit

    when "--groups"
      puts @@config_json.keys
      exit
    end
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

    raise "fatal: No config file found at ./#{config_file_filename}"
  end

  def self.parse_and_require_config_file
    require_config_file

    begin

      @@config_json = JSON.parse(File.open(config_file_filename).read)
    
    rescue => exception
      raise "Cannot parse 'ofe.json' because its JSON is invalid."
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

  def self.files_to_open_for_group(group, formatted: true)
    group_config = find_group_config(group)

    raise "Group '#{group}' is not defined in your ofe.json config file." unless group_config

    files      = group_config["files"]
    extensions = group_config["extensions"]
    to_open    = []

    # Check that at least one definition exists
    raise "Neither files: nor extensions: is defined for group '#{group}'." if !files and !group

    # Check that they're the right type if they exist
    raise "Key 'files': is not an array for group '#{group}'."      if files and files.class != Array
    raise "Key 'extensions': is not an array for group '#{group}'." if extensions and extensions.class != Array

    # Add Full Path/Glob Files
    # --------------------------------------------
    if files
      files.each do |file|

        # This will support globbing and make sure the file exists
        to_open.concat Dir[file]
      end
    end

    # Add Files by Extension
    # --------------------------------------------
    if extensions
      extensions.each do |extension|

        # Glob the extension in current directory and all subdirectories
        files_found = Dir["**/*#{extension}"]
        to_open.concat files_found
      end
    end
    
    raise "No files found for group '#{group}'." if to_open.empty?

    return format_files_to_open(to_open) if formatted

    to_open
  end

  # ----------------------------------------------
  # OPENING --------------------------------------
  # ----------------------------------------------
  def self.open_group(group=get_group)
    to_open = files_to_open_for_group(group)

    puts to_open

  end

  # ----------------------------------------------
  # MAIN -----------------------------------------
  # ----------------------------------------------
  def self.main()

    begin

      parse_and_require_config_file
      parse_and_execute_special_arguments

      open_group

    rescue => exception

      puts "#{current_file_basename}: #{exception}"
      exit 1

    end
  end
  
end

