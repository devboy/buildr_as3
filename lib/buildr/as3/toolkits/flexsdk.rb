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
      class FlexSDK < Buildr::AS3::Toolkits::ZipToolkiteBase

        attr_reader :home, :mxmlc_jar, :compc_jar, :asdoc_jar, :fcsh_jar, :flex_config,
                    :asdoc_templates, :default_options, :air_config, :bin, :adt_jar, :adl

        attr_writer :flex_config, :air_config, :asdoc_templates

        def initialize(version)
          @version = version
          @default_options = []
          @spec = "com.adobe.flex:sdk:zip:#{@version}"
          @zip = Buildr.artifact(@spec)
          @zip_destination = File.join(File.dirname(@zip.to_s), "sdk-#{@version}")
          generate_paths @zip_destination
          self
        end

        def invoke #:nodoc:
          @url ||= generate_url_from_version @version
          super
          self
        end

        # :call-seq:
        #   from(url) => self
        #
        # * You can pass a url where the FlexSDK should be downloaded from as a string:
        # FLEX_SDK.from("http://domain.tld/flex_sdk.zip")
        # * You can pass :maven as a parameter to download it from a maven repository:
        # FLEX_SDK.from(:maven)
        # * If you don't call this function at all, buildr-as3 will try and resolve a url on the adobe-website
        # to download the FlexSDK
        def from(url)
          @url = url
          self
        end

        private

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
