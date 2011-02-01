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
    module Flex
      class FlexSDK

        attr_reader :home, :mxmlc_jar, :compc_jar, :asdoc_jar, :fcsh_jar, :flex_config,
                    :asdoc_templates, :default_options, :air_config, :bin

        attr_writer :flex_config, :air_config, :asdoc_templates

        def initialize(sdk_opts = {})

          @default_options = {}

          generate_url(sdk_opts)

          sdk_zip = Buildr::artifact("com.adobe.flex:sdk:zip:#{sdk_opts[:sdk_version]}").from(Buildr::download(sdk_opts[:sdk_url]))
          sdk_zip.invoke unless File.exists? sdk_zip.to_s
          sdk_dir = File.join(File.dirname(sdk_zip.to_s), "sdk-#{sdk_opts[:sdk_version]}")

          unless File.exists? sdk_dir
            puts "Unzipping FlexSDK, this may take a while."
            Buildr::unzip("#{sdk_dir}"=>sdk_zip.to_s).target.invoke
          end

          @home = sdk_dir
          @mxmlc_jar = "#{@home}/lib/mxmlc.jar"
          @compc_jar = "#{@home}/lib/compc.jar"
          @asdoc_jar = "#{@home}/lib/asdoc.jar"
          @asdoc_templates = "#{@home}/asdoc/templates"
          @fcsh_jar = "#{@home}/lib/fcsh.jar"
          @flex_config = "#{@home}/frameworks/flex-config.xml"
          @air_config = "#{@home}/frameworks/air-config.xml"
          @bin = "#{@home}/bin"
        end

        protected

        def generate_url(opts = {})
          opts[:sdk_url] ||= "http://fpdownload.adobe.com/pub/flex/sdk/builds/flex#{opts[:sdk_version].split(".")[0]}/flex_sdk_#{opts[:sdk_version]}.zip"
        end

      end
    end
  end
end
