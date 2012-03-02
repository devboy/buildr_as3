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
      class ZipToolkiteBase

        def invoke #:nodoc:

          if @url == :maven
            Buildr::artifact(@spec).invoke
          else
            Buildr::download(Buildr::artifact(@spec) => @url).invoke
          end unless File.exists? @zip.to_s

          unzip_toolkit(@zip,@zip_destination)

          self
        end

        # :call-seq:
        #   from(url) => self
        #
        # * You can pass a url where the ToolkitArtifact should be downloaded from as a string:
        # FLEX_SDK.from("http://domain.tld/flex_sdk.zip")
        # * You can pass :maven as a parameter to download it from a maven repository:
        # FLEX_SDK.from(:maven)
        # * If you don't call this function at all, buildr-as3 will try and resolve a url on automatically
        def from(url)
          @url = url
          self
        end

        protected

        def system_unzip_toolkit(zip, destination)
          puts "Please make sure unzip is installed and in your PATH variable!"

          project_dir = Dir.getwd
          Dir.chdir File.dirname(zip.to_s)
          system("unzip #{File.basename(zip.to_s).to_s} -d #{File.basename(destination).to_s}")
          Dir.chdir project_dir
        end

        def system_untar_toolkit(zip, destination)
          puts "Attempting to extract a non-windows archive?" if Buildr::Util.win_os?
          
          project_dir = Dir.getwd
          Dir.chdir File.dirname(zip.to_s)
          system("mkdir #{destination}; tar -xvjf #{zip.to_s} -C #{destination}")
          Dir.chdir project_dir
        end

        def unzip_toolkit(zip, destination)
          unless File.exists? destination
            puts "Unzipping Archive, this might take a while."

            # HACK: Had to check the URL to determine the file type here...
            if (@url.to_s =~ /\.tar\.bz2$/ || @url.to_s =~ /\.tbz2$/)
              system_untar_toolkit(zip, destination)
            else
              system_unzip_toolkit(zip, destination)
            end
            
          end
        end
      end
    end
  end
end
