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
require "rexml/document"

module Buildr
  module AS3
    module Test
      # FlexUnit4 test framework.
      #
      # Support the following options:
      # * :player     -- ["air","flash"] defines the player to run the tests, when not set it chooses based on the projects compiler.
      # * :haltonFailure     -- [Boolean] stop unit-testing on error
      # * :verbose     -- [Boolean] print additional info
      # * :localTrusted     -- [Boolean] some sandbox thing
      # * :htmlreport     -- [Boolean] set to true if you want to create a JUnit HTML report
      class FlexUnit4 < TestFramework::AS3

        DEFAULT_FLEXUNIT_VERSION = '4.1.0-8'
        DEFAULT_FLEX_SDK_VERSION = '4.1.0.16076'

        class << self

          def flexunit_tasks flexunit_version=DEFAULT_FLEXUNIT_VERSION
            "com.adobe.flexunit:flexUnitTasks:jar:#{flexunit_version}"
          end

          def swcs flexunit_version=DEFAULT_FLEXUNIT_VERSION, flexsdk_version=DEFAULT_FLEX_SDK_VERSION, type=:as3
            raise "type has to be :as3 or :flex" unless [:flex, :as3].include? type
            [
                "com.adobe.flexunit:flexunit-cilistener:swc:#{flexsdk_version}:#{flexunit_version}",
                "com.adobe.flexunit:flexunit-aircilistener:swc:#{flexsdk_version}:#{flexunit_version}",
                "com.adobe.flexunit:flexunit-#{type.to_s}:swc:#{flexsdk_version}:#{flexunit_version}",
                "com.adobe.flexunit:flexunit-flexcoverlistener:swc:#{flexsdk_version}:#{flexunit_version}",
                "com.adobe.flexunit:flexunit-uilistener:swc:#{flexsdk_version}:#{flexunit_version}",
                "com.adobe.flexunit:fluint-extensions:swc:#{flexsdk_version}:#{flexunit_version}",
            ]
          end
        end

        def tests(dependencies) #:nodoc:
          candidates = []
          task.project.test.compile.sources.each do |source|
            files = Dir["#{source}/**/*Test.as"] + Dir["#{source}/**/*Tests.as"]
            files.each { |item|
              if File.dirname(item) == source
                candidates << File.basename(item, '.*')
              else
                candidates << "#{File.dirname(item).gsub!(source+"/", "").gsub!("/", ".")}.#{File.basename(item, '.*')}"
              end
            }
          end
          candidates
        end

        def run(tests, dependencies) #:nodoc:

          report_dir = task.project._(:reports, FlexUnit4.to_sym)
          FileUtils.mkdir_p report_dir

          project_dir = Dir.getwd
          Dir.chdir report_dir

          unless options[:antjar]
            taskdef = Buildr.artifact(FlexUnit4.flexunit_tasks options[:version] || DEFAULT_FLEXUNIT_VERSION)
            taskdef.invoke
          else
            taskdef = options[:antjar]
          end

          player = "air" if [:airmxmlc, :airompc].include?(task.project.compile.compiler) || options[:player] == "air"
          player ||= "flash"

          Buildr.ant("flexunit4") do |ant|

            ant.property :name => "FLEX_HOME",
                         :location=>task.project.compile.options[:flexsdk].home

            ant.taskdef :resource => "flexUnitTasks.tasks",
                        :classpath => taskdef.to_s

            ant.flexunit :player => player,
                         :haltonFailure => options[:haltonFailure] || false,
                         :verbose => options[:verbose] || false,
                         :localTrusted => options[:localTrusted] || true,
                         :headless => options[:headless] || false,
                         :display => options[:display] || 99,
                         :port => options[:port] || 1024,
                         :swf => get_output_file(task.project)

            ant.taskdef :name=>'junitreport',
                        :classname=>'org.apache.tools.ant.taskdefs.optional.junit.XMLResultAggregator',
                        :classpath=>Buildr.artifacts(JUnit.ant_taskdef).each(&:invoke).map(&:to_s).join(File::PATH_SEPARATOR)

            unless options[:htmlreport] == false
              ant.junitreport :todir => report_dir do
                ant.fileset :dir => report_dir do
                  ant.include :name => "TEST-*.xml"
                end
                ant.report :format => "frames", :todir => report_dir + "/html"
              end
            end


            Dir[report_dir+"/TEST-*.xml"].each do |xml_report|
              doc = REXML::Document.new File.new(xml_report)
              name = doc.elements["testsuite"].attributes["name"]
              failures = Integer(doc.elements["testsuite"].attributes["failures"])
              errors = Integer(doc.elements["testsuite"].attributes["errors"])
              tests -= [name] unless failures + errors == 0
            end

          end
          Dir.chdir project_dir
          tests
        end

        def get_output_file project
          compile = project.test.compile
          File.join(compile.target.to_s, compile.options[:output] || "#{project.name.split(":").last}.#{compile.packaging.to_s}")
        end

      end
    end
  end

end

Object::FlexUnit4 = Buildr::AS3::Test::FlexUnit4