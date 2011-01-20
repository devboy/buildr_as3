require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.platform      =   Gem::Platform::RUBY
    s.name          =   "buildr-as3"
    s.version       =   "0.1.2"
    s.author        =   "Dominic Graefen"
    s.homepage      =   "http://devboy.org"
    s.email         =   "dominic @nospam@ devboy.org"
    s.summary       =   "Buildr extension to allow ActionScript3/Flex development."
    s.description   =   "Buildr extension to allow ActionScript3/Flex development."
    s.files         =   FileList['{lib}/**/*'].to_a
    s.require_path  =   "lib"
    s.add_dependency("buildr",">=1.4.4")
    s.has_rdoc  =   false
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end