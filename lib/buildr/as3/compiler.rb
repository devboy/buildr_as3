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
#TODO: Refactor compiler classes, right now everything is copy&paste
module Buildr
  module Compiler
    module BuildInfo
      def write_build_info_class( source_path, project )
        file = File.join source_path, "org/devboy/buildras3/Build.as"
        puts "Write Build Info Class:"+file
        file_content =  "/**
 * Created by buildr-as3
 */
package org.devboy.buildras3 {
public class Build
{
    public static const PROJECT_NAME : String = '#{project.to_s}';
    public static const PROJECT_GROUP : String = '#{project.group.to_s}';
    public static const PROJECT_VERSION : String = '#{project.version.to_s}';
    public static const BUILD_TIME : String = '#{Time.now.to_s}';
}
}"
        File.open(file, 'w') {|f| f.write(file_content) }
      end
    end
    module NeededTools
      def is_output_outdated?(output,file_to_check)
        return true unless File.exists? output
        older(output,file_to_check)
      end

      def older(a,b) # a older than b
#        puts "OLDER"
#        puts a, timestamp_from_file(a)
#        puts b, timestamp_from_file(b)
        timestamp_from_file(a) < timestamp_from_file(b)
      end

      def timestamp_from_file(file)
        File.directory?(file) ? get_last_modified(file) : File.mtime(file)
      end

      def get_last_modified(dir)
        file_mtimes = []
        dirs = Dir.new(dir).select { |file| file!= '.' && file!='..' && File.directory?(dir+"/"+file)==true }
        dirs = dirs.collect { |subdir| dir+"/"+subdir }
        dirs.each { |subdir| file_mtimes << get_last_modified(subdir) }
        files = Dir.new(dir).select { |file| file!= '.' && file!='..' && File.directory?(dir+"/"+file)==false }
        files = files.collect { |file| dir+'/'+file }
        files.each { |file|
          file_mtimes << File.mtime(file)
#          puts "","checkFile:"
#          puts File.mtime(file).to_s
#          puts file.to_s, ""
        }
        file_mtimes.sort!
        file_mtimes.reverse!
        file_mtimes.length > 0 ? file_mtimes.first : Time.at(0)
      end

      def applies_to?(project, task) #:nodoc:
          trace "applies_to?: false"
          false
      end
    end
    class Mxmlc < Base
      specify :language => :actionscript,
              :sources => [:as3, :mxml], :source_ext => [:as, :mxml],
              :target => "bin", :target_ext => "swf",
              :packaging => :swf

      attr_reader :project

      def initialize(project, options)
        super
        @project = project
      end


      include NeededTools
      def needed?(sources, target, dependencies)
        main = options[:main]
        mainfile = File.basename(main, File.extname(main))
        output =  (options[:output] || "#{target}/#{mainfile}.swf")
        sources.each do |source|
          if is_output_outdated?(output, source)
#            puts "checkSource:" + source
            puts "Recompile needed: Sources are newer than target"
            return true
          end
        end
        dependencies.each do |dependency|
          if is_output_outdated?(output, dependency)
            puts "Recompile needed: Dependencies are newer than target"
            return true
          end
        end
        puts "Recompile not needed"
        false
      end


      include BuildInfo
      def compile(sources, target, dependencies)
