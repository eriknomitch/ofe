require 'rubygems'
require 'rake'

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
