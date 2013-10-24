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
    class VcVappNetworkInternal < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVappCommon
      include Knife::VcNetworkCommon

      banner "knife vc vapp network internal [add|delete|edit| [VAPP] [NETWORK] (options)"

      option :gateway,
             :long => "--gateway GATEWAY",
             :description => "Set a gateway"

      option :netmask,
             :long => "--netmask NETMASK",
             :description => "Set a netmask"

      option :dns1,
             :long => "--dns1 DNS",
             :description => "Set a DNS"

      option :dns2,
             :long => "--dns2 DNS",
             :description => "Set a DNS"

      option :dns_suffix,
             :long => "--dns-suffix DNS_SUFFIX",
             :description => "Set a DNS Suffix"

      option :start_address,
             :long => "--start-address ADDRESS",
             :description => "Set a start address"

      option :end_address,
             :long => "--end-address ADDRESS",
             :description => "Set a end address"

      option :is_inherited,
             :long => "--[no-]inherited",
             :description => "Toggle IsInherited (default false)",
             :proc => Proc.new { |key| Chef::Config[:knife][:is_inherited] = key },
             :boolean => true,
             :default => false

      option :retain_network,
             :long => "--[no-]retain-network",
             :description => "Toggle Retain Network across deployments (default true)",
             :proc => Proc.new { |key| Chef::Config[:knife][:retain_network] = key },
             :boolean => true,
             :default => true

      option :parent_network,
             :short => "-p PARENT_NETWORK",
             :long => "--parent-network PARENT_NETWORK",
             :description => "Set a parent network for this internal network",
             :proc => Proc.new { |key| Chef::Config[:knife][:parent_network] = key }

      def run
        $stdout.sync = true

        command_arg = @name_args.shift
        vapp_arg = @name_args.shift
        network_arg = @name_args.shift

        unless command_arg =~ /add|delete|edit/
          raise ArgumentError, "Invalid command #{command_arg} supplied. Only add, delete and edit are allowed."
        end

        command = command_arg.to_sym

        config = { :fence_mode => 'isolated' }

        connection.login

        vapp = get_vapp(vapp_arg)

        network = vapp[:networks].select{|n| n[:name] == network_arg }.first

        unless network
          if command != :add
            raise ArgumentError, "Network #{network_arg} not found in vApp, " \
                                      "please use `--add` if you want to add new network."
          else
            network = {:name => network_arg}
          end
        end

        unless command == :delete
          fields = [:gateway, :netmask, :dns1, :dns2, :dns_suffix,
                    :start_address, :end_address, :is_inherited, :retain_network]

          fields.each do |field|
            config[field] = locate_config_value(field)

            if command == :add && config[field].nil?
              config[field] = ui.ask_question("  #{pretty_symbol(field)}: ")
            end
          end

          parent_network_arg = locate_config_value(:parent_network)
          if parent_network_arg
            ui.msg "Retrieving parent network details"
            parent_network = get_network parent_network_arg
            config[:parent_network] =  { :id => parent_network[:id],
                                        :name => parent_network[:name] }
          end

          if parent_network && config[:fence_mode] != 'natRouted'
            ui.info "Setting a parent network for an internal network requires fence mode natRouted. Fixing it..."
            config[:fence_mode] = 'natRouted'
          end
        end

        case command
          when :add
            ui.msg "Adding #{network[:name]} to vApp..."
            task_id, response = connection.add_internal_network_to_vapp vapp[:id], network, config
            wait_task(connection, task_id)
          when :delete
            ui.msg "Removing #{network[:name]} from vApp..."
            task_id, response = connection.delete_vapp_network vapp[:id], network
            wait_task(connection, task_id)
          when :edit
            ui.msg "vApp network configuration for #{network[:name]}..."
            task_id, response = connection.set_vapp_network_config vapp[:id], network, config
            wait_task(connection, task_id)
        end

        connection.logout
      end
    end
  end
end