#        write_build_info_class sources[0], project
        flex_sdk = options[:flexsdk]
        main = options[:main]
        mainfile = File.basename(main, File.extname(main))
        output =  (options[:output] || "#{target}/#{mainfile}.swf")

        cmd_args = []
        cmd_args << "-jar" << flex_sdk.mxmlc_jar
        cmd_args << "+flexlib" << "#{flex_sdk.home}/frameworks"
        cmd_args << main
        cmd_args << "-output" << output
        cmd_args << "-load-config" << flex_sdk.flex_config
        cmd_args << "-source-path" << sources.join(" ")
        cmd_args << "-library-path+=#{dependencies.join(",")}" unless dependencies.empty?
        reserved = [:flexsdk,:main]
        options.to_hash.reject { |key, value| reserved.include?(key) }.
            each do |key, value|
              cmd_args << "-#{key}=#{value}"
        end
        flex_sdk.default_options.each do |key, value|
              cmd_args << "-#{key}=#{value}"
        end

        unless Buildr.application.options.dryrun
          Java::Commands.java cmd_args
        end
      end
    end
    class AirMxmlc < Base
      specify :language => :actionscript,
              :sources => [:as3, :mxml], :source_ext => [:as, :mxml],
              :target => "bin", :target_ext => "swf",
              :packaging => :swf


      def initialize(project, options)
        super
      end


      include NeededTools
      def needed?(sources, target, dependencies)
        main = options[:main]
        mainfile = File.basename(main, File.extname(main))
        output =  (options[:output] || "#{target}/#{mainfile}.swf")
        sources.each do |source|
          if is_output_outdated?(output, source)
            puts "Recompile needed: Sources are newer than target"
            return true
          end
        end
        dependencies.each do |dependency|
          if is_output_outdated?(output, dependency)
            puts "Recompile needed: Dependencies are newer than target"
            return true
          end
        end
        puts "Recompile not needed"
        false
      end

      def compile(sources, target, dependencies)
        flex_sdk = options[:flexsdk]
        main = options[:main]
        mainfile = File.basename(main, File.extname(main))
        output =  (options[:output] || "#{target}/#{mainfile}.swf")

        cmd_args = []
        cmd_args << "-jar" << flex_sdk.mxmlc_jar
        cmd_args << "+flexlib" << "#{flex_sdk.home}/frameworks"
        cmd_args << main
        cmd_args << "-output" << output
        cmd_args << "-load-config" << flex_sdk.air_config
        cmd_args << "-source-path" << sources.join(" ")
        cmd_args << "-library-path+=#{dependencies.join(",")}" unless dependencies.empty?
        reserved = [:flexsdk,:main]
        options.to_hash.reject { |key, value| reserved.include?(key) }.
            each do |key, value|
              cmd_args << "-#{key}=#{value}"
        end
        flex_sdk.default_options.each do |key, value|
              cmd_args << "-#{key}=#{value}"
        end

        unless Buildr.application.options.dryrun
          Java::Commands.java cmd_args
        end
      end
    end
    class Compc < Base
      specify :language => :actionscript,
              :sources => [:as3, :mxml], :source_ext => [:as, :mxml],
              :target => "bin", :target_ext => "swc",
              :packaging => :swc
      attr_reader :project
      def initialize(project, options)
        super
        @project = project
      end
      include NeededTools
      def needed?(sources, target, dependencies)
        output =  (options[:output] || "#{target}/#{project.name.gsub(":", "-")}.swc")
        sources.each do |source|
          return true if is_output_outdated?(output,source)
        end
        dependencies.each do |dependency|
          return true if is_output_outdated?(output,dependency)
        end
        puts "Recompile not needed"
        false
      end

      def compile(sources, target, dependencies)
