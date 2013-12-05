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

        vm = get_vm(vm_arg)

        out_msg("VM Name", vm.name)
        out_msg("OS Name", vm.operating_system)
        out_msg("Status", vm.status)
        out_msg("vApp", vm.vapp_name)

        list = []
        list << ['', '']

        list << ui.color("Number of Virtual CPUs", :bold)
        list << vm.cpu.to_s

        list << ui.color("Memory size (MB)", :bold)
        list << vm.memory.to_s

        list << [ui.color("Disks", :bold), '']

        vm.hard_disks.each do |disk|
          disk.each do |key, value|
            list << key
            list << value.to_s
          end
        end

        list << ['', '', ui.color('Networks', :bold), '']


        network = vm.network
        list << ["Primary connection", network.primary_network_connection_index.to_s]

        # connections = network.connections.collect do |network|
        #   show_vm_connection(network)
        # end

        # list << connections

        list << ['', '', ui.color('Guest Customizations', :bold), '']
        customization = vm.customization

        list << ['Enabled', ''] if customization.enabled
        list << ['Computer Name', customization.computer_name]
        list << ['Admin Password', customization.admin_password]
        list << ['Admin Password Enabled', ''] if customization.admin_password_enabled
        list << ['Reset Password Required', ''] if customization.reset_password_required

        # FIXME: Unable to retrieve customization script if not existing
        #        Fog bug?
        #
        # (byebug) vm.customization
        # <Fog::Compute::VcloudDirector::VmCustomization
        #   id="vm-846d5d87-d3d8-4078-92dc-a36d35c56bc9",
        #   type="application/vnd.vmware.vcloud.guestCustomizationSection+xml",
        #   href="https://csicloud.csi.it/api/vApp/vm-846d5d87-d3d8-4078-92dc-a36d35c56bc9/guestCustomizationSection/",
        #   enabled=true,
        #   change_sid=false,
        #   join_domain_enabled=false,
        #   use_org_settings=false,
        #   admin_password_enabled=false,
        #   reset_password_required=false,
        #   virtual_machine_id="846d5d87-d3d8-4078-92dc-a36d35c56bc9",
        #   computer_name="SMALL-CentOS64",
        #   has_customization_script=NonLoaded
        # >
        # (byebug) vm.customization.reload
        # NoMethodError Exception: undefined method `get_by_id' for #<Fog::Compute::VcloudDirector::VmCustomizations:0x007fd8d6bb31e8>
        # nil

        #list << ['Customization script?', customization.has_customization_script]

        list.flatten!
        ui.msg ui.list(list, :columns_across, 2)
      end

      def show_vm_connection(network)
        list = []
        name = network[:network]
        name << " (connected)" if network[:is_connected]

        list << ["Network", name]
        list << ["  Index", network[:network_connection_index].to_s]
        list << ["  Mac address", network[:mac_address]]
        list << ["  Ip allocation mode", network[:ip_address_allocation_mode]]
        list << ["  Ip", network[:ip_address]]
        list << ["  Needs customization", ''] if network[:needsCustomization]
        list
      end
    end
  end
end
