#$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|

  # General Information
  s.name = "ofe"
  s.version = "0.0.0"
  s.date = "2014-09-27"
  s.summary = "Open For Editing"
  s.description = "Open For Editing: CLI Gem which opens specified files (ofe.json) for editing in your text editor."
  s.authors = ["Erik Nomitch"]
  s.email = "erik@nomitch.com"
  s.homepage = "https://github.com/eriknomitch/ofe"
  s.licenses = ["GPL-2.0"]

  # Files & Pathes
  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
  s.executables << "ofe"
end

