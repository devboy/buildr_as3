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

require 'fileutils'
module Buildr
  module AS3
    module IDE
      module FDT4
        module Tasks
          include Buildr::Extension

          first_time do
            desc "Generates dependency file for FDT4 projects"
            Project.local_task('as3:fdt4:generate')
          end

          before_define do |project|
            project.recursive_task("as3:fdt4:generate")
          end

          after_define("as3:fdt4:generate" => :package) do |project|
            project.task("as3:fdt4:generate") do
              fail("Cannot create fdt4 projects on Windows machines, no support for symlinks.") if Buildr::Util.win_os?
              if [:mxmlc, :compc, :airmxmlc, :aircompc].include? project.compile.compiler
                output = project.base_dir + "/.settings/com.powerflasher.fdt.classpath"
                puts "Writing FDT4 classpath file: #{output}"
                puts "WARNING: This will create symlinks in #{project.path_to(:lib, :main, :as3)} as FDT4 doesn't support referencing files outside of the project folder."
                sdk_based_libs = []
                sdk_based_libs << "frameworks/libs/player/{playerVersion}/playerglobal.swc"
                sdk_based_libs << "frameworks/libs/flex.swc"
                sdk_based_libs << "frameworks/libs/textLayout.swc"
                sdk_based_libs << "frameworks/libs/framework.swc"
                sdk_based_libs << "frameworks/libs/framework.swc"
                sdk_based_libs << "frameworks/libs/rpc.swc"
                sdk_based_libs << "frameworks/libs/spark.swc"
                sdk_based_libs << "frameworks/libs/sparkskins.swc"
                sdk_based_libs << "frameworks/libs/datavisualization.swc"

                if [:airmxmlc, :aircompc].include? project.compile.compiler
                  sdk_based_libs << "frameworks/libs/air/airglobal.swc"
                  sdk_based_libs << "frameworks/libs/air/airframework.swc"
                  sdk_based_libs << "frameworks/libs/air/airspark.swc"
                  sdk_based_libs << "frameworks/libs/air/applicationupdater.swc"
                  sdk_based_libs << "frameworks/libs/air/applicationupdater_ui.swc"
                  sdk_based_libs << "frameworks/libs/air/servicemonitor.swc"
                end

                contents = ""
                classpath_xml = Builder::XmlMarkup.new(:target => contents, :indent => 4)
                classpath_xml.instruct!
                classpath_xml.AS3Classpath do
                  sdk_based_libs.each do |sdk_lib|
                    classpath_xml.AS3Classpath(sdk_lib, :generateProblems => false, :sdkBased => true, :type => "lib", :useAsSharedCode => "false")
                  end
                  project.compile.sources.each do |source|
                    classpath_xml.AS3Classpath(project.get_eclipse_relative_path(project, source), :generateProblems => true, :sdkBased => false, :type => project.get_fdt4_classpath_type(source), :useAsSharedCode => "false")
                  end
                  unless File.directory? project.path_to(:lib, :main, :as3)
                    #:dummy is just a bogus thing, it somehow stops creating the folders a layer to early
                    FileUtils.mkdir_p File.dirname(project.path_to(:lib, :main, :as3, :dummy))
                  end
                  project.compile.dependencies.each do |dependency|
                    dependency = project.create_fdt4_dependency_symlink(project, dependency)
                    classpath_xml.AS3Classpath(project.get_eclipse_relative_path(project, dependency), :generateProblems => false, :sdkBased => false, :type => project.get_fdt4_classpath_type(dependency), :useAsSharedCode => "false")
                  end
                end

                unless File.directory? File.dirname(output)
                  Dir.mkdir File.dirname(output)
                end
                File.open(output, 'w') { |f| f.write(contents) }
              end
            end
          end

          def create_fdt4_dependency_symlink(project, dependency)
            case dependency
              when Buildr::Artifact then
                path = dependency.name
              else
                path = dependency.to_s
            end
            target = project.path_to(:lib, :main, :as3) + "/" + File.basename(path)
            if target != path
              unless File.exists?(target) && !File.symlink?(target)
                puts "Creating symlink: #{target}"
                File.delete(target) if File.exists?(target)
                File.symlink path, target
              end
            end
            target
          end

          def get_eclipse_relative_path(project, source)
            case source
              when Buildr::Artifact then
                path = source.name
              else
                path = source.to_s
            end
            Util.relative_path(File.expand_path(path), project.base_dir)
          end

          def get_fdt4_classpath_type(source)
            case source
              when Buildr::Artifact then
                return "source" if File.directory?(source.name)
                return "lib" if File.extname(source.name) == ".swc"
              else

                return "source" if File.directory?(source.to_s)
                return "lib" if File.extname(source.to_s) == ".swc"
            end
            "Could not guess type!"
          end

        end
      end
    end
  end
  class Project
    include Buildr::AS3::IDE::FDT4::Tasks
  end
end