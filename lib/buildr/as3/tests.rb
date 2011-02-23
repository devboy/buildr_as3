# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

require 'buildr/core/test'
require 'buildr/core/build'
require 'buildr/core/compile'
require 'buildr/java/ant'


module Buildr

  class FlexUnit4 < TestFramework::Base

    class << self
      taskdef_spec = "org.flexunit:flexUnitTasks:jar:4.1.0"
       def applies_to?(project) #:nodoc:
        project.test.compile.language == :actionscript
      end
    end

#    def initialize
#      puts "FlexUnit4 init"
#    end

    def tests(dependencies) #:nodoc:
      puts "FlexUnit4 run"
      []
    end

    def run(tests, dependencies) #:nodoc:
      puts "FlexUnit4 run"
      Buildr.ant('flexunit') do |ant|
        taskdef = Buildr.artifact(FlexUnit4.taskdef_spec)
        taskdef.invoke
        ant.taskdef :name=>'flexunit', :resource=>"flexUnitTasks.tasks", :classpath=>taskdef.to_s
      end
    end
  end

end

Buildr::TestFramework.add Buildr::FlexUnit4
