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
    module Packaging

      class SwfTask < Rake::FileTask

        include Extension
#        include Buildr::AS3::Compiler::CompilerUtils

        attr_writer :target_swf, :src_swf
        attr_reader :target_swf, :src_swf

        def initialize(*args) #:nodoc:
          super
          enhance do
            fail "File not found: #{src_swf}" unless File.exists? src_swf
            File.copy(src_swf, target_swf)
          end
        end

        def needed?
          super
        end

        first_time do
          desc 'create swf package task'
          Project.local_task('package_swf')
        end

        before_define do |project|
          SwfTask.define_task('package_swf').tap do |package_swf|
            package_swf
          end
        end

      end

      def package_swf(&block)
        task("package_swf").enhance &block
      end

      protected

      def package_as_swf(file_name)
        fail("Package types don't match! :swf vs. :#{compile.packaging.to_s}") unless compile.packaging == :swf
        SwfTask.define_task(file_name).tap do |swf|
          swf.src_swf = "#{compile.target}/output.swf"
          swf.target_swf = file_name
        end
      end

    end
  end
end