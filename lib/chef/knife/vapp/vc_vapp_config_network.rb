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
    class VcVappConfigNetwork < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vapp config network [VAPP_ID] [NETWORK_NAME] (options)"

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

      def run
        $stdout.sync = true

        vapp_id = @name_args.shift
        network_name = @name_args.shift

        connection.login

        config = {
          :fence_mode => locate_config_value(:fence_mode),
          :retain_net => locate_config_value(:retain_net)
        }

        task_id, response = connection.set_vapp_network_config vapp_id, network_name, config

        print "vApp network configuration..."
        wait_task(connection, task_id)

        connection.logout
      end
    end
  end
end
