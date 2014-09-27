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

  # ----------------------------------------------
  # TARGET ---------------------------------------
  # ----------------------------------------------
  def self.get_target
    return :default if ARGV.count == 0

    ARGV.first.to_sym
  end

  def self.valid_target?(target)
  end
  
  # ----------------------------------------------
  # FINDING --------------------------------------
  # ----------------------------------------------
  def self.files_for_target(target)
  end
  
  # ----------------------------------------------
  # OPENING --------------------------------------
  # ----------------------------------------------
  def self.open_target(target=get_target)
  end

  # ----------------------------------------------
  # MAIN -----------------------------------------
  # ----------------------------------------------
  def self.main()

    begin

      parse_config_file
      open_target

      puts @@config_json

    rescue => exception

      puts "#{current_file_basename}: #{exception}"
      exit 1

    end
  end
  
end

