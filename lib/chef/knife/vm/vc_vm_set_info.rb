#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2013
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

require 'chef/knife/vc_common'

class Chef
  class Knife
    class VcVmSetInfo < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vm set info [VM_ID] (options)"

      option :vm_cpus_number,
             :long => "--cpus CPUs_NUMBER",
             :description => "Number of virtual CPUs to be allocated"

      option :vm_ram,
             :long => "--ram MEMORY_SIZE (in MB)",
             :description => "Memory to be allocated"

      def run
        $stdout.sync = true

        vm_id = @name_args.shift

        connection.login

        cpus = locate_config_value(:vm_cpus_number)
        ram = locate_config_value(:vm_ram)

        if cpus
          task_id = connection.set_vm_cpus vm_id, cpus
          print "VM setting CPUs info..."
          wait_task(connection, task_id)
        end

        if ram
          task_id = connection.set_vm_ram vm_id, ram
          print "VM setting RAM info..."
          wait_task(connection, task_id)
        end

        connection.logout
      end
    end
  end
end