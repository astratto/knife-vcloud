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
    class VcVappShow < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVappCommon

      banner "knife vc vapp show VAPP (options)"

      def run
        $stdout.sync = true

        vapp_arg = @name_args.shift

        vapp = get_vapp(vapp_arg)

        out_msg("Name", vapp.name)
        out_msg("Description", vapp.description)
        out_msg("Status", convert_vapp_status(vapp.status))

        networks = vapp.network_config
        # TODO: Better handling for placeholder networks
        unless networks.is_a?(Hash) && networks[:networkName] == 'none'
          ui.msg("#{ui.color('Networks', :cyan)}")
          if networks.is_a?(Array)
            networks.each do |network|
              show_vapp_network(network)
            end
          else
            show_vapp_network(networks)
          end
        end

        # TODO: Retrieve from fog
        # if vapp[:vapp_snapshot]
        #   out_msg("Snapshot", vapp[:vapp_snapshot][:creation_date])
        # end

        ui.msg("#{ui.color('VMs', :cyan)}")

        list = [
            ui.color('Name', :bold),
            ui.color('Status', :bold),
            ui.color('IPs', :bold),
            ui.color('ID', :bold)
        ]

        sort_by_name(vapp.vms).each do |item|
          list << (item.name || '')
          list << (item.status || '')
          list << (item.ip_address || '<no ip>')
          list << (item.id || '')
        end
        ui.msg ui.list(list, :uneven_columns_across, 4)
      end

      def show_vapp_network(network)
        configuration = network[:Configuration]

        out_msg("Network", network[:networkName])
        out_msg("  Parent Network", configuration[:ParentNetwork][:name])
        out_msg("  Retain Network", configuration[:RetainNetInfoAcrossDeployments])
        out_msg("  Fence Mode", configuration[:FenceMode])

        list = [
            ui.color(' ', :bold),
            ui.color('Gateway', :bold),
            ui.color('Netmask', :bold),
            ui.color('DNS1', :bold),
            ui.color('DNS2', :bold),
            ui.color('Inherited', :bold)
        ]

        configuration[:IpScopes].each do |scope, values|
          list << " "
          list << (values[:Gateway] || '')
          list << (values[:Netmask] || '')
          list << (values[:Dns1] || '')
          list << (values[:Dns2] || '')
          list << (values[:IsInherited] || '')
        end

        ui.msg ui.list(list, :uneven_columns_across, 6)
      end
    end
  end
end
