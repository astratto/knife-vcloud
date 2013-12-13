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
          :ip_allocation_mode => locate_config_value(:vm_ip_allocation_mode),
          :retain_network => locate_config_value(:retain_network)
        }

        connection.login

        vm = get_vm(vm_arg)
        network = get_network network_arg

        unless network
          raise new ArgumentError, "Network #{network_arg} not found in vDC."
        end

        unless command == :delete
          parent_network_arg = locate_config_value(:parent_network)
          if parent_network_arg
            ui.msg "Retrieving parent network details"
            parent_network = get_network parent_network_arg
            config[:parent_network] =  { :id => parent_network[:id],
                                         :name => parent_network[:name] }
          else
            ui.msg "Forcing parent network to itself"
            config[:parent_network] = { :id => network[:id],
                                        :name => network[:name] }
          end
        end

        ui.msg "VM network configuration..."
        stop_if_running(connection, vm)

        case command
          when :add
            ui.msg "Adding #{network[:name]} to VM..."
            task_id, response = connection.add_vm_network vm[:id], network, config
            result = wait_task(connection, task_id)
          when :delete
            ui.msg "Removing #{network[:name]} from VM..."
            task_id, response = connection.delete_vm_network vm[:id], network
            result = wait_task(connection, task_id)
          when :edit
            ui.msg "VM network configuration for #{network[:name]}..."
            task_id, response = connection.edit_vm_network vm[:id], network, config
            result = wait_task(connection, task_id)
        end

        if result
          unless vm[:guest_customizations][:enabled]
            config = {
              :enabled => true,
              :admin_passwd_enabled => vm[:guest_customizations][:admin_passwd_enabled],
              :admin_passwd => vm[:guest_customizations][:admin_passwd],
              :customization_script => script
            }

            ui.msg "Enabling Guest Customization to apply changes..."
            task_id, response = connection.set_vm_guest_customization vm[:id], guest_name, config
            wait_task(connection, task_id)
          end

          ui.msg "Forcing Guest Customization to apply changes..."
          task_id = connection.force_customization_vm vm[:id]
          wait_task(connection, task_id)
        end

        connection.logout
      end
    end
  end
end
