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
    class VcVmDisks < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon

      banner "knife vc vm disks [add|delete|edit] [VM] (options)"

      option :vm_disk_name,
             :long => "--name DISK_NAME",
             :description => "Name of the disk to be modified (required unless using --add)"

      option :vm_disk_size,
             :long => "--size DISK_SIZE",
             :description => "Size of the disk (in MB)"

      option :vm_add_disk,
             :long => "--[no-]add",
             :description => "Whether or not allocate a new disk (default false)",
             :boolean => true,
             :default => false

      option :vm_delete_disk,
             :long => "--[no-]delete",
             :description => "Whether or not delete a given disk (default false)",
             :boolean => true,
             :default => false

      def run
        $stdout.sync = true

        command_arg = @name_args.shift
        vm_arg = @name_args.shift

        disk_name = locate_config_value(:vm_disk_name)
        disk_size = locate_config_value(:vm_disk_size)

        unless command_arg =~ /add|delete|edit/
          raise ArgumentError, "Invalid command #{command_arg} supplied. Only add, delete and edit are allowed."
        end

        add_disk = command_arg == 'add'
        delete_disk = command_arg == 'delete'

        raise ArgumentError, "Disk name is mandatory unless using add" if !add_disk && disk_name.nil?
        raise ArgumentError, "Disk size is mandatory if using --add" if add_disk && disk_size.nil?
        raise ArgumentError, "Disk name is mandatory if using --delete" if delete_disk && disk_name.nil?

        vm = get_vm(vm_arg)

        if delete_disk
          if ui.confirm("Do you really want to #{ui.color('DELETE', :red)} disk #{disk_name}")
            ui.msg "Removing disk..."
            disk = vm.disks.get_by_name(disk_name)
            disk.destroy
          end
        elsif add_disk
          ui.msg "Adding disk..."
          vm.disks.create(disk_size)
        else
          ui.msg "Resizing disk..."
          disk = vm.disks.get_by_name(disk_name)
          disk.capacity = disk_size
        end
      end
    end
  end
end