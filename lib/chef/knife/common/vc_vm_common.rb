#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2013
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
    module VcVmCommon

      def self.included(includer)
        includer.class_eval do
          option :vcloud_vdc,
                 :long => "--vdc VDC_NAME",
                 :description => "VDC to whom VM's vApp belongs",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_vdc] = key }

          option :vcloud_vapp,
                 :long => "--vapp VAPP_NAME",
                 :description => "vApp to whom VM belongs",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_vapp] = key }
        end
      end

      def get_vm(vm_arg)
        vm = nil
        vapp_name = locate_config_value(:vcloud_vapp)
        org_name = locate_org_option
        vdc_name = locate_config_value(:vcloud_vdc)

        unless vdc_name && vapp_name
          notice_msg("--vapp and --vdc not specified, assuming VM is an ID")
          vm = connection.get_vm vm_arg
        else
          org = connection.get_organization_by_name org_name
          vm = connection.get_vm_by_name org, vdc_name, vapp_name, vm_arg
        end
        raise ArgumentError, "VM #{vm_arg} not found" unless vm
        vm
      end

      # Accept only characters and hyphens
      #
      # Underscores are converted to hyphens
      def sanitize_guest_name(name)
        name.gsub(/_/, '-').gsub(/[^[0-9]|^[a-z]|^[A-Z]|^-]/, '')
      end

      # Verify a VM and stop it if it's running
      #
      # Return :nothing if nothing was made
      #        :errored for errors
      #        :stopped if was stopped
      def stop_if_running(connection, vm)
        if vm[:status] == 'running'
          if ui.confirm("Guest customizations must be applied to a stopped VM, " \
                        "but it's running. Can I #{ui.color('STOP', :red)} it")
            ui.msg "Stopping VM..."
            task_id, response = connection.poweroff_vm vm[:id]
            return :errored unless wait_task(connection, task_id)
          end
          return :stopped
        end
        return :nothing
      end
    end
  end
end
