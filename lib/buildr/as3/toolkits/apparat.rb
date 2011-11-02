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
    module Toolkits
      class ApparatToolkit < Buildr::AS3::Toolkits::ZipToolkiteBase
        DEFAULT_SCALA_VERSION = "2.8.0"

        attr_reader :home, :asmifier, :concrete, :coverage, :dump,
                    :jitb, :reducer, :stripper, :tdsi, :asm_swc,
                    :ersatz_swc, :lzma_decoder_swc

        def initialize(version)
          @version = version
          @spec = "com.googlecode:apparat-bin:zip:#{@version}"
          @zip = Buildr.artifact(@spec)
          @zip_destination = File.join(File.dirname(@zip.to_s), "apparat-#{@version}", "apparat-#{@version}")
          generate_paths @zip_destination, @version
        end

        def invoke #:nodoc:
          @url ||= generate_url_from_version @version
          super
          self
        end

        def scala_dependencies
          Buildr.repositories.remote << 'http://scala-tools.org/repo-releases'
          version = DEFAULT_SCALA_VERSION
          Buildr.artifacts('org.scala-lang:scala-library:jar:' + version).
              map { |a|
                a.install
                a.to_s
              }
        end


        def apparat_dependencies
          Dir.glob("#{@home}/*.jar")
        end

        private

        def generate_url_from_version(version)
          "http://apparat.googlecode.com/files/apparat-#{version}-bin.zip"
        end

        def generate_paths(home_dir, version)
          @home = home_dir
          bat_ext = Buildr::Util.win_os? ? "" : ""
          @apparat = "#{@home}/apparat#{bat_ext}"
          @asmifier = "#{@home}/asmifier#{bat_ext}"
          @concrete = "#{@home}/concrete#{bat_ext}"
          @coverage = "#{@home}/coverage#{bat_ext}"
          @dump = "#{@home}/dump#{bat_ext}"
          @jitb = "#{@home}/jitb#{bat_ext}"
          @reducer = "#{@home}/reducer#{bat_ext}"
          @stripper = "#{@home}/stripper#{bat_ext}"
          @tdsi = "#{@home}/tdsi#{bat_ext}"
          @asm_swc = "#{@home}/apparat-asm-#{version}.swc"
          @ersatz_swc = "#{@home}/apparat-ersatz-#{version}.swc"
          @lzma_decoder_swc = "#{@home}/apparat-lzma-decoder-#{version}.swc"
          self
        end
      end

      module ApparatTasks
        include Extension

        def apparat_tdsi(options = {})
          output = project.get_as3_output
          compile.options[:apparat].invoke
          cmd_args = []
          cmd_args << "apparat.tools.tdsi.TurboDieselSportInjection"
          cmd_args << "-i #{output}"
          cmd_args << "-o #{output}"
          reserved = []
          options.to_hash.reject { |key, value| reserved.include?(key) }.
              each do |key, value|
            cmd_args << "-#{key}" << "#{value}"
          end
          call_system(cmd_args)
        end

        def apparat_reducer(options ={})
          output = project.get_as3_output
          compile.options[:apparat].invoke
          cmd_args = []
          cmd_args << "apparat.tools.reducer.Reducer"
          cmd_args << "-i #{output}"
          cmd_args << "-o #{output}"
          reserved = []
          options.to_hash.reject { |key, value| reserved.include?(key) }.
              each do |key, value|
            cmd_args << "-#{key}" << "#{value}"
          end
          call_system(cmd_args)
        end

        private

        def call_system(args)
          unless Buildr.application.options.dryrun
            cp = compile.options[:apparat].scala_dependencies + compile.options[:apparat].apparat_dependencies
            sh (['java', '-classpath', cp.join(":")] + args).join(" ")
          end
        end

      end
    end
  end
  class Project
    include Buildr::AS3::Toolkits::ApparatTasks
  end
end
