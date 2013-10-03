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
    class VcVappCreate < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vapp create [VDC] [NAME] [DESCRIPTION] [TEMPLATE_ID] (options)"

      option :org_name,
             :long => "--org ORG_NAME",
             :description => "Organization to whom vApp's VDC belongs",
             :proc => Proc.new { |key| Chef::Config[:knife][:default_org_name] = key }

      def run
        $stdout.sync = true

        vdc_arg = @name_args.shift
        name = @name_args.shift
        description = @name_args.shift
        templateId = @name_args.shift
        org_name = locate_config_value(:org_name)

        connection.login

        unless org_name
          notice_msg("--org not specified, assuming VDC is an ID")
          vdc_id = vdc_arg
        else
          org = connection.get_organization_by_name org_name
          vdc = connection.get_vdc_by_name org, vdc_arg
          vdc_id = vdc[:id]
        end

        result = connection.create_vapp_from_template vdc_id, name, description, templateId

        ui.msg "vApp creation..."
        wait_task(connection, result[:task_id])
        ui.msg "vApp created with ID: #{ui.color(result[:vapp_id], :cyan)}"

        connection.logout
      end
    end
  end
end
