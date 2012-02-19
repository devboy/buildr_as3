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

      class AirTask < Rake::FileTask
        include Extension

        attr_writer :target_air, :src_swf, :flexsdk
        attr_reader :target_air, :src_swf, :storetype, :keystore, :storepass, :appdescriptor, :libs, :flexsdk

        def initialize(*args) #:nodoc:
          super
          enhance do
            fail "File not found: #{src_swf}" unless File.exists? src_swf
            cmd_args = []
            cmd_args << "-jar" << flexsdk.adt_jar
            cmd_args << "-package"
            cmd_args << "-storetype" << storetype
            cmd_args << "-keystore" << keystore
            cmd_args << "-storepass" << storepass
            cmd_args << target_air
            cmd_args << appdescriptor
            cmd_args << "-C" << File.dirname(src_swf) << File.basename(src_swf)
            libs.each do |key, value|
              puts "key,value", key, value
              cmd_args << "-C" << key << value
            end unless libs.nil?

            puts cmd_args.join " "

            unless Buildr.application.options.dryrun
              Java::Commands.java cmd_args
            end
          end
        end

        def needed?
          return true unless File.exists?(target_air)
          File.stat(src_swf).mtime > File.stat(target_air).mtime
        end

        first_time do
          desc 'create air package task'
          Project.local_task('package_air')
        end

        before_define do |project|
          AirTask.define_task('package_air').tap do |package_air|
            package_air
          end
        end

        def sign(*args)
          args.each do |arg|
            @storetype = arg[:storetype] if arg.has_key? :storetype
            @keystore = arg[:keystore] if arg.has_key? :keystore
            @storepass = arg[:storepass] if arg.has_key? :storepass
            @appdescriptor = arg[:appdescriptor] if arg.has_key? :appdescriptor
          end
          self
        end

        def with(*args)
          @libs ||= Hash.new
          args.each do |arg|
            case arg
              when Hash
                arg.each do |key, value|
                  @libs[key] = value
                end
            end
          end
          self
        end

      end

      def package_air(&block)
        task("package_air").enhance &block
      end

      protected

      def package_as_air(file_name)
        fail("Package types don't match! :swf vs. :#{compile.packaging.to_s}") unless compile.packaging == :swf
        AirTask.define_task(file_name).tap do |swf|
          swf.src_swf = File.join(compile.target.to_s, compile.options[:output] || "#{project.name.split(":").last}.#{compile.packaging.to_s}")
          swf.target_air = file_name
          swf.flexsdk = compile.options[:flexsdk]
        end
      end

    end
  end
end