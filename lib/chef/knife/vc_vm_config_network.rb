#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2012
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

require 'chef/knife'

module KnifeVCloud
  class VcVmConfigNetwork < Chef::Knife
    include KnifeVCloud::Common

    deps do
      require 'vcloud-rest/connection'
      require 'chef/api_client'
    end

    banner "knife vc vm config network [VAPP_ID] [NETWORK_NAME] (options)"

    option :vcloud_url,
           :short => "-H URL",
           :long => "--vcloud-url URL",
           :description => "The vCloud endpoint URL",
           :proc => Proc.new { |url| Chef::Config[:knife][:vcloud_url] = url }

    option :vcloud_user,
           :short => "-U USER",
           :long => "--vcloud-user USER",
           :description => "Your vCloud User",
           :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_user] = key }

    option :vcloud_password,
           :short => "-P SECRET",
           :long => "--vcloud-password SECRET",
           :description => "Your vCloud secret key",
           :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_password] = key }

    option :vcloud_org,
           :short => "-O ORGANIZATION",
           :long => "--vcloud-organization ORGANIZATION",
           :description => "Your vCloud Organization",
           :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_org] = key }

    option :vcloud_api_version,
           :short => "-A API_VERSION",
           :long => "--vcloud-api-version API_VERSION",
           :description => "vCloud API version (1.5 and 5.1 supported)",
           :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_api_version] = key }

    option :vm_net_primary_index,
           :long => "--net-primary NETWORK_PRIMARY_IDX",
           :description => "Index of the primary network interface"

    option :vm_net_index,
           :long => "--net-index NETWORK_IDX",
           :description => "Index of the current network interface"

    option :vm_net_ip,
           :long => "--net-ip NETWORK_IP",
           :description => "IP of the current network interface"

    option :vm_net_is_connected,
           :long => "--net-is-connected true|false",
           :description => "Toggle IsConnected flag of the current network interface"

    option :vm_ip_allocation_mode,
           :long => "--ip-allocation-mode ALLOCATION_MODE",
           :description => "Set IP allocation mode of the current network interface (e.g., POOL)"

    def run
      $stdout.sync = true

      vm_id = @name_args.shift
      network_name = @name_args.shift

      connection.login

      task_id, response = connection.set_vm_network_config vm_id, network_name, {:ip_allocation_mode => 'POOL'}

      print "VM network configuration..."
      wait_task(connection, task_id)

      connection.logout
    end
  end
end
