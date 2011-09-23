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

# Let's enhance the CompileTask here!

require "buildr/core/compile"

class Buildr::CompileTask

  attr_accessor :as3_dependencies

  def with(*specs)

    @as3_dependencies ||= {}
    @as3_dependencies[:library] ||= FileList[]
    @as3_dependencies[:external] ||= FileList[]
    @as3_dependencies[:include] ||= FileList[]

    specs.each do |spec|
      case spec
        when Hash
          spec.each{ |key,value|
            raise "key needs to be :library, :external or :include" unless [:library, :external, :include].include? key
            @as3_dependencies[key] |= Buildr.artifacts(value).uniq
            @dependencies |= Buildr.artifacts(value).uniq
          }
        else
          @as3_dependencies[:library] |= Buildr.artifacts(spec).uniq
          @dependencies |= Buildr.artifacts(spec).uniq
      end
    end
    self
  end

end