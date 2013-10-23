#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2012-2013
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
    class VcVmConfigGuest < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon

      banner "knife vc vm config guest [VM] [COMPUTER_NAME] (options)"

      option :guest_enabled,
             :long => "--[no-]guest",
             :description => "Toggle Guest Customization (default true)",
             :boolean => true,
             :default => true

      option :admin_passwd_enabled,
             :long => "--use-[no-]admin-passwd",
             :description => "Toggle Admin Password (default true)",
             :boolean => true,
             :default => true

      option :admin_passwd,
             :long => "--admin-passwd ADMIN_PASSWD",
             :description => "Set Admin Password"

      option :customization_script,
             :long => "--script CUSTOMIZATION_SCRIPT",
             :description => "Filename of a customization script to upload"

      option :force_customization,
             :long => "--[no-]force",
             :description => "Force a Guest Customization of the parent vAPP",
             :boolean => true,
             :default => true

      def run
        $stdout.sync = true

        vm_arg = @name_args.shift
        computer_name = @name_args.shift
        script_filename = locate_config_value(:customization_script)

        if script_filename
          script = File.read(script_filename)
          raise ArgumentError,
            "A customization script cannot exceed 49000 characters" if script.size > 49_000
        end

        config = {
          :enabled => locate_config_value(:guest_enabled),
          :admin_passwd_enabled => locate_config_value(:admin_passwd_enabled),
          :admin_passwd => locate_config_value(:admin_passwd),
          :customization_script => script
        }

        connection.login

        vm = get_vm(vm_arg)

        if vm[:status] == 'running'
          if ui.confirm("Guest customizations must be applied to a stopped VM, " \
                        "but it's running. Can I #{ui.color('STOP', :red)} it")
            task_id, response = connection.poweroff_vm vm[:id]

            ui.msg "Stopping VM..."
            wait_task(connection, task_id)
          end
        end

        task_id, response = connection.set_vm_guest_customization vm[:id], computer_name, config

        ui.msg "VM guest configuration..."
        wait_task(connection, task_id)

        if locate_config_value(:force_customization)
          ui.msg "Forcing Guest Customization..."
          task_id = connection.force_customization_vm vm[:id]
          wait_task(connection, task_id)
        end

        connection.logout
      end
    end
  end
end
