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
    module Apparat
      class ApparatToolkit
        attr_reader :home, :asmifier, :concrete, :coverage, :dump,
                    :jitb, :reducer, :stripper, :tdsi, :asm_swc,
                    :ersatz_swc, :lzma_decoder_swc, :scala_home

        def initialize(version)
          @version = version
          @spec = "com.googlecode:apparat-bin:zip:#{@version}"
          @apparat_zip = Buildr.artifact(@spec)
          @apparat_dir = File.join(File.dirname(@apparat_zip.to_s), "apparat-bin-#{@version}", "apparat-#{@version}")
          generate_paths @apparat_dir, @version
        end

        def invoke

          if @url
            Buildr.artifact(@spec).from(Buildr.download(@url)).invoke unless File.exists? @apparat_zip.to_s
          else
            Buildr.artifact(@spec).invoke unless File.exists? @apparat_zip.to_s
          end

          unless File.exists? @apparat_dir
            puts "Unzipping Apparat, this might take a while."
            unzip_dir = File.dirname @apparat_dir
            if Buildr::Util.win_os?
              puts "Please make sure unzip is installed and in your PATH variable!"
              unzip @apparat_zip, unzip_dir
            else
              begin
                Buildr.unzip(unzip_dir.to_s=>@apparat_zip.to_s).target.invoke
              rescue TypeError
                puts "RubyZip extract failed, trying system unzip now."
                unzip @apparat_zip, unzip_dir
              end
            end
          end
          self
        end

        def from(url)
          @url = url
          self
        end

        def scala(scala_home)
          @scala_home = scala_home
          self
        end


        protected

        def unzip(zip, destination)
          project_dir = Dir.getwd
          Dir.chdir File.dirname(zip.to_s)
          system("unzip #{File.basename(zip.to_s).to_s} -d #{File.basename(destination).to_s}")
          Dir.chdir project_dir
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

      module Tasks
        include Extension

        first_time do
          Project.local_task('apparat_tdsi')
          Project.local_task('apparat_reducer')
        end

        before_define do |project|
        end

        after_define do |project|
        end

        def apparat_tdsi(options = {})
          output = Buildr::AS3::Compiler::CompilerUtils::get_output(project, compile.target, compile.packaging, compile.options)
          apparat_tk = compile.options[:apparat].invoke
          cmd_args = []
          cmd_args << "#{apparat_tk.tdsi}"
          cmd_args << "-i #{output}"
          cmd_args << "-o #{output}"
          reserved = []
          options.to_hash.reject { |key, value| reserved.include?(key) }.
              each do |key, value|
            cmd_args << "-#{key} #{value}"
          end
          ENV["PATH"] = "#{apparat_tk.scala_home}/bin#{File::PATH_SEPARATOR}#{ENV["PATH"]}" if apparat_tk.scala_home && !ENV["PATH"].include?("#{apparat_tk.scala_home}/bin")
          system(cmd_args.join " ")
        end

        def apparat_reducer(quality)
          output = Buildr::AS3::Compiler::CompilerUtils::get_output(project, compile.target, compile.packaging, compile.options)
          apparat_tk = compile.options[:apparat].invoke
          cmd_args = []
          cmd_args << "#{apparat_tk.reducer}"
          cmd_args << "-i #{output}"
          cmd_args << "-o #{output}"
          cmd_args << "-q"
          cmd_args << quality || 100
          ENV["PATH"] = "#{apparat_tk.scala_home}#{File::Separator}bin#{File::PATH_SEPARATOR}#{ENV["PATH"]}" if apparat_tk.scala_home && !ENV["PATH"].include?("#{apparat_tk.scala_home}/bin")
          system(cmd_args.join " ")
        end
      end
    end
  end
  class Project
    include Buildr::AS3::Apparat::Tasks
  end
end
