require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helpers'))

describe Buildr::CompileTask do

  it "should create an as3_dependecies property" do
    define('foo').compile.with().as3_dependencies.should_not be(nil)
  end

  it "should create FileList for dependency type library" do
    define('foo').compile.with().as3_dependencies[:library].should be_a FileList
  end

  it "should create FileList for dependency type external" do
    define('foo').compile.with().as3_dependencies[:external].should be_a FileList
    end

  it "should create FileList for dependency type  include" do
    define('foo').compile.with().as3_dependencies[:include].should be_a FileList
  end

  it "should add dependency to library type when :library is specified" do
    define('foo').compile.with(:library => "myLibrary.swc").as3_dependencies[:library].should include(File.join( pwd, "myLibrary.swc"))
  end

  it "should add dependency to @dependencies when :library is specified" do
    define('foo').compile.with(:library => "myLibrary.swc").dependencies.should include(File.join( pwd, "myLibrary.swc"))
  end

  it "should add dependency to library when nothing is specified" do
    define('foo').compile.with("myLibrary.swc").as3_dependencies[:library].should include(File.join( pwd, "myLibrary.swc"))
  end

  it "should add dependency to include type when :include is specified" do
    define('foo').compile.with(:include => "myLibrary.swc").as3_dependencies[:include].should include(File.join( pwd, "myLibrary.swc"))
  end

  it "should add dependency to @dependencies when :include is specified" do
    define('foo').compile.with(:include => "myLibrary.swc").dependencies.should include(File.join( pwd, "myLibrary.swc"))
  end

  it "should add dependency to external type when :external is specified" do
    define('foo').compile.with(:external => "myLibrary.swc").as3_dependencies[:external].should include(File.join( pwd, "myLibrary.swc") )
  end

  it "should add dependency to @dependencies when :external is specified" do
    define('foo').compile.with(:external => "myLibrary.swc").dependencies.should include(File.join( pwd, "myLibrary.swc"))
  end

  it "should be possible to add multiple dependency types at once" do
    deps = define('foo').compile.with(:library => "lib1.swc", :external => "extern.swc", :include => "include.swc").with("lib2.swc").as3_dependencies
    deps[:library].should include( File.join(pwd,"lib1.swc" ))
    deps[:library].should include( File.join(pwd,"lib2.swc" ))
    deps[:external].should include( File.join(pwd,"extern.swc" ))
    deps[:include].should include( File.join(pwd,"include.swc" ))
  end

  it "should throw and error for incorrect dependecy type" do
    lambda { define('foo').compile.with(:incorrect => "incorrect.swc") }.should raise_error
  end

  after do
    Buildr.options.debug = nil
    ENV.delete "debug"
    ENV.delete "DEBUG"
  end
end