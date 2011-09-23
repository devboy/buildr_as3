require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helpers'))

describe Buildr::AS3::Compiler::Compc do

  it 'should not identify itself from source directories' do
    write 'src/main/java/com/example/Test.as', 'package com.example{ class Test {} }'
    define('foo').compile.compiler.should_not eql(:compc)
  end

  it 'should report the language as :actionscript' do
    define('foo').compile.using(:compc).language.should eql(:actionscript)
  end

  it 'should set the target directory to target/bin' do
    define 'foo' do
      lambda { compile.using(:compc) }.should change { compile.target.to_s }.to(File.expand_path('target/bin'))
    end
  end

  it 'should not override existing target directory' do
    define 'foo' do
      compile.into('classes')
      lambda { compile.using(:compc) }.should_not change { compile.target }
    end
  end

  it 'should not change existing list of sources' do
    define 'foo' do
      compile.from('sources')
      lambda { compile.using(:compc) }.should_not change { compile.sources }
    end
  end

  after do
    Buildr.options.debug = nil
    ENV.delete "debug"
    ENV.delete "DEBUG"
  end
end



describe "Buildr::AS3::Compiler::Compc compiler options" do

  def compile_task
    @compile_task ||= define('foo').compile.using( :compc, :flexsdk => FlexSDK.new("4.5.0.20967") )
  end

  def flex_sdk
    compile_task.options.flexsdk
  end

  def output
    compile_task.options.output
  end

  def target
    compile_task.target
  end

  def dependencies
    compile_task.as3_dependencies
  end

  def sources
    compile_task.sources
  end

  def compc_args
    compiler.send(:compiler_args,dependencies,flex_sdk,output,sources)
  end

  def compiler
    compile_task.instance_eval { @compiler }
  end

  it 'should set warnings option to true by default' do
    compile_task.options.warnings.should be_true
  end

  it 'should set debug option to true by default' do
    compile_task.options.debug.should be_true
  end

  it 'should set debug option to false based on Buildr.options' do
    Buildr.options.debug = false
    compile_task.options.debug.should be_false
  end

  it 'should set debug option to false based on debug environment variable' do
    ENV['debug'] = 'no'
    compile_task.options.debug.should be_false
  end

  it 'should set debug option to false based on DEBUG environment variable' do
    ENV['DEBUG'] = 'no'
    compile_task.options.debug.should be_false
  end

  it 'should use -debug=true argument when debug option is true' do
    compile_task.using(:debug=>true)
    compc_args.should include('-debug=true')
  end

  it 'should not use -debug=true argument when debug option is false' do
    compile_task.using(:debug=>false)
    compc_args.should_not include('-debug=true')
  end

  it 'should define CONFIG::debug,true when debug option is true' do
    compile_task.using(:debug=>true)
    compc_args.should include('-define+=CONFIG::debug,true')
  end

   it 'should define CONFIG::debug,false when debug option is false' do
    compile_task.using(:debug=>false)
    compc_args.should include('-define+=CONFIG::debug,false')
  end

  it 'should use -warnings=true argument when warnings option is true' do
    compile_task.using(:warnings=>true)
    compc_args.should_not include('-warnings=false')
  end

  it 'should not use -warnings=true argument when warnings option is false' do
    compile_task.using(:warnings=>false)
    compc_args.should include('-warnings=false')
  end

  it 'should point to the correct compiler jar' do
    compiler.instance_eval{ compiler_jar }.should eql( flex_sdk.compc_jar )
  end

  it 'should not identify itself as an air compiler' do
    compiler.instance_eval{ air }.should_not eql( true )
  end

  it "should not use +configname=air ever" do
    compc_args.should_not include('+configname=air')
  end

  it "should not use air config file ever" do
    compc_args.should_not include(flex_sdk.air_config)
  end

  it "should use flex config file by default" do
    compc_args.should include(flex_sdk.flex_config)
  end

  it "should not identify itself as a test task when it's not" do
    compiler.send(:is_test,sources,target,dependencies).should eql(false)
  end

  after do
    Buildr.options.debug = nil
    ENV.delete "debug"
    ENV.delete "DEBUG"
  end

end