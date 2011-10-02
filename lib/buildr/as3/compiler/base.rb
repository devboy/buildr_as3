#
# Copyright (C) 2011 by Dominic Graefen / http://devboy.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

require "buildr"
require 'buildr/core/compile'

module Buildr
  module AS3
    module Compiler
      class FlexCompilerBase < Buildr::Compiler::Base #:nodoc:

        COMPILE_OPTIONS = [:warnings, :debug, :other, :flexsdk, :apparat, :output]

        def initialize(project, options) #:nodoc:
          super
          options[:debug] = Buildr.options.debug if options[:debug].nil?
          options[:warnings] ||= true
        end

        def compile(sources, target, dependencies) #:nodoc:
          check_options options, COMPILE_OPTIONS
          flex_sdk = options[:flexsdk].invoke
          output = @project.get_as3_output( is_test(sources,target,dependencies) )
          cmd_args = compiler_args(@project.compile.as3_dependencies, flex_sdk, output, sources)
          unless Buildr.application.options.dryrun
            trace(cmd_args.join(' '))
            Java::Commands.java cmd_args
          end
        end

        def needed?(sources, target, dependencies)
          return true unless File.exist?(@project.get_as3_output(is_test(sources,target,dependencies)))
          source_files = Dir.glob(sources.collect{|source| source = "#{source}/**/*"})
          dep_files = dependencies.collect{ |dep|
            File.directory?(dep) ? Dir.glob("#{dep}/**/*") : dep
          }.flatten
          maxtime = (source_files + dep_files).collect{ |file| File.stat(file).mtime }.max || Time.at(0)
          maxtime > File.stat(@project.get_as3_output(is_test(sources,target,dependencies))).mtime
        end

        private

        def compiler_args(as3_dependencies, flex_sdk, output, sources)
          cmd_args = []
          cmd_args << "-jar" << compiler_jar
          cmd_args << "+flexlib" << "#{flex_sdk.home}/frameworks"
          cmd_args << "-output" << output
          cmd_args << "+configname=air" if air
          cmd_args << @main unless @main.nil?
          cmd_args << "-define+=CONFIG::debug,#{options[:debug]}"
          cmd_args << "-define+=CONFIG::environment,\"#{Buildr.environment}\""
          cmd_args << "-load-config" << flex_sdk.flex_config unless air
          cmd_args << "-load-config" << flex_sdk.air_config if air
          cmd_args += generate_source_args sources
          cmd_args += generate_dependency_args as3_dependencies
          cmd_args += flex_compiler_args
          cmd_args
        end

        def flex_compiler_args #:nodoc:
          args = []
          args << '-warnings=false' unless options[:warnings]
          args << '-debug=true' if options[:debug]
          args + Array(options[:other]) + Array(options[:flexsdk].default_options)
        end

        def is_test( sources, target, dependencies )
          sources==@project.test.compile.sources && dependencies==@project.test.compile.dependencies.collect{|dep|dep.to_s} && target==@project.test.compile.target.to_s
        end

      end
    end
  end
end