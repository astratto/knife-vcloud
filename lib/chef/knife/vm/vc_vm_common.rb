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
        end
      end

      def get_vm(vm_arg)
        vapp_name = locate_config_value(:vapp_name)
        org_name = locate_config_value(:org_name)
        vdc_name = locate_config_value(:vdc_name)

        unless org_name && vdc_name && vapp_name
          notice_msg("--vapp, --org and --vdc not specified, assuming VM is an ID")
          vm = connection.get_vm vm_arg
        else
          org = connection.get_organization_by_name org_name
          vm = connection.get_vm_by_name org, vdc_name, vapp_name, vm_arg
        end
      end
    end
  end
end
