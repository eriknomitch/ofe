# encoding: utf-8
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'

desc "Tests ofe gem"

task :test do
  #sh "rspec spec/ofe_spec.rb"
end

desc "Uninstalls ofe gem and executables"

task :uninstall do
  sh "gem uninstall ofe --executables"
end

desc "Builds ofe gem"

task :build do
  sh "gem build ofe.gemspec"
end

desc "Installs ofe gem"

task :install do
  sh "gem install ofe-0.0.0.gem"
end

desc "Uninstalls, Builds, and Installs ofe gem"

task :default => [:uninstall, :build, :install]

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "ofe"
  gem.homepage = "https://github.com/eriknomitch/ofe"
  gem.summary = %Q{Open For Editing}
  gem.description = "Open For Editing: CLI Gem which opens specified files (ofe.json) for editing in your text editor."
  gem.email = "erik@nomitch.com"
  gem.authors = ["Erik Nomitch"]
  gem.license = "GPL-2"
  gem.licenses = ["GPL-2"]
  gem.date = "2014-09-27"
  gem.post_install_message = <<-EOS
---------------------------------------------------------------
If you have not done so, you will need to set your EDITOR 
environment variable (usually in ~/.bashrc or ~/.zshrc).

Example:

export EDITOR=vim
---------------------------------------------------------------
  EOS

  #s.files = `git ls-files`.split("\n")
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

#require 'rake/testtask'
#Rake::TestTask.new(:test) do |test|
  #test.libs << 'lib' << 'test'
  #test.pattern = 'test/**/test_*.rb'
  #test.verbose = true
#end

#desc "Code coverage detail"
#task :simplecov do
  #ENV['COVERAGE'] = "true"
  #Rake::Task['test'].execute
#end

#task :default => :test

#require 'rdoc/task'
#Rake::RDocTask.new do |rdoc|
  #version = File.exist?('VERSION') ? File.read('VERSION') : ""

  #rdoc.rdoc_dir = 'rdoc'
  #rdoc.title = "ofe #{version}"
  #rdoc.rdoc_files.include('README*')
  #rdoc.rdoc_files.include('lib/**/*.rb')
#end
