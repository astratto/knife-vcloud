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
    class VcVmNetwork < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon
      include Knife::VcNetworkCommon

      banner "knife vc vm network [add|delete|edit| [VM] [NETWORK] (options)"

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

        command_arg = @name_args.shift
        vm_arg = @name_args.shift
        network_arg = @name_args.shift

        unless command_arg =~ /add|delete|edit/
          raise ArgumentError, "Invalid command #{command_arg} supplied. Only add, delete and edit are allowed."
        end

        command = command_arg.to_sym

        config = {
          :network_index => locate_config_value(:vm_net_index),
          :ip => locate_config_value(:vm_net_ip),
          :is_connected => locate_config_value(:vm_net_is_connected),
          :ip_address_allocation_mode => locate_config_value(:vm_ip_allocation_mode)
        }
        config.delete_if{|k, v| v.nil?}

        vm = get_vm(vm_arg)

        ui.msg "VM network configuration..."
        stop_if_running(vm)

        case command
          when :add
            ui.msg "Adding #{network_arg} to VM..."
            net = organization.networks.get_by_name(network_arg)
            vm.network << net
          when :delete
            ui.msg "Removing #{network_arg} from VM..."
            vm.network.remove(network_arg)
          when :edit
            ui.msg "Editing VM network configuration for #{network_arg}..."
            network = vm.network[network_arg]
            network.merge!(config)
            vm.network[network_arg] = network
        end
      end
    end
  end
end
