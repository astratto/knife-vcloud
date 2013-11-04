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

        connection.login
        vapp = get_vapp(vapp_arg)
        connection.logout

        out_msg("Name", vapp[:name])
        out_msg("Description", vapp[:description])
        out_msg("Status", vapp[:status])
        out_msg("IP", vapp[:ip])

        ui.msg("#{ui.color('Networks', :cyan)}")

        vapp[:networks].each do |network|
          ui.msg ui.color(network[:name], :bold)

          list = [
              ui.color(' ', :bold),
              ui.color('Gateway', :bold),
              ui.color('Netmask', :bold),
              ui.color('Fence Mode', :bold),
              ui.color('Parent Network', :bold),
              ui.color('Retain Network', :bold)
          ]

          list << " "
          list << (network[:scope][:gateway] || '')
          list << (network[:scope][:netmask] || '')
          list << (network[:scope][:fence_mode] || '')
          list << (network[:scope][:parent_network] || '')
          list << (network[:scope][:retain_network] || '')

          ui.msg ui.list(list, :uneven_columns_across, 6)
        end

        if vapp[:vapp_snapshot]
          out_msg("Snapshot", vapp[:vapp_snapshot][:creation_date])
        end

        ui.msg("#{ui.color('VMs', :cyan)}")

        list = [
            ui.color('Name', :bold),
            ui.color('Status', :bold),
            ui.color('IPs', :bold),
            ui.color('ID', :bold),
            ui.color('Scoped ID', :bold)
        ]

        vapp[:vms_hash].each do |k, v|
          list << (k || '')
          list << (v[:status] || '')
          list << (v[:addresses].join(', ') || '<no ip>')
          list << (v[:id] || '')
          list << (v[:vapp_scoped_local_id] || '')
        end
        ui.msg ui.list(list, :uneven_columns_across, 5)
      end
    end
  end
end
