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
    class VcVappConfigNetwork < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVappCommon
      include Knife::VcNetworkCommon

      banner "knife vc vapp config network [VAPP] [NETWORK] (options)"

      option :add_network,
             :long => "--[no-]add",
             :description => "Add a new network",
             :boolean => true,
             :default => false

      option :fence_mode,
             :short => "-F FENCE_MODE",
             :long => "--fence-mode FENCE_MODE",
             :description => "Set Fence Mode (e.g., Isolated, Bridged)",
             :proc => Proc.new { |key| Chef::Config[:knife][:fence_mode] = key }

      option :retain_network,
             :long => "--[no-]retain-network",
             :description => "Toggle Retain Network across deployments (default true)",
             :proc => Proc.new { |key| Chef::Config[:knife][:retain_network] = key },
             :boolean => true,
             :default => true

      option :parent_network,
             :short => "-p PARENT_NETWORK",
             :long => "--parent_network PARENT_NETWORK",
             :description => "Set Fence Mode (e.g., Isolated, Bridged)",
             :proc => Proc.new { |key| Chef::Config[:knife][:parent_network] = key }

      def run
        $stdout.sync = true

        vapp_arg = @name_args.shift
        network_arg = @name_args.shift

        add_network = locate_config_value(:add_network)
        config = {
          :fence_mode => locate_config_value(:fence_mode),
          :retain_net => locate_config_value(:retain_net)
        }

        connection.login

        vapp = get_vapp(vapp_arg)
        network = get_network network_arg

        parent_network_arg = locate_config_value(:parent_network)
        if parent_network_arg
          ui.msg "Retrieving parent network details"
          parent_network = get_network parent_network_arg
          config[:parent_network] =  { :id => parent_network[:id],
                                      :name => parent_network[:name] }
        end

        if add_network
          task_id, response = connection.add_network_to_vapp vapp[:id], network[:id]
          ui.msg "Adding #{network[:name]} to vApp..."

          if wait_task(connection, task_id)
            if config[:fence_mode] == 'bridged' && config[:parent_network].nil?
              ui.msg "Forcing parent network to itself"
              config[:parent_network] = { :id => network[:id],
                                          :name => network[:name] }
            end

            task_id, response = connection.set_vapp_network_config vapp[:id], network, config

            if wait_task(connection, task_id)
              ui.msg "Forcing Guest Customization..."
              task_id = connection.force_customization_vapp vapp[:id]
              wait_task(connection, task_id)
            end
          end
        else
          task_id, response = connection.set_vapp_network_config vapp[:id], network, config
          ui.msg "vApp network configuration for #{network[:name]}..."
          wait_task(connection, task_id)
        end

        connection.logout
      end
    end
  end
end