#        write_build_info_class sources[0], project
        flex_sdk = options[:flexsdk]
        output =  (options[:output] || "#{target}/#{project.name.gsub(":", "-")}.swc")
        cmd_args = []
        cmd_args << "-jar" << flex_sdk.compc_jar
        cmd_args << "-output" << output
        cmd_args << "+flexlib" << "#{flex_sdk.home}/frameworks"
        cmd_args << "-load-config" << flex_sdk.flex_config
        cmd_args << "-include-sources" << sources.join(" ")
        cmd_args << "-library-path+=#{dependencies.join(",")}" unless dependencies.empty?
        reserved = [:flexsdk, :main]
        options.to_hash.reject { |key, value| reserved.include?(key) }.
            each do |key, value|
              cmd_args << "-#{key}=#{value}"
            end
        flex_sdk.default_options.each do |key, value|
              cmd_args << "-#{key}=#{value}"
        end

        unless Buildr.application.options.dryrun
          Java::Commands.java cmd_args
        end
      end
    end
    class AirCompc < Base
      specify :language => :actionscript,
              :sources => [:as3, :mxml], :source_ext => [:as, :mxml],
              :target => "bin", :target_ext => "swc",
              :packaging => :swc
      attr_reader :project
      def initialize(project, options)
        super
        @project = project
      end
      include NeededTools
      def needed?(sources, target, dependencies)
        output =  (options[:output] || "#{target}/#{project.name.gsub(":", "-")}.swc")
        sources.each do |source|
          if is_output_outdated?(output, source)
            puts "Recompile needed: Sources are newer than target"
            return true
          end
        end
        dependencies.each do |dependency|
          if is_output_outdated?(output, dependency)
            puts "Recompile needed: Dependencies are newer than target"
            return true
          end
        end
        false
      end

      def compile(sources, target, dependencies)
        flex_sdk = options[:flexsdk]
        output =  (options[:output] || "#{target}/#{project.to_s}.swc")
        cmd_args = []
        cmd_args << "-jar" << flex_sdk.compc_jar
        cmd_args << "-output" << output
        cmd_args << "-load-config" << flex_sdk.air_config
        cmd_args << "+flexlib" << "#{flex_sdk.home}/frameworks"
        cmd_args << "-include-sources" << sources.join(" ")
        cmd_args << "-library-path+=#{dependencies.join(",")}" unless dependencies.empty?
        reserved = [:flexsdk, :main]
        options.to_hash.reject { |key, value| reserved.include?(key) }.
            each do |key, value|
              cmd_args << "-#{key}=#{value}"
            end
        flex_sdk.default_options.each do |key, value|
              cmd_args << "-#{key}=#{value}"
        end

        unless Buildr.application.options.dryrun
          Java::Commands.java cmd_args
        end
      end
    end
    class AlcGcc < Base
      specify :language => :c,
              :sources => :c, :source_ext => :c,
              :target => "bin", :target_ext => "swc",
              :packaging => :swc

      attr_reader :project

      def initialize(project, options)
        super
        @project = project
      end


      include NeededTools
      def needed?(sources, target, dependencies)
        true
#        main = options[:main]
#        mainfile = File.basename(main, File.extname(main))
#        output =  (options[:output] || "#{target}/#{mainfile}.swf")
#        sources.each do |source|
#          if is_output_outdated?(output, source)
#            puts "Recompile needed: Sources are newer than target"
#            return true
#          end
#        end
#        dependencies.each do |dependency|
#          if is_output_outdated?(output, dependency)
#            puts "Recompile needed: Dependencies are newer than target"
#            return true
#          end
#        end
#        puts "Recompile not needed"
#        false
      end


      include BuildInfo
      def compile(sources, target, dependencies)
        alchemy_tk = options[:alchemytk]
        flex_sdk = alchemy_tk.flex_sdk
        output =  (options[:output] || "#{target}/#{project.name.gsub(":", "-")}.swc")

        # gcc stringecho.c -O3 -Wall -swc -o stringecho.swc
        cmd_args = []
        cmd_args << "gcc"
        cmd_args << File.basename(options[:main])
        cmd_args << "-O3 -Wall -swc"
        cmd_args << "-o #{File.basename output}"

        reserved = [:flexsdk,:main,:alchemytk]
        options.to_hash.reject { |key, value| reserved.include?(key) }.
            each do |key, value|
              cmd_args << "-#{key}=#{value}"
        end

        unless Buildr.application.options.dryrun
          ENV["ALCHEMY_HOME"]= alchemy_tk.home
          ENV["ALCHEMY_VER"] = "0.4a"
          ENV["PATH"] = "#{alchemy_tk.bin}:#{ENV["PATH"]}"
          ENV["ASC"]="#{alchemy_tk.home}/bin/asc.jar"
          ENV["SWFBRIDGE"]="#{alchemy_tk.home}/bin/swfbridge"
          ENV["PATH"] = "#{alchemy_tk.achacks}:#{ENV["PATH"]}"
          ENV["PATH"] = "#{ENV["PATH"]}:#{flex_sdk.bin}"
          project_dir = Dir.getwd
          Dir.chdir File.dirname options[:main]
          system(cmd_args.join(" "))
          File.copy( File.basename(output), output)
          Dir.chdir project_dir
        end
      end
    end
  end
end
Buildr::Compiler.compilers << Buildr::Compiler::Mxmlc
Buildr::Compiler.compilers << Buildr::Compiler::Compc
Buildr::Compiler.compilers << Buildr::Compiler::AirMxmlc
Buildr::Compiler.compilers << Buildr::Compiler::AirCompc
Buildr::Compiler.compilers << Buildr::Compiler::AlcGcc
