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

        header = [
            ui.color('Name', :bold),
            ui.color('ID', :bold)
        ]

        list = ["#{ui.color('CATALOGS', :cyan)}", '']
        list << header
        list.flatten!
        sort_by_name(organization.catalogs).each do |item|
          list << (item.name || '')
          list << (item.id || '')
        end

        list << ['', '', "#{ui.color('VDCs', :cyan)}", '']
        list << header
        list.flatten!
        sort_by_name(organization.vdcs).each do |item|
          list << (item.name || '')
          list << (item.id || '')
        end

        list << ['', '', "#{ui.color('NETWORKS', :cyan)}", '']
        list << header
        list.flatten!
        sort_by_name(organization.networks).each do |item|
          list << (item.name || '')
          list << (item.id || '')
        end

        list << ['', '', "#{ui.color('ACTIVE/ERRORED TASKS', :cyan)}", '']
        list << header
        list.flatten!
        sort_by_operation_name(organization.tasks.select{|t| !t.success? }).each do |item|
          list << ("#{item.operation_name} (#{item.status})" || '')
          list << (item.id || '')
        end

        ui.msg ui.list(list, :columns_across, 2)
      end
    end
  end
end