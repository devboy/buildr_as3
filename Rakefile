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
require File.dirname(__FILE__)+"/rake/jeweler_prerelease_tasks"
Jeweler::Tasks.new do |gem|
  gem.name = "buildr-as3"
  gem.homepage = "http://github.com/devboy/buildr_as3"
  gem.license = "MIT"
  gem.summary = "Buildr extension to allow ActionScript3/Flex development."
  gem.description = "Build like you code - now supporting ActionScript 3 & Flex"
  gem.email = "dominic @nospam@ devboy.org"
  gem.authors = ["Dominic Graefen"]
  gem.add_runtime_dependency("buildr",">=1.4.5")
end
Jeweler::RubygemsDotOrgTasks.new
Jeweler::PrereleaseTasks.new

task :prerelease => 'rubygems:release'

require 'rspec/core'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

ENV["CI_REPORTS"] ||= File.expand_path( File.join( File.dirname(__FILE__), "test", "report" ) )
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :spec => "ci:setup:rspec"

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :test => :spec
task :default => :spec


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "buildr_as3 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
