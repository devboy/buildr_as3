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
  end
end
