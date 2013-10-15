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
    class VcVappCreate < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVDCCommon

      deps do
        require 'chef/knife/bootstrap'
        require 'chef/knife/bootstrap_windows_winrm'
        require 'chef/knife/core/windows_bootstrap_context'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife vc vapp create [VDC] [NAME] [DESCRIPTION] [TEMPLATE_ID] (options)"

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template; default is 'ubuntu12.04-gems'",
        :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
        :default => "ubuntu12.04-gems"

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node",
        :proc => Proc.new { |t| Chef::Config[:knife][:chef_node_name] = t }

      option :no_bootstrap,
        :long => "--[no-]bootstrap",
        :description => "Disable Chef bootstrap",
        :boolean => true,
        :proc => Proc.new { |v| Chef::Config[:knife][:no_bootstrap] = v },
        :default => false

      option :bootstrap_protocol,
        :long => "--bootstrap-protocol protocol",
        :description => "Protocol to bootstrap windows servers. options: winrm",
        :default => nil

      option :bootstrap_proxy,
        :long => "--bootstrap-proxy PROXY_URL",
        :description => "The proxy server for the node being bootstrapped",
        :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_proxy] = v }


      def run
        $stdout.sync = true

        vdc_arg = @name_args.shift
        name = @name_args.shift
        description = @name_args.shift
        templateId = @name_args.shift
        bootstrap = locate_config_value(:no_bootstrap)

        connection.login

        vdc = get_vdc(vdc_arg)

        result = connection.create_vapp_from_template vdc[:id], name, description, templateId

        ui.msg "vApp creation..."
        wait_task(connection, result[:task_id])
        ui.msg "vApp created with ID: #{ui.color(result[:vapp_id], :cyan)}"

        if bootstrap
          puts "Bootstrap"

        #   ui.msg "vApp bootstrap..."

        #   if locate_config_value(:bootstrap_protocol) == 'winrm'
        #     print(".") until tcp_test_winrm(public_ip_address, locate_config_value(:winrm_port)) {
        #       sleep @initial_sleep_delay ||= 10
        #       puts("done")
        #     }
        #     bootstrap_for_windows_node(server, public_ip_address).run
        #   else
        #     print "\n#{ui.color("Waiting for sshd", :magenta)}"
        #     print(".") until tcp_test_ssh(public_ip_address) {
        #       sleep @initial_sleep_delay ||= 10
        #       puts("done")
        #     }
        #     bootstrap_for_node(server, public_ip_address).run
        #   end
        end

        connection.logout
      end
    end
  end
end
