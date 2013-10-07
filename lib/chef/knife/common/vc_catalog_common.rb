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
    module VcCatalogCommon
      def self.included(includer)
        includer.class_eval do
          option :vcloud_org_name,
                 :long => "--org ORG_NAME",
                 :description => "Organization to whom Catalog belongs",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_org_name] = key }
        end
      end

      def get_catalog(catalog_arg)
        org_name = locate_config_value(:vcloud_org_name)

        unless org_name
          notice_msg("--org not specified, assuming CATALOG is an ID")
          catalog = connection.get_catalog catalog_arg
        else
          org = connection.get_organization_by_name org_name
          catalog = connection.get_catalog_by_name org, catalog_arg
        end
      end
    end
  end
end
