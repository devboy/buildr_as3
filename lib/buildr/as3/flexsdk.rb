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
require 'tmpdir'
require "open-uri"
require "fileutils"

module Buildr
  module AS3
    module Flex
      class FlexSDK

        attr_reader :home, :mxmlc_jar, :compc_jar, :asdoc_jar, :fcsh_jar, :flex_config,
                    :asdoc_templates, :default_options, :air_config, :bin, :adt_jar

        attr_writer :flex_config, :air_config, :asdoc_templates

        def initialize(version)
          @version = version
          @default_options = {}
          @spec = "com.adobe.flex:sdk:zip:#{@version}"
          @sdk_zip = Buildr.artifact(@spec)
          @sdk_dir = File.join(File.dirname(@sdk_zip.to_s), "sdk-#{@version}")
          generate_paths @sdk_dir
          self
        end

        def invoke
          @url ||= generate_url_from_version @version

          if Buildr::Util.win_os?
            unless File.exists? @sdk_zip.to_s
              FileUtils.mkdir_p File.dirname(@sdk_zip.to_s) unless File.directory? File.dirname(@sdk_zip.to_s)
              File.open @sdk_zip.to_s, 'w' do |file|
                file.binmode()
                URI.read(@url, {:progress=>true}) { |chunk| file.write chunk }
              end
            end
          else
            Buildr.artifact(@spec).from(Buildr.download(@url)).invoke unless File.exists? @sdk_zip.to_s
          end


          unless File.exists? @sdk_dir
            puts "Unzipping FlexSDK, this might take a while."
            if Buildr::Util.win_os?
              puts "Please make sure unzip is installed and in your PATH variable!"
              unzip @sdk_zip, @sdk_dir
            else
              begin
                Buildr.unzip(@sdk_dir.to_s=>@sdk_zip.to_s).target.invoke
              rescue TypeError
                puts "RubyZip extract failed, trying system unzip now."
                unzip @sdk_zip, @sdk_dir
              end
            end
          end
          self
        end

        def from(url)
          @url = url
          self
        end

        protected

        def unzip(zip, destination)
          project_dir = Dir.getwd
          Dir.chdir File.dirname(zip.to_s)
          system("unzip #{File.basename(zip.to_s).to_s} -d #{File.basename(destination).to_s}")
          Dir.chdir project_dir
        end

        def generate_url_from_version(version)
          "http://fpdownload.adobe.com/pub/flex/sdk/builds/flex#{version.split(".")[0]}/flex_sdk_#{version}.zip"
        end

        def generate_paths(home_dir)
          @home = home_dir
          @mxmlc_jar = "#{@home}/lib/mxmlc.jar"
          @compc_jar = "#{@home}/lib/compc.jar"
          @asdoc_jar = "#{@home}/lib/asdoc.jar"
          @adt_jar = "#{@home}/lib/adt.jar"
          @adl = Buildr::Util.win_os? ? "#{@home}/bin/adl.exe" : "#{@home}/bin/adl"
          @asdoc_templates = "#{@home}/asdoc/templates"
          @fcsh_jar = "#{@home}/lib/fcsh.jar"
          @flex_config = "#{@home}/frameworks/flex-config.xml"
          @air_config = "#{@home}/frameworks/air-config.xml"
          @bin = "#{@home}/bin"
          true
        end
      end
    end
  end
end
