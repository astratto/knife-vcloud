#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2012
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

      banner "knife vc vapp show [VAPP_ID] (options)"

      def run
        $stdout.sync = true

        vapp_id = @name_args.first

        list = [
            ui.color('Name', :bold),
            ui.color('Status', :bold),
            ui.color('IPs', :bold),
            ui.color('ID', :bold)
        ]

        connection.login
        name, description, status, ip, vms_hash = connection.show_vapp vapp_id
        connection.logout

        out_msg("Name", name)
        out_msg("Description", description)
        out_msg("Status", status)
        out_msg("IP", ip)

        vms_hash.each do |k, v|
          list << (k || '')
          list << (v[:status] || '')
          list << (v[:addresses].join(', ') || '<no ip>')
          list << (v[:id] || '')
        end
        puts ui.list(list, :columns_across, 4)
      end
    end
  end
end