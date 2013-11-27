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
    module VcVappCommon

      def self.included(includer)
        includer.class_eval do
          option :vcloud_vdc,
                 :long => "--vdc VDC_NAME",
                 :description => "VDC to whom vApp belongs",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_vdc] = key }
        end
      end

      def get_vapp(vapp_arg)
        vapp = nil
        vdc_name = locate_config_value(:vcloud_vdc)

        unless vdc_name
          notice_msg("--vdc not specified, assuming VAPP is an ID")
          vapp = connection.get_vapp vapp_arg
        else
          org_name = locate_org_option
          org = connection.get_organization_by_name org_name
          vapp = connection.get_vapp_by_name org, vdc_name, vapp_arg
        end
        raise ArgumentError, "VApp #{vapp_arg} not found" unless vapp
        vapp
      end
    end
  end
end
