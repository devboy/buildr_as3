require 'rake'
require 'rake/tasklib'
require File.dirname(__FILE__)+"/jeweler"

class Jeweler
  class PrereleaseTasks < Rake::TaskLib
    attr_accessor :jeweler

    def initialize
      yield self if block_given?

      define
    end

    def jeweler
      @jeweler ||= Rake.application.jeweler
    end

    def define
      namespace :git do
        desc "Tag and push prerelease to git. (happens by default with `rake prerelease`)"
        task :prerelease do
          jeweler.prerelease_to_git
        end
      end

      namespace :gemspec do
        desc "Regenerate and validate gemspec, and then commits and pushes to git on develop branch"
        task :prerelease do
          jeweler.prerelease_gemspec
        end
      end

      desc "Verifies that it is a prerelease version."
      task :is_prerelease_version => :version_required do
        abort "it's not a prerelease version" unless jeweler.is_prerelease_version?
      end

      namespace :rubygems do
        desc "Release gem to Gemcutter"
        task :release => [:gemspec, :build] do
          jeweler.release_gem_to_rubygems
        end
      end

      desc "Make a prerelease to rubygems."
      task :prerelease => [:is_prerelease_version, 'gemspec:prerelease', 'git:prerelease', 'rubygems:release']
    end
  end
end
