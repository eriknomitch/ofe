# ================================================
# OFE ============================================
# ================================================
require "json"

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

  def self.parse_config_file
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

  def self.files_to_open_for_group(group)
    group_config = find_group_config(group)

    raise "Group '#{group}' is not defined in your ofe.json config file." unless group_config

    files      = group_config["files"]
    extensions = group_config["extensions"]
    to_open    = []

    # Check that at least one definition exists
    raise "Neither files: nor extensions: is defined for group '#{group}'." if !files and !group

    # Check that they're the right type if they exist
    raise "Key files: is not an array for group '#{group}'." if files and files.class != Array
    raise "Key extensions: is not an array for group '#{group}'." if extensions and extensions.class != Array

    # Files
    # --------------------------------------------
    to_open.concat(files) if files

    # Extensions
    # --------------------------------------------
    if extensions
      extensions.each do |extension|
        files_found = Dir["**/*#{extension}"]
        to_open.concat files_found
      end
    end
    
    raise "No files found for group '#{group}'." if to_open.empty?

    to_open
  end

  # ----------------------------------------------
  # OPENING --------------------------------------
  # ----------------------------------------------
  def self.open_group(group=get_group)
    to_open = files_to_open_for_group(group)

  end

  # ----------------------------------------------
  # MAIN -----------------------------------------
  # ----------------------------------------------
  def self.main()

    begin

      parse_config_file
      open_group

    rescue => exception

      puts "#{current_file_basename}: #{exception}"
      exit 1

    end
  end
  
end

