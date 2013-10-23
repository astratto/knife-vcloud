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
    class VcVappCreate < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVDCCommon

      banner "knife vc vapp create [VDC] [NAME] [DESCRIPTION] [TEMPLATE_ID] (options)"

      def run
        $stdout.sync = true

        vdc_arg = @name_args.shift
        name = @name_args.shift
        description = @name_args.shift
        templateId = @name_args.shift

        connection.login

        vdc = get_vdc(vdc_arg)

        result = connection.create_vapp_from_template vdc[:id], name, description, templateId

        ui.msg "vApp creation..."
        wait_task(connection, result[:task_id])
        ui.msg "vApp created with ID: #{ui.color(result[:vapp_id], :cyan)}"

        connection.logout
      end
    end
  end
end
