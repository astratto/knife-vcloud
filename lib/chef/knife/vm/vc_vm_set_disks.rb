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
    class VcVmSetDisks < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon

      banner "knife vc vm set disks [VM] (options)"

      option :vm_disk_name,
             :long => "--disk-name DISK_NAME",
             :description => "Name of the disk to be modified (required unless using --add)"

      option :vm_disk_size,
             :long => "--disk-size DISK_SIZE",
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

        vm_arg = @name_args.shift

        new_disk = locate_config_value(:vm_add_disk)
        delete_disk = locate_config_value(:vm_delete_disk)
        disk_name = locate_config_value(:vm_disk_name)
        disk_size = locate_config_value(:vm_disk_size)

        raise ArgumentError, "Disk name is mandatory if using --no-add" if !new_disk && disk_name.nil?
        raise ArgumentError, "Disk size is mandatory if using --add" if new_disk && disk_size.nil?
        raise ArgumentError, "Disk name is mandatory if using --delete" if delete_disk && disk_name.nil?

        connection.login
        vm = get_vm(vm_arg)

        if !delete_disk || ui.confirm("Do you really want to #{ui.color('DELETE', :red)} disk #{disk_name}")
          task_id = connection.set_vm_disk_info vm[:id], {
                                                        :add => new_disk,
                                                        :delete => delete_disk,
                                                        :disk_size => disk_size,
                                                        :disk_name => disk_name
                                                      }
          ui.msg "VM setting Disks info..."
          wait_task(connection, task_id)
        end
        connection.logout
      end
    end
  end
end