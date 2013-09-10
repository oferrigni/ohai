#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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


require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb')

describe Ohai::System, "NetBSD kernel plugin" do
  before(:each) do
    @plugin = get_plugin("netbsd/kernel")
    @plugin.stub(:shell_out).with("uname -i").and_return([0, "foo", ""])
    @plugin.stub(:shell_out).with("sysctl kern.securelevel").and_return([0, "kern.securelevel: 1\n", ""])
    # @plugin.stub(:shell_out).with("#{ Ohai.abs_path( "/usr/bin/modstat" )}").and_return([0, "  1    7 0xc0400000 97f830   kernel", ""])
    @plugin.stub(:shell_out).with("#{ Ohai.abs_path( "/usr/bin/modstat" )}").and_return([0, "", ""])
    @plugin[:kernel] = Mash.new
    @plugin[:kernel][:name] = "netbsd"
  end

  it "should set the kernel_os to the kernel_name value" do
    @plugin.run
    @plugin[:kernel][:os].should == @plugin[:kernel][:name]
  end
end
