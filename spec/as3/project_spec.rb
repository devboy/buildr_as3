require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helpers'))

describe Buildr::Project do

  it "should get the correct as3 output for a compile project for a swf" do
    define('foo') do
      compile.using(:mxmlc, :main => _(:src,:main,:as3,"Main.as"))
      get_as3_output(false).to_s.should eql(_(:target,:bin,"Main.swf"))
    end
  end

  it "should get the correct as3 output for a compile project for a swf from output option" do
    define('foo') do
      compile.using(:mxmlc, :main => _(:src,:main,:as3,"Main.as"), :output => _(:target,:bin,"Output.swf"))
      get_as3_output(false).to_s.should eql(_(:target,:bin,"Output.swf"))
    end
  end

  it "should get the correct as3 output for a compile project for a swc" do
    define('foo') do
      compile.using(:compc)
      get_as3_output(false).to_s.should eql(_(:target,:bin,"foo.swc"))
    end
  end

  it "should get the correct as3 output for a compile project for a swc from output option" do
    define('foo') do
      compile.using(:compc,:output => _(:target,:bin,"Output.swc"))
      get_as3_output(false).to_s.should eql(_(:target,:bin,"Output.swc"))
    end
  end

  it "should get the correct as3 output for a test project for a swf" do
    define('foo') do
      test.compile.using(:mxmlc, :main => _(:src,:test,:as3,"TestRunner.mxml"))
      get_as3_output(true).to_s.should eql(_(:target,:test,:bin,"TestRunner.swf"))
    end
  end

  it "should get the correct as3 output for a test project for a swf from output option" do
    define('foo') do
      test.compile.using(:mxmlc, :main => _(:src,:test,:as3,"TestRunner.mxml"),:output => _(:target,:test,:bin,"Output.swf"))
      get_as3_output(true).to_s.should eql(_(:target,:test,:bin,"Output.swf"))
    end
  end

  after do
    Buildr.options.debug = nil
    ENV.delete "debug"
    ENV.delete "DEBUG"
  end

end