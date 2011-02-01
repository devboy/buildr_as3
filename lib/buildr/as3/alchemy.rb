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
    module Alchemy
      class AlchemyToolkit

        attr_reader :home, :achacks, :gcc, :flex_sdk, :alchemy_setup, :bin

        def initialize( flex_sdk )

          @flex_sdk = flex_sdk

          toolkit_version = "1.0.0"
          toolkit_url = "http://download.macromedia.com/pub/labs/alchemy/alchemy_sdk_darwin_p1_121008.zip"

          toolkit_zip = Buildr::artifact("com.adobe.alchemy:toolkit:zip:#{toolkit_version}").from(Buildr::download(toolkit_url))
          toolkit_zip.invoke unless File.exists? toolkit_zip.to_s

          toolkit_dir = File.join(File.dirname(toolkit_zip.to_s), "toolkit-#{toolkit_version}")

          unless File.exists? toolkit_dir
            puts "Unzipping Alchemy Toolkit, this may take a while."
            Buildr::unzip("#{toolkit_dir}"=>toolkit_zip.to_s).target.invoke
          end

          @home = "#{toolkit_dir}/alchemy-darwin-v0.5a"
          @achacks = "#{@home}/achacks"
          @gcc = "#{@achacks}/gcc"
          @alchemy_setup = "#{@home}/alchemy-setup"
          @config = "#{@home}/config"
          @bin = "#{@home}/bin"

          # Run config script if alchemy-setup doesn't exist
          unless File.exists? @alchemy_setup
            project_dir = Dir.getwd
            ENV["PATH"] = "#{ENV["PATH"]}:#{flex_sdk.bin}"
            Dir.chdir @home
            system("sh ./config")
            Dir.chdir project_dir
          end

        end
      end

      module Compiler
        class AlcGcc < Buildr::Compiler::Base
        specify :language => :c,
                :sources => :c, :source_ext => :c,
                :target => "bin", :target_ext => "swc",
                :packaging => :swc

        attr_reader :project

        def initialize(project, options)
          super
          @project = project
        end

        include Buildr::AS3::Compiler::CompilerUtils

        def compile(sources, target, dependencies)
          alchemy_tk = options[:alchemy]
          flex_sdk = alchemy_tk.flex_sdk
          output =  Buildr::AS3::Compiler::CompilerUtils::get_output(project,target,:swc,options)

          # gcc stringecho.c -O3 -Wall -swc -o stringecho.swc
          cmd_args = []
          cmd_args << "gcc"
          cmd_args << File.basename(options[:main])
          cmd_args << "-O3 -Wall -swc"
          cmd_args << "-o #{File.basename output}"

          reserved = [:flexsdk,:main,:alchemy]
          options.to_hash.reject { |key, value| reserved.include?(key) }.
              each do |key, value|
                cmd_args << "-#{key}=#{value}"
          end

          unless Buildr.application.options.dryrun
            ENV["ALCHEMY_HOME"]= alchemy_tk.home
            ENV["ALCHEMY_VER"] = "0.4a"
            ENV["PATH"] = "#{alchemy_tk.bin}:#{ENV["PATH"]}"
            ENV["ASC"]="#{alchemy_tk.home}/bin/asc.jar"
            ENV["SWFBRIDGE"]="#{alchemy_tk.home}/bin/swfbridge"
            ENV["PATH"] = "#{alchemy_tk.achacks}:#{ENV["PATH"]}"
            ENV["PATH"] = "#{ENV["PATH"]}:#{flex_sdk.bin}"
            project_dir = Dir.getwd
            Dir.chdir File.dirname options[:main]
            system(cmd_args.join(" "))
            File.copy( File.basename(output), output)
            File.delete File.basename(output)
            Dir.chdir project_dir
          end
        end
        end
      end
    end
  end
end
Buildr::Compiler.compilers << Buildr::AS3::Alchemy::Compiler::AlcGcc