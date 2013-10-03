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
    class VcOrgShow < Chef::Knife
      include Knife::VcCommon

      banner "knife vc org show [ORG] (options)"

      option :org_use_ids,
             :long => "--[no-]use-ids",
             :description => "Specify whether [ORG] is an ID or a name (default)",
             :boolean => true,
             :default => false

      def run
        $stdout.sync = true

        org = @name_args.first
        use_ids = locate_config_value(:org_use_ids)

        connection.login

        header = [
            ui.color('Name', :bold),
            ui.color('ID', :bold)
        ]

        if use_ids
          organizations = connection.get_organization org
        else
          organizations = connection.get_organization_by_name org
        end

        connection.logout

        list = ["#{ui.color('CATALOGS', :cyan)}", '']
        list << header
        list.flatten!
        organizations[:catalogs].each do |k, v|
          list << (k || '')
          list << (v || '')
        end

        list << ['', '', "#{ui.color('VDCs', :cyan)}", '']
        list << header
        list.flatten!
        organizations[:vdcs].each do |k, v|
          list << (k || '')
          list << (v || '')
        end

        list << ['', '', "#{ui.color('NETWORKS', :cyan)}", '']
        list << header
        list.flatten!
        organizations[:networks].each do |k, v|
          list << (k || '')
          list << (v || '')
        end

        list << ['', '', "#{ui.color('TASKLISTS', :cyan)}", '']
        list << header
        list.flatten!
        organizations[:tasklists].each do |k, v|
          list << (k || '<unnamed list>')
          list << (v || '')
        end

        ui.msg ui.list(list, :columns_across, 2)
      end
    end
  end
end