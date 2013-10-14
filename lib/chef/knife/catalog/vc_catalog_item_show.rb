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
    class VcCatalogItemShow < Chef::Knife
      include Knife::VcCommon
      include Knife::VcCatalogCommon

      banner "knife vc catalog item show [CATALOG_ITEM] (options)"

      def run
        $stdout.sync = true

        item_arg = @name_args.first

        connection.login
        catalog_item = get_catalog_item(item_arg)
        connection.logout

        header = [
            ui.color('Name', :bold),
            ui.color('Template ID', :bold)
        ]

        ui.msg "#{ui.color('Description:', :cyan)} #{catalog_item[:description]}"
        list = header
        list.flatten!

        catalog_item[:items].each do |item|
          list << (item[:name] || '')
          list << (item[:id] || '')
          # TODO: show VMs using this item? item[:vms_hash]
        end

        ui.msg ui.list(list, :columns_across, 2)
      end
    end
  end
end
