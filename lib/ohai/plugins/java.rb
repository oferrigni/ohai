#
# Author:: Benjamin Black (<bb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

Ohai.plugin do
  provides "languages/java"

  depends "languages"

  collect_data do
    java = Mash.new

    status, stdout, stderr = nil
    if RUBY_PLATFORM.downcase.include?("darwin") 
      if system("#{ Ohai.abs_path( "/usr/libexec/java_home" )} 2>&1 >#{ Ohai.dev_null }")
        status, stdout, stderr = run_command(:no_status_check => true, :command => "java -version")
      end
    else
      status, stdout, stderr = run_command(:no_status_check => true, :command => "java -version")
    end

    if status == 0
      stderr.split("\n").each do |line|
        case line
        when /java version \"([0-9\.\_]+)\"/
          java[:version] = $1
        when /^(.+Runtime Environment.*) \((build )?(.+)\)$/
          java[:runtime] = { "name" => $1, "build" => $3 }
        when /^(.+ (Client|Server) VM) \(build (.+)\)$/
          java[:hotspot] = { "name" => $1, "build" => $3 }
        end
      end

      languages[:java] = java if java[:version]
    end
  end
end
