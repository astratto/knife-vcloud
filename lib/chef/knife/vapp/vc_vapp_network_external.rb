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
    class VcVappNetworkExternal < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVappCommon
      include Knife::VcNetworkCommon

      banner "knife vc vapp network external [add|delete|edit| [VAPP] [NETWORK] (options)"

      option :retain_network,
             :long => "--[no-]retain-network",
             :description => "Toggle Retain Network across deployments (default true)",
             :proc => Proc.new { |key| Chef::Config[:knife][:retain_network] = key },
             :boolean => true,
             :default => true

      option :parent_network,
             :short => "-p PARENT_NETWORK",
             :long => "--parent-network PARENT_NETWORK",
             :description => "Set a parent network. Defaults to the current network.",
             :proc => Proc.new { |key| Chef::Config[:knife][:parent_network] = key }

      def run
        $stdout.sync = true

        command_arg = @name_args.shift
        vapp_arg = @name_args.shift
        network_arg = @name_args.shift

        unless command_arg =~ /add|delete|edit/
          raise ArgumentError, "Invalid command #{command_arg} supplied. Only add, delete and edit are allowed."
        end

        command = command_arg.to_sym

        config = {
          :fence_mode => 'bridged',
          :retain_network => locate_config_value(:retain_network)
        }

        connection.login

        vapp = get_vapp(vapp_arg)
        network = get_network network_arg

        unless network
          raise new ArgumentError, "Network #{network_arg} not found in vDC"
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

        case command
          when :add
            ui.msg "Adding #{network[:name]} to vApp..."
            task_id, response = connection.add_org_network_to_vapp vapp[:id], network, config
            wait_task(connection, task_id)
          when :delete
            ui.msg "Removing #{network[:name]} from vApp..."
            task_id, response = connection.delete_vapp_network vapp[:id], network
            wait_task(connection, task_id)
          when :edit
            ui.msg "vApp network configuration for #{network[:name]}..."
            task_id, response = connection.set_vapp_network_config vapp[:id], network, config
            wait_task(connection, task_id)
        end

        connection.logout
      end
    end
  end
end
