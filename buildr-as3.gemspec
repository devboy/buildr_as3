# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "buildr-as3"
  s.version = "0.2.31.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dominic Graefen"]
  s.date = "2011-12-10"
  s.description = "Build like you code - now supporting ActionScript 3 & Flex"
  s.email = "dominic @nospam@ devboy.org"
  s.executables = ["buildr-as3"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
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
    "rake/jeweler.rb",
    "rake/jeweler_prerelease_tasks.rb",
    "rake/pre_release_gemspec.rb",
    "rake/pre_release_to_git.rb",
    "spec/as3/compiler/aircompc_spec.rb",
    "spec/as3/compiler/airmxmlc_spec.rb",
    "spec/as3/compiler/compc_spec.rb",
    "spec/as3/compiler/mxmlc_spec.rb",
    "spec/as3/compiler/task_spec.rb",
    "spec/as3/project_spec.rb",
    "spec/sandbox.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/devboy/buildr_as3"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Buildr extension to allow ActionScript3/Flex development."
  s.test_files = [
    "spec/as3/compiler/aircompc_spec.rb",
    "spec/as3/compiler/airmxmlc_spec.rb",
    "spec/as3/compiler/compc_spec.rb",
    "spec/as3/compiler/mxmlc_spec.rb",
    "spec/as3/compiler/task_spec.rb",
    "spec/as3/project_spec.rb",
    "spec/sandbox.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<buildr>, ["~> 1.4.6"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<simplecov-rcov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.1.0"])
      s.add_development_dependency(%q<ci_reporter>, ["~> 1.6.5"])
      s.add_runtime_dependency(%q<buildr>, [">= 1.4.6"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<buildr>, ["~> 1.4.6"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<simplecov-rcov>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.1.0"])
      s.add_dependency(%q<ci_reporter>, ["~> 1.6.5"])
      s.add_dependency(%q<buildr>, [">= 1.4.6"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<buildr>, ["~> 1.4.6"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<simplecov-rcov>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.1.0"])
    s.add_dependency(%q<ci_reporter>, ["~> 1.6.5"])
    s.add_dependency(%q<buildr>, [">= 1.4.6"])
  end
end

