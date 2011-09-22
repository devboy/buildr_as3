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


require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helpers'))


describe Buildr::AS3::Compiler::Mxmlc do

  it 'should report the language as :actionscript' do
    define('foo').compile.using(:mxmlc).language.should eql(:actionscript)
  end

  it 'should set the target directory to target/bin' do
    define 'foo' do
      lambda { compile.using(:mxmlc) }.should change { compile.target.to_s }.to(File.expand_path('target/bin'))
    end
  end

  it 'should not override existing target directory' do
    define 'foo' do
      compile.into('classes')
      lambda { compile.using(:mxmlc) }.should_not change { compile.target }
    end
  end

  it 'should not change existing list of sources' do
    define 'foo' do
      compile.from('sources')
      lambda { compile.using(:mxmlc) }.should_not change { compile.sources }
    end
  end

  after do
    Buildr.options.debug = nil
    ENV.delete "debug"
    ENV.delete "DEBUG"
  end
end

