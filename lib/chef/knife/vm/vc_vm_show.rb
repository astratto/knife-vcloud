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
    class VcVmShow < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vm show VM (options)"

      option :org_name,
             :long => "--org ORG_NAME",
             :description => "Organization to whom vApp's VDC belongs",
             :proc => Proc.new { |key| Chef::Config[:knife][:default_org_name] = key }

      option :vdc_name,
             :long => "--vdc VDC_NAME",
             :description => "VDC to whom vApp belongs",
             :proc => Proc.new { |key| Chef::Config[:knife][:default_vdc_name] = key }

      option :vapp_name,
             :long => "--vapp VAPP_NAME",
             :description => "vApp to whom VM belongs",
             :proc => Proc.new { |key| Chef::Config[:knife][:default_vapp_name] = key }

      def pretty_symbol(key)
        key.to_s.gsub('_', ' ').capitalize
      end

      def run
        $stdout.sync = true

        vm_arg = @name_args.first
        vapp_name = locate_config_value(:vapp_name)
        org_name = locate_config_value(:org_name)
        vdc_name = locate_config_value(:vdc_name)

        list = []

        connection.login

        unless org_name && vdc_name && vapp_name
          vm = connection.get_vm vm_arg
        else
          puts "#{org_name}, #{vdc_name}, #{vapp_name}, #{vm_arg}"
          org = connection.get_organization_by_name org_name
          vm = connection.get_vm_by_name org, vdc_name, vapp_name, vm_arg
        end

        vm_info = connection.get_vm_info vm[:id]
        vm_disks = connection.get_vm_disk_info vm[:id]
        connection.logout

        out_msg("VM Name", vm[:vm_name])
        out_msg("OS Name", vm[:os_desc])
        out_msg("Status", vm[:status])

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
          list << (network || '')
          values.each do |k, v|
            list << (pretty_symbol(k) || '')
            list << (v || '')
          end
        end

        list << ['', '', ui.color('Guest Customizations', :bold), '']
        list.flatten!
        vm[:guest_customizations].each do |k, v|
          list << (pretty_symbol(k) || '')
          list << (v || '')
        end
        puts ui.list(list, :columns_across, 2)
      end
    end
  end
end
