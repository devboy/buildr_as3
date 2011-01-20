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
require 'buildr/core/doc'

module Buildr
  module Doc
    class Asdoc < Base

      specify :language => :actionscript, :source_ext => :as

      def generate(sources, target, options = {})
        dependencies = project.compile.dependencies
        sources = project.compile.sources
        flex_sdk = options[:flexsdk]
        output =  (options[:output] || "#{target}")
        cmd_args = []
        cmd_args << "-classpath" << "#{flex_sdk.home}/lib/xalan.jar"
        cmd_args << "-classpath" << flex_sdk.asdoc_jar
        cmd_args << "flex2.tools.ASDoc"
        cmd_args << "+flexlib" << "#{flex_sdk.home}/frameworks"
        cmd_args << "-load-config" << flex_sdk.flex_config
        cmd_args << "-output" << output
        cmd_args << "-source-path" << sources.join(" ")
        cmd_args << "-doc-sources" << sources.join(" ")
        cmd_args << "-templates-path" << flex_sdk.asdoc_templates
        cmd_args << "-library-path+=#{dependencies.join(",")}" unless dependencies.empty?
        reserved = [:flexsdk,:main,:classpath,:sourcepath]
        options.to_hash.reject { |key, value| reserved.include?(key) }.
            each do |key, value|
              cmd_args << "-#{key}=#{value}"
            end
        flex_sdk.default_options.each do |key, value|
              cmd_args << "-#{key}=#{value}"
        end
        unless Buildr.application.options.dryrun
          Java::Commands.java cmd_args
        end
      end
    end
  end
end

Buildr::Doc.engines << Buildr::Doc::Asdoc
