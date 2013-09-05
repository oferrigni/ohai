#
# Author:: Doug MacEachern <dougm@vmware.com>
# Copyright:: Copyright (c) 2010 VMware, Inc.
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

require 'rbconfig'

Ohai.plugin do
  provides "languages/c"

  depends "languages"

  collect_data do
    c = Mash.new

    #gcc
    status, stdout, stderr = run_command(:no_status_check => true, :command => "gcc -v")
    if status == 0
      description = stderr.split($/).last
      output = description.split
      if output.length >= 3
        c[:gcc] = Mash.new
        c[:gcc][:version] = output[2]
        c[:gcc][:description] = description
      end
    end

    #glibc
    ["/lib/libc.so.6", "/lib64/libc.so.6"].each do |glibc|
      m = Mixlib::ShellOut.new(glibc).run_command
      if m.exitstatus == 0
        description = m.stdout.split($/).first
        if description =~ /(\d+\.\d+\.?\d*)/
          c[:glibc] = Mash.new
          c[:glibc][:version] = $1
          c[:glibc][:description] = description
        end
        break
      end
    end

    #ms cl
    m = Mixlib::ShellOut.new("cl /?").run_command
    if m.exit_status == 0
      description = m.stderr.split($/).first
      if description =~ /Compiler Version ([\d\.]+)/
        c[:cl] = Mash.new
        c[:cl][:version] = $1
        c[:cl][:description] = description
      end
    end

    #ms vs
    m = Mixlib::ShellOut.new("devenv.com /?").run_command
    if m.exitstatus == 0
      lines = m.stdout.split($/)
      description = lines[0].length == 0 ? lines[1] : lines[0]
      if description =~ /Visual Studio Version ([\d\.]+)/
        c[:vs] = Mash.new
        c[:vs][:version] = $1.chop
        c[:vs][:description] = description
      end
    end

    #ibm xlc
    m = Mixlib::ShellOut.new("xlc -qversion").run_command
    if m.status == 0 or (m.status >> 8) == 249
      description = m.stdout.split($/).first
      if description =~ /V(\d+\.\d+)/
        c[:xlc] = Mash.new
        c[:xlc][:version] = $1
        c[:xlc][:description] = description.strip
      end
    end

    #sun pro
    m = Mixlib::ShellOut.new("cc -V -flags").run_command
    if m.status == 0
      output = m.stderr.split
      if m.stderr =~ /^cc: Sun C/ && output.size >= 4
        c[:sunpro] = Mash.new
        c[:sunpro][:version] = output[3]
        c[:sunpro][:description] = m.stderr.chomp
      end
    end

    #hpux cc
    m = Mixlib::ShellOut.new("what /opt/ansic/bin/cc").run_command
    if m.status == 0
      description = m.stdout.split($/).select { |line| line =~ /HP C Compiler/ }.first
      if description
        output = description.split
        c[:hpcc] = Mash.new
        c[:hpcc][:version] = output[1] if output.size >= 1
        c[:hpcc][:description] = description.strip
      end
    end

    languages[:c] = c if c.keys.length > 0
  end
end
