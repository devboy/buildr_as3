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

require 'buildr'

module Buildr
  module AS3
    module Doc
      module AsDoc

        include Buildr::Extension

        first_time do
          desc "Generates asdoc documentation."
          Project.local_task('asdoc')
        end

        before_define do |project|
          project.recursive_task("asdoc")
        end

        after_define("asdoc" => :doc) do |project|
          project.task("asdoc") do

            if project.compile.language == :actionscript

              sources = project.compile.sources
              dependencies = project.compile.dependencies

              flex_sdk = project.compile.options[:flexsdk].invoke
              output = project.base_dir + "/target/docs"
              cmd_args = []
              cmd_args << "-classpath" << "#{flex_sdk.home}/lib/xalan.jar"
              cmd_args << "-classpath" << flex_sdk.asdoc_jar
              cmd_args << "flex2.tools.ASDoc"
              cmd_args << "+flexlib" << "#{flex_sdk.home}/frameworks"
              cmd_args << "-load-config" << flex_sdk.flex_config
              cmd_args << "-output" << output
              sources.each { |source| cmd_args << "-source-path+=#{source}" }
              sources.each { |source| cmd_args << "-doc-sources+=#{source}" }
              cmd_args << "-templates-path" << flex_sdk.asdoc_templates
              cmd_args << "-library-path+=#{dependencies.join(",")}" unless dependencies.empty?

              unless Buildr.application.options.dryrun
                trace "java #{cmd_args.join(" ")}"
                Java::Commands.java cmd_args
              end

            end
          end

        end
      end
    end
  end
end