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
      class Player

        attr_reader :home, :version, :swc

        def initialize(version)
          @version = version
          if v = /^[0-9.]+/.match(@version) then @version = v[0] end
          @spec = "com.adobe.flex:player:swc:#{version.gsub(/ /, '-')}"
          @playerglobal = Buildr.artifact(@spec)
          @home = File.dirname(@playerglobal.to_s)
          @swc = @playerglobal.to_s
          self
        end

        def invoke #:nodoc:
          @url ||= generate_url_from_version @version

          Buildr::download(Buildr::artifact(@spec) => @url).invoke
          return unless File.exists? @playerglobal.to_s

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
          version_minor = 0 # Adobe doesn't seem to store the player global properly
          version_id = "#{version_major}_#{version_minor}"
          
          "http://fpdownload.macromedia.com/pub/flashplayer/updaters/#{version_major}/playerglobal#{version_id}.swc"
        end
      end
    end
  end
end