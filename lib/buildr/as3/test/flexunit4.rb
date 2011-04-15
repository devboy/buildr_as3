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

require 'buildr'
require 'fileutils'

module Buildr
  module AS3
    module Test
      # JUnit test framework, the default test framework for Java tests.
      #
      # Support the following options:
      # * :fork        -- If true/:once (default), fork for each test class.  If :each, fork for each individual
      #                   test case.  If false, run all tests in the same VM (fast, but dangerous).
      # * :clonevm     -- If true clone the VM each time it is forked.
      # * :properties  -- Hash of system properties available to the test case.
      # * :environment -- Hash of environment variables available to the test case.
      # * :java_args   -- Arguments passed as is to the JVM.
      class FlexUnit4 < TestFramework::AS3
        # JUnit version number.
#        VERSION = '4.1'

#        class << self
          # :call-seq:
          #    report()
          #
          # Returns the Report object used by the junit:report task. You can use this object to set
          # various options that affect your report, for example:
          #   JUnit.report.frames = false
          #   JUnit.report.params['title'] = 'My App'
#          def report
#            @report ||= JUnit::Report.new
#          end

#          def version
#            Buildr.settings.build['junit'] || VERSION
#          end

#          def dependencies
#            super
#            @dependencies ||= ["junit:junit:jar:#{version}"]+ JMock.dependencies
#          end

#          def ant_taskdef #:nodoc:
#            "org.apache.ant:ant-junit:jar:#{Ant.version}"
#          end

#          private
#          def const_missing(const)
#            return super unless const == :REQUIRES # TODO: remove in 1.5
#            Buildr.application.deprecated "Please use JUnit.dependencies/.version instead of JUnit::REQUIRES/VERSION"
#            dependencies
#          end
#        end

        def tests(dependencies) #:nodoc:
          candidates = Dir["#{task.project.test.compile.sources[0]}/**/*Test.as"] + Dir["#{task.project.test.compile.sources[0]}/**/*Test.mxml"]
          candidates.collect{|file|file=File.basename(file,'.*')}
        end

        def run(tests, dependencies) #:nodoc:
          p tests
          report_dir = task.project.base_dir + "/reports/flexunit4"
          FileUtils.mkdir_p report_dir
          project_dir = Dir.getwd
          Dir.chdir report_dir
          Buildr.ant("flexunit4test") do |ant|

            ant.property :name => "FLEX_HOME", :location=>task.project.compile.options[:flexsdk].home
            taskdef = "/Users/devboy/Downloads/flexunit-flexunit-63a89a9/FlexUnit4AntTasks/target/flexUnitTasks-4.1.0.jar"
            ant.taskdef :resource => "flexUnitTasks.tasks", :classpath => taskdef

            ant.flexunit  :player => "flash",
                          :haltonFailure => false,
                          :verbose => true,
                          :localTrusted => true,
                          :swf => task.project.get_as3_output(task.project.test.compile.target,task.project.test.compile.options)
            ant.taskdef :name=>'junitreport', :classname=>'org.apache.tools.ant.taskdefs.optional.junit.XMLResultAggregator',
                        :classpath=>Buildr.artifacts(JUnit.ant_taskdef).each(&:invoke).map(&:to_s).join(File::PATH_SEPARATOR)

            ant.junitreport :todir => report_dir do
              ant.fileset :dir => report_dir do
                ant.include :name => "TEST-*.xml"
              end
              ant.report :format => "frames", :todir => report_dir + "/html"
            end

          end
          Dir.chdir project_dir
          tests
        end

      end
    end
  end
end
