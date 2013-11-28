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
    class VcVdcShow < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVDCCommon

      banner "knife vc vdc show VDC (options)"

      def run
        $stdout.sync = true

        vdc_arg = @name_args.shift

        connection.login

        vdc = get_vdc(vdc_arg)

        header = [
            ui.color('Name', :bold),
            ui.color('ID', :bold),
            ui.color('Status', :bold),
            ui.color('IP', :bold),
        ]

        ui.msg "#{ui.color('Description:', :cyan)} #{vdc[:description]}"
        list = ["#{ui.color('vAPPS', :cyan)}", '', '', '']
        list << header
        list.flatten!
        sort_by_key(vdc[:vapps]).each do |k, v|
          vapp = connection.get_vapp v
          list << ("#{k} (#{vapp[:vms_hash].count} VMs)" || '')
          list << (v || '')
          list << (vapp[:status] || '')
          list << (vapp[:ip] || '')
        end

        ui.msg ui.list(list, :columns_across, 4)
        connection.logout
      end
    end
  end
end
