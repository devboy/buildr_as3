require 'buildr/core/doc'

module Buildr
  module Doc

    module AsdocDefaults
      include Extension

      after_define(:asdoc => :doc) do |project|
        if project.doc.engine? Asdoc
          options = project.doc.options
          options[:maintitle] = (project.comment || project.name) unless options[:maintitle]
        end
      end
    end

    class Asdoc < Base

      specify :language => :actionscript, :source_ext => ["as", "mxml"]

      def generate(sources, target, options = {})

        flexsdk = @project.compile.options[:flexsdk].invoke
        cmd_args = []
        cmd_args << "-jar" << flexsdk.asdoc_jar
        cmd_args << "+flexlib" << "#{flexsdk.home}/frameworks"
        cmd_args << "-load-config" << flexsdk.flex_config
        cmd_args << "-main-title" << options[:maintitle]
        cmd_args << "-window-title" << options[:windowtitle] if options.has_key? :windowtitle
        cmd_args += generate_source_args @project.compile.sources
        cmd_args += generate_dependency_args @project.compile.dependencies
        cmd_args += options[:args] if options.has_key? :args
        cmd_args << "-output" << target

        unless Buildr.application.options.dryrun
          info "Generating ASDoc for #{project.name}"
          trace (['java'] + cmd_args).join(' ')
          Java.load
          Java::Commands.java cmd_args
        end

      end

      private

      def generate_source_args(sources) #:nodoc:
        source_args = []
        sources.each { |source|
          source_args << "-source-path+=#{source}"
          source_args << "-doc-sources+=#{source}"
        }
        source_args
      end

      def generate_dependency_args(dependencies) #:nodoc:
        dependency_args = []
        dependencies.each { |source| dependency_args << "-library-path+=#{source}" }
        dependency_args
      end
    end
  end

  class Project
    include AsdocDefaults
  end
end

Buildr::Doc.engines << Buildr::Doc::Asdoc
