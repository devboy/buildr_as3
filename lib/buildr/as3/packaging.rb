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
require 'buildr/packaging'
require "ftools"
module Buildr
  module Packaging
    module AS3
      class SwcTask < Rake::FileTask
        include Extension
        attr_writer :target_swc, :src_swc
        attr_reader :target_swc, :src_swc
        def initialize(*args) #:nodoc:
          super
          enhance do
            fail "File not found: #{src_swc}" unless File.exists? src_swc
            File.copy( src_swc, target_swc )
          end
        end
        def needed?
          true
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
      class SwfTask < Rake::FileTask
        include Extension
        attr_writer :target_swf, :src_swf
        attr_reader :target_swf, :src_swf
        def initialize(*args) #:nodoc:
          super
          enhance do
            fail "File not found: #{src_swf}" unless File.exists? src_swf
            File.copy( src_swf, target_swf )
          end
        end
        def needed?
          true
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
      def package_swc(&block)
        task("package_swc").enhance &block
      end
      def package_swf(&block)
        task("package_swf").enhance &block
      end
      protected
      def package_as_swc(file_name)
        SwcTask.define_task(file_name).tap do |swc|
          swc.src_swc = (compile.options[:output] || "#{compile.target}/#{project.to_s}.swc")
          swc.target_swc = file_name
        end
      end
      def package_as_swf(file_name)
        SwfTask.define_task(file_name).tap do |swf|
          main = compile.options[:main]
          mainfile = File.basename(main, File.extname(main))
          swf.src_swf =  (compile.options[:output] || "#{compile.target}/#{mainfile}.swf")
          swf.target_swf = file_name
        end
      end
    end
  end
end
class Buildr::Project
  include Buildr::Packaging::AS3
end