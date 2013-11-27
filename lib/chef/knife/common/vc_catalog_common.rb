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
          option :vcloud_catalog,
                 :long => "--catalog CATALOG_NAME",
                 :description => "Catalog to whom Catalog Item belongs",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_catalog] = key }
        end
      end

      def get_catalog(catalog_arg)
        catalog = nil
        org_name = locate_org_option

        org = connection.get_organization_by_name org_name
        catalog = connection.get_catalog_by_name org, catalog_arg

        raise ArgumentError, "Catalog #{catalog_arg} not found" unless catalog
        catalog
      end

      def get_catalog_item(catalog_item_arg)
        item = nil
        catalog_name = locate_config_value(:vcloud_catalog)

        unless catalog_name
          notice_msg("--catalog not specified, assuming CATALOG_ITEM is an ID")
          item = connection.get_catalog_item catalog_item_arg
        else
          catalog = get_catalog(catalog_name)
          item = connection.get_catalog_item_by_name catalog[:id], catalog_item_arg
        end
        raise ArgumentError, "Catalog Item #{catalog_item_arg} not found" unless item
        item
      end
    end
  end
end
