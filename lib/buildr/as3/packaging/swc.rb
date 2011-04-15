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
require "fileutils"

module Buildr
  module AS3
    module Packaging

      class SwcTask < Rake::FileTask

        include Extension

        attr_writer :target_swc, :src_swc
        attr_reader :target_swc, :src_swc

        def initialize(*args) #:nodoc:
          super
          enhance do
            fail "File not found: #{src_swc}" unless File.exists? src_swc
            FileUtils.cp(src_swc, target_swc)
          end
        end

        def needed?
          return true unless File.exists?(target_swc)
          File.stat(src_swc).mtime > File.stat(target_swc).mtime
        end

        first_time do
          desc 'create swc package task'
          Project.local_task('package_swc')
        end

        before_define do |project|
          SwcTask.define_task('package_swc').tap do |package_swc|
            package_swc
          end
        end

      end

      def package_swc(&block)
        task("package_swc").enhance &block
      end

      protected

      def package_as_swc(file_name)
        fail("Package types don't match! :swc vs. :#{compile.packaging.to_s}") unless compile.packaging == :swc
        SwcTask.define_task(file_name).tap do |swc|
          swc.src_swc = get_as3_output(compile.target,compile.options)
          swc.target_swc = file_name
        end
      end

    end
  end
end