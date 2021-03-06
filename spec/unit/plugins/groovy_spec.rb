#
# Author:: Doug MacEachern <dougm@vmware.com>
# Copyright:: Copyright (c) 2009 VMware, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper.rb'))

describe Ohai::System, "plugin groovy" do

  before(:each) do
    @plugin = get_plugin("groovy")
    @plugin[:languages] = Mash.new
    @status = 0
    @stdout = "Groovy Version: 1.6.3 JVM: 1.6.0_0\n"
    @stderr = ""
    @plugin.stub(:run_command).with({:no_status_check=>true, :command=>"groovy -v"}).and_return([@status, @stdout, @stderr])
  end

  it "should get the groovy version from running groovy -v" do
    @plugin.should_receive(:run_command).with({:no_status_check=>true, :command=>"groovy -v"}).and_return([0, "Groovy Version: 1.6.3 JVM: 1.6.0_0\n", ""])
    @plugin.run
  end

  it "should set languages[:groovy][:version]" do
    @plugin.run
    @plugin.languages[:groovy][:version].should eql("1.6.3")
  end

  it "should not set the languages[:groovy] tree up if groovy command fails" do
    @status = 1
    @stdout = "Groovy Version: 1.6.3 JVM: 1.6.0_0\n"
    @stderr = ""
    @plugin.stub(:run_command).with({:no_status_check=>true, :command=>"groovy -v"}).and_return([@status, @stdout, @stderr])
    @plugin.run
    @plugin.languages.should_not have_key(:groovy)
  end

end
