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

require 'rubygems'
require 'buildr/core/project'
require 'buildr/core/common'
require 'buildr/core/compile'
require 'buildr/packaging'


module Buildr
  module Compiler

    class FlexCompilerBase < Base #:nodoc:

      OPTIONS = [:warnings, :debug, :other, :flexsdk, :apparat, :main]

      def initialize(project, options) #:nodoc:
        super
        options[:debug] = Buildr.options.debug if options[:debug].nil?
        options[:warnings] ||= true
      end

      def compile(sources, target, dependencies) #:nodoc:
        check_options options, OPTIONS
        flex_sdk = options[:flexsdk].invoke
        output = "#{target}/output.swf"
        cmd_args = []
        cmd_args << "-jar" << @compiler_jar
        cmd_args << "+flexlib" << "#{flex_sdk.home}/frameworks"
        cmd_args << "-output" << output
        cmd_args << "-load-config" << flex_sdk.flex_config
        cmd_args += generate_source_args sources
        cmd_args += generate_dependency_args dependencies
        cmd_args += flex_compiler_args
        unless Buildr.application.options.dryrun
          trace(cmd_args.join(' '))
          Java::Commands.java cmd_args
        end
      end

      private

      def flex_compiler_args #:nodoc:
        args = []
        args << '-warnings=false' unless options[:warnings]
        args << '-debug=true' if options[:debug]
        args + Array(options[:other]) + Array(options[:flexsdk].default_options)
      end

    end

    # Mxmlc compiler:
    #   compile.using(:mxmlc)
    # Used by default if .as or .mxmlc files are found in the src/main/as3 directory (or src/test/as3)
    # and sets the target directory to target/bin (or target/test/bin).
    #
    # Accepts the following options:
    # * :warnings    -- Issue warnings when compiling.  Defaults to "true"
    # * :debug       -- Generates bytecode with debugging information.  Set from the debug
    # environment variable/global option.
    # * :flexsdk     -- Specify an FlexSDK Artifact of the type Buildr::AS3::Flex::FlexSDK
    # * :apparat     -- Specify an Apparat Artifact of the type Buildr::AS3::Apparat::ApparatToolkit
    # (this is only necessary if you want to make use of the apparat-toolkit)
    # * :other       -- Array of options passed to the compiler
    # (e.g. ['-compiler.incremental=true', '-static-link-runtime-shared-libraries=true', '-optimize'])
    class Mxmlc < FlexCompilerBase

      specify :language => :actionscript,
              :sources => [:as3, :mxml], :source_ext => [:as, :mxml],
              :target => "bin", :target_ext => "swf",
              :packaging => :swf

      def compile(sources, target, dependencies)
        @compiler_jar = options[:flexsdk].mxmlc_jar
        options[:other] = [] if options[:other].nil?
        options[:other] << options[:main]
        super
      end

      private

      def generate_source_args(sources)
        source_args = []
        sources.each {|source| source_args << "-source-path+=#{source}"}
        source_args
      end

      def generate_dependency_args(dependencies)
        dependency_args = []
        dependencies.each {|source| dependency_args << "-library-path+=#{source}"}
        dependency_args
      end

    end

    class Compc < FlexCompilerBase

      specify :language => :actionscript,
              :sources => [:as3, :mxml], :source_ext => [:as, :mxml],
              :target => "bin", :target_ext => "swc",
              :packaging => :swc

      def compile(sources, target, dependencies)
        @compiler_jar = options[:flexsdk].compc_jar
        super
      end

      private

      def generate_source_args(sources)
        source_args = []
        sources.each {|source| source_args << "-include-sources+=#{source}"}
        source_args
      end

      def generate_dependency_args(dependencies)
        dependency_args = []
        dependencies.each {|source| dependency_args << "-library-path+=#{source}"}
        dependency_args
      end

    end

  end

end

Buildr::Compiler << Buildr::Compiler::Mxmlc
Buildr::Compiler << Buildr::Compiler::Compc
