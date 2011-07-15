# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{buildr-as3}
  s.version = "0.2.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dominic Graefen"]
  s.date = %q{2011-07-15}
  s.default_executable = %q{buildr-as3}
  s.description = %q{Build like you code - now supporting ActionScript 3 & Flex}
  s.email = %q{dominic @nospam@ devboy.org}
  s.executables = ["buildr-as3"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/buildr-as3",
    "buildr-as3.gemspec",
    "lib/buildr/as3.rb",
    "lib/buildr/as3/compiler.rb",
    "lib/buildr/as3/compiler/aircompc.rb",
    "lib/buildr/as3/compiler/airmxmlc.rb",
    "lib/buildr/as3/compiler/base.rb",
    "lib/buildr/as3/compiler/compc.rb",
    "lib/buildr/as3/compiler/mxmlc.rb",
    "lib/buildr/as3/compiler/task.rb",
    "lib/buildr/as3/doc.rb",
    "lib/buildr/as3/doc/asdoc.rb",
    "lib/buildr/as3/ide.rb",
    "lib/buildr/as3/ide/fdt4.rb",
    "lib/buildr/as3/packaging.rb",
    "lib/buildr/as3/packaging/air.rb",
    "lib/buildr/as3/packaging/airi.rb",
    "lib/buildr/as3/packaging/swc.rb",
    "lib/buildr/as3/packaging/swf.rb",
    "lib/buildr/as3/project.rb",
    "lib/buildr/as3/test.rb",
    "lib/buildr/as3/test/base.rb",
    "lib/buildr/as3/test/flexunit4.rb",
    "lib/buildr/as3/toolkits.rb",
    "lib/buildr/as3/toolkits/alchemy.rb",
    "lib/buildr/as3/toolkits/apparat.rb",
    "lib/buildr/as3/toolkits/base.rb",
    "lib/buildr/as3/toolkits/flexsdk.rb",
    "test/helper.rb",
    "test/test_buildr_as3.rb"
  ]
  s.homepage = %q{http://github.com/devboy/buildr_as3}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Buildr extension to allow ActionScript3/Flex development.}
  s.test_files = [
    "test/helper.rb",
    "test/test_buildr_as3.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<buildr>, ["~> 1.4.6"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_runtime_dependency(%q<buildr>, [">= 1.4.5"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<buildr>, ["~> 1.4.6"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<buildr>, [">= 1.4.5"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<buildr>, ["~> 1.4.6"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<buildr>, [">= 1.4.5"])
  end
end

