#
# Copyright (C) 2012 by Justin Walsh / http://theJustinWalsh.com
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
      class AirSDK < Buildr::AS3::Toolkits::ZipToolkiteBase

        attr_reader :home, :version

        def initialize(version)
          @version = version
          @spec = "com.adobe.air:sdk:zip:#{version.gsub(/ /, '-')}"
          @zip = Buildr.artifact(@spec)
          @home = @zip_destination = File.join(File.dirname(@zip.to_s), "sdk-#{version.gsub(/ /, '-')}")
          self
        end

        def invoke #:nodoc:
          @url ||= generate_url_from_version @version
          super
          self
        end

        def from(url)
          @url = url
          self
        end
        private

        def generate_url_from_version(version)
          version_major = version.split(".")[0]
          version_minor = version.split(".")[1]
          version_id = "#{version_major}.#{version_minor}"
          os = Buildr::Util.win_os? ? "win" : "mac"
          ext = Buildr::Util.win_os? ? "zip" : "tbz2"
          
          "http://airdownload.adobe.com/air/#{os}/download/#{version_id}/AdobeAIRSDK.#{ext}"
        end
      end
    end
  end
end
