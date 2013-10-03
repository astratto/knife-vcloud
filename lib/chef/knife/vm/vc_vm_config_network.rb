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

require 'chef/knife/vc_common'

class Chef
  class Knife
    class VcVmConfigNetwork < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon

      banner "knife vc vm config network [VM] [NETWORK_NAME] (options)"

      option :vm_net_primary_index,
             :long => "--net-primary NETWORK_PRIMARY_IDX",
             :description => "Index of the primary network interface"

      option :vm_net_index,
             :long => "--net-index NETWORK_IDX",
             :description => "Index of the current network interface"

      option :vm_net_ip,
             :long => "--net-ip NETWORK_IP",
             :description => "IP of the current network interface"

      option :vm_net_is_connected,
             :long => "--net-[no-]connected",
             :description => "Toggle IsConnected flag of the current network interface (default true)",
             :boolean => true,
             :default => true

      option :vm_ip_allocation_mode,
             :long => "--ip-allocation-mode ALLOCATION_MODE",
             :description => "Set IP allocation mode of the current network interface (default POOL)",
             :default => 'POOL'

      def run
        $stdout.sync = true

        vm_arg = @name_args.shift
        network_name = @name_args.shift
        config = {
          :primary_index => locate_config_value(:vm_net_primary_index),
          :network_index => locate_config_value(:vm_net_index),
          :ip => locate_config_value(:vm_net_ip),
          :is_connected => locate_config_value(:vm_net_is_connected),
          :ip_allocation_mode => locate_config_value(:vm_ip_allocation_mode),
        }

        connection.login

        vm = get_vm(vm_arg)

        task_id = connection.set_vm_network_config vm[:id], network_name, config

        ui.msg "VM network configuration..."
        wait_task(connection, task_id)

        connection.logout
      end
    end
  end
end