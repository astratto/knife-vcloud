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
    module VcVDCCommon
      def self.included(includer)
        includer.class_eval do
          option :vcloud_org,
                 :long => "--org ORG_NAME",
                 :description => "Organization to whom VDC belongs",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_org] = key }
        end
      end

      def get_vdc(vdc_arg)
        vdc = nil
        org_name = locate_org_option

        org = connection.get_organization_by_name org_name
        vdc = connection.get_vdc_by_name org, vdc_arg

        raise ArgumentError, "VDC #{vdc_arg} not found" unless vdc
        vdc
      end
    end
  end
end
