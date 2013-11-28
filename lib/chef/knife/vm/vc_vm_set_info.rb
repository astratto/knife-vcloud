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

class Chef
  class Knife
    class VcVmSetInfo < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon

      banner "knife vc vm set info [VM] (options)"

      option :vm_cpus_number,
             :long => "--cpus CPUs_NUMBER",
             :description => "Number of virtual CPUs to be allocated"

      option :vm_ram,
             :long => "--ram MEMORY_SIZE (in MB)",
             :description => "Memory to be allocated"

      option :vm_name,
             :long => "--name VM_NAME",
             :description => "Rename the VM"

      def run
        $stdout.sync = true

        vm_arg = @name_args.first
        cpus = locate_config_value(:vm_cpus_number)
        ram = locate_config_value(:vm_ram)
        vm_name = locate_config_value(:vm_name)

        connection.login

        vm = get_vm(vm_arg)

        if cpus
          task_id = connection.set_vm_cpus vm[:id], cpus
          ui.msg "VM setting CPUs info..."
          wait_task(connection, task_id)
        end

        if ram
          task_id = connection.set_vm_ram vm[:id], ram
          ui.msg "VM setting RAM info..."
          wait_task(connection, task_id)
        end

        if vm_name
          # Changing VM name requires to change also its guest computer name
          guest_config = {}

          if vm[:guest_customizations][:admin_passwd_enabled]
            ui.msg('Inheriting admin password')
            guest_config[:admin_passwd] = vm[:guest_customizations][:admin_passwd]
          end

          if vm[:status] == 'running'
            if ui.confirm("Guest customizations must be applied to a stopped VM, " \
                          "but it's running. Can I #{ui.color('STOP', :red)} it")
              task_id, response = connection.poweroff_vm vm[:id]

              ui.msg "Stopping VM..."
              wait_task(connection, task_id)
            end
          end

          ui.msg "Renaming VM from #{vm[:vm_name]} to #{vm_name}"
          task_id = connection.rename_vm vm[:id], vm_name

          if wait_task(connection, task_id)
            computer_name = vm[:guest_customizations][:computer_name]
            task_id, response = connection.set_vm_guest_customization vm[:id], computer_name, guest_config

            if wait_task(connection, task_id)
              ui.msg "Forcing Guest Customization..."
              task_id = connection.force_customization_vm vm[:id]
              wait_task(connection, task_id)
            end
          end
        end

        connection.logout
      end
    end
  end
end