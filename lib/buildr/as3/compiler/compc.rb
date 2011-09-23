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

module Buildr
  module AS3
    module Compiler
      # Compc compiler:
      #   compile.using(:compc)
      #
      # Accepts the following options:
      # * :warnings    -- Issue warnings when compiling.  Defaults to "true"
      # * :debug       -- Generates bytecode with debugging information.  Set from the debug environment variable/global option.
      # * :flexsdk     -- Specify an FlexSDK Artifact of the type Buildr::AS3::Flex::FlexSDK
      # * :apparat     -- Specify an Apparat Artifact of the type Buildr::AS3::Apparat::ApparatToolkit (this is only necessary if you want to make use of the apparat-toolkit)
      # * :other       -- Array of options passed to the compiler (e.g. ['-compiler.incremental=true', '-static-link-runtime-shared-libraries=true', '-optimize'])
      class Compc < FlexCompilerBase

        specify :language => :actionscript,
                :sources => [:as3, :mxml], :source_ext => [:as, :mxml],
                :target => "bin", :target_ext => "swc",
                :packaging => :swc

        def compile(sources, target, dependencies) #:nodoc:
          super
        end

        private

        def compiler_jar
          options[:flexsdk].compc_jar
        end

        def air
          false
        end

        def generate_source_args(sources) #:nodoc:
          source_args = []
          sources.each { |source|
            source_args << "-include-sources+=#{source}"
            source_args << "-source-path+=#{source}"
          }
          source_args
        end

        def generate_dependency_args(dependencies) #:nodoc:
          dependency_args = []
          dependencies[:library].each { |source| dependency_args << "-library-path+=#{source}" }
          dependencies[:external].each { |source| dependency_args << "-external-library-path+=#{source}" }
          dependencies[:include].each { |source| dependency_args << "-include-libraries+=#{source}" }
          dependency_args
        end

      end
    end
  end
end