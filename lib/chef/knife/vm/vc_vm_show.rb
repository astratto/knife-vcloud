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
    class VcVmShow < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon

      banner "knife vc vm show VM (options)"

      def run
        $stdout.sync = true

        vm_arg = @name_args.first

        connection.login

        vm = get_vm(vm_arg)

        vm_info = connection.get_vm_info vm[:id]
        vm_disks = connection.get_vm_disk_info vm[:id]
        connection.logout

        out_msg("VM Name", vm[:vm_name])
        out_msg("OS Name", vm[:os_desc])
        out_msg("Status", vm[:status])

        list = []
        list << ['', '']
        vm_info.each do |section, values|
          list << ui.color(section.capitalize, :bold)
          list << ''

          list << (values[:description] || '')
          list << (values[:name] || '')

          list << ['', '']
        end

        list << [ui.color('Disks', :bold), '']
        vm_disks.each do |values|
          list << (values[:name] || '')
          list << (values[:capacity] || '')
        end

        list << ['', '', ui.color('Networks', :bold), '']
        vm[:networks].each do |network, values|
          list << [(network || ''), '']
          values.each do |k, v|
            list << "  #{(pretty_symbol(k) || '')}"
            list << (v || '')
          end
        end

        list << ['', '', ui.color('Guest Customizations', :bold), '']
        list.flatten!
        vm[:guest_customizations].each do |k, v|
          list << (pretty_symbol(k) || '')
          list << (v || '')
        end
        ui.msg ui.list(list, :columns_across, 2)
      end
    end
  end
end
