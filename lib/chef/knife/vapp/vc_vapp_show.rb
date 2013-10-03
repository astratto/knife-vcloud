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
    class VcVappShow < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vapp show VAPP (options)"

      option :org_name,
             :long => "--org ORG_NAME",
             :description => "Organization to whom vApp's VDC belongs",
             :proc => Proc.new { |key| Chef::Config[:knife][:default_org_name] = key }

      option :vdc_name,
             :long => "--vdc VDC_NAME",
             :description => "VDC to whom vApp belongs",
             :proc => Proc.new { |key| Chef::Config[:knife][:default_vdc_name] = key }

      def run
        $stdout.sync = true

        vapp_arg = @name_args.shift
        org_name = locate_config_value(:org_name)
        vdc_name = locate_config_value(:vdc_name)

        connection.login
        unless org_name && vdc_name
          notice_msg("--org and --vdc not specified, assuming VAPP is an ID")
          vapp = connection.get_vapp vapp_arg
        else
          org = connection.get_organization_by_name org_name
          vapp = connection.get_vapp_by_name org, vdc_name, vapp_arg
        end

        connection.logout

        out_msg("Name", vapp[:name])
        out_msg("Description", vapp[:description])
        out_msg("Status", vapp[:status])
        out_msg("IP", vapp[:ip])

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
        ui.msg ui.list(list, :columns_across, 5)
      end
    end
  end
end
