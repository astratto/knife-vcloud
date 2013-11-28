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
    class VcOrgShow < Chef::Knife
      include Knife::VcCommon

      banner "knife vc org show (options)"

      def run
        $stdout.sync = true

        org = locate_org_option

        connection.login

        header = [
            ui.color('Name', :bold),
            ui.color('ID', :bold)
        ]

        organization = connection.get_organization_by_name org

        connection.logout

        list = ["#{ui.color('CATALOGS', :cyan)}", '']
        list << header
        list.flatten!
        sort_by_key(organization[:catalogs]).each do |k, v|
          list << (k || '')
          list << (v || '')
        end

        list << ['', '', "#{ui.color('VDCs', :cyan)}", '']
        list << header
        list.flatten!
        sort_by_key(organization[:vdcs]).each do |k, v|
          list << (k || '')
          list << (v || '')
        end

        list << ['', '', "#{ui.color('NETWORKS', :cyan)}", '']
        list << header
        list.flatten!
        sort_by_key(organization[:networks]).each do |k, v|
          list << (k || '')
          list << (v || '')
        end

        list << ['', '', "#{ui.color('TASKLISTS', :cyan)}", '']
        list << header
        list.flatten!
        sort_by_key(organization[:tasklists]).each do |k, v|
          list << (k || '<unnamed list>')
          list << (v || '')
        end

        ui.msg ui.list(list, :columns_across, 2)
      end
    end
  end
end