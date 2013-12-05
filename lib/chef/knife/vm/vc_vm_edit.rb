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
    class VcVmEdit < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon

      banner "knife vc vm edit [VM] (options)"

      option :vm_cpus_number,
             :long => "--cpus CPUs_NUMBER",
             :description => "Number of virtual CPUs to be allocated"

      option :vm_ram,
             :long => "--ram MEMORY_SIZE (in MB)",
             :description => "Memory to be allocated"

      option :vm_name,
             :long => "--name VM_NAME",
             :description => "Rename the VM"

      option :override_guest_name,
             :long => "--[no-]override-guest",
             :description => "Override also Guest Name (used with --name)",
             :boolean => true,
             :default => false

      option :guest_enabled,
             :long => "--[no-]guest",
             :description => "Toggle Guest Customization (default true)",
             :boolean => true,
             :default => true

      option :admin_password_enabled,
             :long => "--use-[no-]admin-password",
             :description => "Toggle Admin Password (default true)",
             :boolean => true,
             :default => true

      option :admin_password,
             :long => "--admin-password ADMIN_PASSWD",
             :description => "Set Admin Password"

      option :customization_script,
             :long => "--script CUSTOMIZATION_SCRIPT",
             :description => "Filename of a customization script to upload"

      option :force_customization,
             :long => "--[no-]force",
             :description => "Force a Guest Customization of the parent vAPP",
             :boolean => true,
             :default => true

      option :guest_computer_name,
             :long => "--computer-name COMPUTER_NAME",
             :description => "Set Guest Computer Name"

      def run
        $stdout.sync = true

        vm_arg = @name_args.first
        cpus = locate_config_value(:vm_cpus_number)
        ram = locate_config_value(:vm_ram)
        vm_name = locate_config_value(:vm_name)
        script_filename = locate_config_value(:customization_script)

        if script_filename
          script = File.read(script_filename)
          raise ArgumentError,
            "A customization script cannot exceed 49000 characters" if script.size > 49_000
        end

        config = {
          :enabled => locate_config_value(:guest_enabled),
          :admin_password_enabled => locate_config_value(:admin_password_enabled),
          :admin_password => locate_config_value(:admin_password),
          :script => script,
          :computer_name => locate_config_value(:guest_computer_name)
        }
        config.reject!{|k, v| v.nil?}

        vm = get_vm(vm_arg)

        if cpus
          ui.msg "VM setting CPUs info..."
          vm.cpu = cpus
          vm.save
        end

        if ram
          ui.msg "VM setting RAM info..."
          vm.memory = ram
          vm.save
        end

        if vm_name
          # TODO: IMPLEMENT RENAME!
          raise NotImplementedError
          rename_vm(connection, vm, vm_name)
        end

        customization = vm.customization

        config.each do |key, value|
          ui.msg "Setting #{pretty_symbol(key)}..."
          customization.send("#{key}=".to_sym, value)
        end
        customization.save
      end

      def rename_vm(connection, vm, vm_name)
        ui.msg "Renaming VM from #{vm[:vm_name]} to #{vm_name}"
        task_id = connection.rename_vm vm[:id], vm_name
        result = wait_task(connection, task_id)

        return unless result && locate_config_value(:override_guest_name)

        # Change also its guest computer name
        guest_config = {:enabled => true}

        # Inheriting admin_password if enabled
        if vm[:guest_customizations][:admin_password_enabled]
          guest_config[:admin_password] = vm[:guest_customizations][:admin_password]
        end

        stop_if_running(connection, vm)

        guest_name = sanitize_guest_name(vm_name)

        ui.msg "Renaming guest name to #{guest_name}..."
        task_id, response = connection.set_vm_guest_customization vm[:id], guest_name, guest_config

        wait_task(connection, task_id)

        ui.msg "Forcing Guest Customization..."
        task_id = connection.force_customization_vm vm[:id]
        wait_task(connection, task_id)
      end
    end
  end
end