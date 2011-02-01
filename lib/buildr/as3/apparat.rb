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
      class ApparatToolkit
        attr_reader :home, :asmifier, :concrete, :coverage, :dump,
                    :jitb, :reducer, :stripper, :tdsi, :asm_swc,
                    :ersatz_swc, :lzma_decoder_swc

        def initialize(apparat_version,apparat_url)

          apparat_zip = Buildr::artifact("com.googlecode:apparat-bin:zip:#{apparat_version}").from(Buildr::download(apparat_url))
          apparat_zip.invoke unless File.exists? apparat_zip.to_s
          apparat_dir = File.join(File.dirname(apparat_zip.to_s), "apparat-bin-#{apparat_version}")
          unless File.exists? apparat_dir
            puts "Unzipping Apparat, this may take a while."
            Buildr::unzip(apparat_dir=>apparat_zip.to_s).target.invoke
          end

          @home = apparat_dir
          bat_ext = Buildr::Util.win_os? ? ".bat" : ""
          @apparat = "#{@home}/apparat#{bat_ext}"
          @asmifier = "#{@home}/asmifier#{bat_ext}"
          @concrete = "#{@home}/concrete#{bat_ext}"
          @coverage = "#{@home}/coverage#{bat_ext}"
          @dump = "#{@home}/dump#{bat_ext}"
          @jitb = "#{@home}/jitb#{bat_ext}"
          @reducer = "#{@home}/reducer#{bat_ext}"
          @stripper = "#{@home}/stripper#{bat_ext}"
          @tdsi = "#{@home}/tdsi#{bat_ext}"
          @asm_swc = "#{@home}/apparat-asm-#{apparat_version}.swc"
          @ersatz_swc = "#{@home}/apparat-ersatz-#{apparat_version}.swc"
          @lzma_decoder_swc = "#{@home}/apparat-lzma-decoder-#{apparat_version}.swc"
        end
      end
      module Apparat
        include Extension

        first_time do
          Project.local_task('apparat_tdsi')
          Project.local_task('apparat_reducer')
        end

        before_define do |project|
        end

        after_define do |project|
        end

        def apparat_tdsi(apparat_tk,options = {})
          output = Buildr::AS3::Compiler::CompilerUtils::get_output(project,compile.target,compile.packaging,compile.options)
          cmd_args = []
          cmd_args << apparat_tk.tdsi
          cmd_args << "-i #{output}"
          cmd_args << "-o #{output}"
          reserved = []
          options.to_hash.reject { |key, value| reserved.include?(key) }.
            each do |key, value|
              cmd_args << "-#{key} #{value}"
          end
          system(cmd_args.join " ")
        end

        def apparat_reducer(apparat_tk,quality)
          output = Buildr::AS3::Compiler::CompilerUtils::get_output(project,compile.target,compile.packaging,compile.options)
          cmd_args = []
          cmd_args << apparat_tk.reducer
          cmd_args << "-i #{output}"
          cmd_args << "-o #{output}"
          cmd_args << "-q"
          cmd_args << quality || 100
          system(cmd_args.join " ")
        end
      end
  end
  class Project
    include Buildr::AS3::Apparat
  end
end
