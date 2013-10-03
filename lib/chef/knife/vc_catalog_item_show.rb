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
    class VcCatalogItemShow < Chef::Knife
      include Knife::VcCommon

      banner "knife vc catalog item show [CATALOG_ID] (options)"

      def run
        $stdout.sync = true

        item_id = @name_args.first

        connection.login

        header = [
            ui.color('Name', :bold),
            ui.color('Template ID', :bold)
        ]

        catalog_item = connection.get_catalog_item item_id
        connection.logout

        ui.msg "#{ui.color('Description:', :cyan)} #{catalog_item[:description]}"
        list = header
        list.flatten!
        catalog_item[:items].each do |k, v|
          list << (k || '')
          list << (v || '')
        end

        ui.msg ui.list(list, :columns_across, 2)
      end
    end
  end
end
