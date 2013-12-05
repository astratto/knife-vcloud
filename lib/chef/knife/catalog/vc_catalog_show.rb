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
    class VcCatalogShow < Chef::Knife
      include Knife::VcCommon
      include Knife::VcCatalogCommon

      banner "knife vc catalog show [CATALOG] (options)"

      def run
        $stdout.sync = true

        catalog_arg = @name_args.shift

        catalog = organization.catalogs.get_by_name(catalog_arg)

        ui.msg "#{ui.color('Description:', :cyan)} #{catalog.description}"

        list = [
            ui.color('Name', :bold),
            ui.color('Description', :bold),
            ui.color('vApp Template', :bold)
        ]

        sort_by_name(catalog.catalog_items).each do |item|
          list << (item.name || '')
          list << short_description(item.description || '', 25)
          list << (item.vapp_template_id || '')
        end

        ui.msg ui.list(list, :uneven_columns_across, 3)
      end
    end
  end
end
