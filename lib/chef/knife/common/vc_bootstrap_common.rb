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
    module VcBootstrapCommon
      def self.included(includer)
        includer.class_eval do
          deps do
            require 'chef/knife/bootstrap'
            require 'chef/knife/bootstrap_windows_winrm'
            require 'chef/knife/core/windows_bootstrap_context'
            Chef::Knife::Bootstrap.load_deps
          end

          option :run_list,
            :short => "-r RUN_LIST",
            :long => "--run-list RUN_LIST",
            :description => "Comma separated list of roles/recipes to apply",
            :proc => lambda { |o| o.split(/[\s,]+/) },
            :default => []

          option :distro,
            :short => "-d DISTRO",
            :long => "--distro DISTRO",
            :description => "Bootstrap a distro using a template; default is 'chef-full'",
            :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
            :default => "chef-full"

          option :bootstrap_windows,
            :long => "--[no-]bootstrap-windows",
            :description => "The machine to be bootstrapped is Windows",
            :boolean => true,
            :default => false

          option :bootstrap_proxy,
            :long => "--bootstrap-proxy PROXY_URL",
            :description => "The proxy server for the node being bootstrapped",
            :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_proxy] = v }

          option :ssh_user,
            :short => "-x USERNAME",
            :long => "--ssh-user USERNAME",
            :description => "The ssh username",
            :default => "root"

          option :ssh_password,
            :short => "-P PASSWORD",
            :long => "--ssh-password PASSWORD",
            :description => "The ssh password"

          option :ssh_port,
            :short => "-p PORT",
            :long => "--ssh-port PORT",
            :description => "The ssh port",
            :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key },
            :default => 22

          option :ssh_gateway,
            :short => "-G GATEWAY",
            :long => "--ssh-gateway GATEWAY",
            :description => "The ssh gateway",
            :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

          option :forward_agent,
            :short => "-A",
            :long => "--forward-agent",
            :description => "Enable SSH agent forwarding",
            :boolean => true

          option :identity_file,
            :short => "-i IDENTITY_FILE",
            :long => "--identity-file IDENTITY_FILE",
            :description => "The SSH identity file used for authentication"

          option :host_key_verify,
            :long => "--[no-]host-key-verify",
            :description => "Verify host key, enabled by default.",
            :boolean => true,
            :default => true

          option :max_tries,
            :long => "--max-tries MAX_TRIES",
            :description => "Max number of connection tries for each VM",
            :default => 5

          option :secret,
            :short => "-s SECRET",
            :long  => "--secret ",
            :description => "The secret key to use to encrypt data bag item values",
            :proc => Proc.new { |s| Chef::Config[:knife][:secret] = s }

          option :secret_file,
            :long => "--secret-file SECRET_FILE",
            :description => "A file containing the secret key to use to encrypt data bag item values",
            :proc => Proc.new { |sf| Chef::Config[:knife][:secret_file] = sf }

          option :template_file,
            :long => "--template-file TEMPLATE_FILE",
            :description => "Template file to use for bootstrap",
            :proc => Proc.new { |sf| Chef::Config[:knife][:template_file] = tf }

          Chef::Config[:knife][:hints] ||= {"vcloud" => {}}
          option :hint,
            :long => "--hint HINT_FILE",
            :description => "Specify Ohai Hint to be set on the bootstrap target.",
            :proc => Proc.new { |path| Chef::Config[:knife][:hints]["vcloud"] = path ? JSON.parse(::File.read(path)) : Hash.new }
        end
      end

      def bootstrap_vm(vm_name, id, addresses)
        ui.msg "Bootstrap VM: #{vm_name}..."

        max_tries = locate_config_value(:max_tries)
        ssh_port = locate_config_value(:ssh_port)

        # Stop at the first reachable IP address
        reachable_ip = nil
        addresses.each do |address|
          tries = 1

          until tries > max_tries
            ui.info "Trying to reach #{address} (try #{tries}/#{max_tries})"

            if test_connection_ssh(address, ssh_port)
              reachable_ip = address
              break
            end
            tries += 1
          end
          break if reachable_ip
        end

        if reachable_ip
          ui.msg "Bootstrap IP: #{reachable_ip}"
          bootstrap_for_node(reachable_ip).run
        else
          ui.warn "No reachable IPs. Not bootstrapping."
        end
      end

      private
        def test_connection_ssh(hostname, port)
          socket = TCPSocket.new(hostname, port)

          result = IO.select([socket], nil, nil, @test_connection_timeout)
          if result
            ui.info("\t#{hostname}:#{port} replied with: #{socket.gets}")
            true
          else
            false
          end
        rescue Errno::ETIMEDOUT, Errno::EPERM => e
          ui.info("\tUnable to reach #{hostname}:#{port} => #{e.message}")
          false
        rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH, Errno::ECONNRESET => e
          ui.info("\tUnable to reach #{hostname}:#{port} => #{e.message}")
          sleep 2
          false
        ensure
          socket && socket.close
        end

        def bootstrap_for_node(fqdn)
          bootstrap = Chef::Knife::Bootstrap.new
          bootstrap.name_args = [fqdn]
          bootstrap.config[:ssh_user] = locate_config_value(:ssh_user) || "root"
          bootstrap.config[:ssh_password] = locate_config_value(:ssh_password)
          bootstrap.config[:use_sudo] = true unless locate_config_value(:ssh_user) == 'root'
          bootstrap.config[:ssh_user] = locate_config_value(:ssh_user)
          bootstrap.config[:ssh_password] = config[:ssh_password]
          bootstrap.config[:ssh_port] = locate_config_value(:ssh_port)
          bootstrap.config[:ssh_gateway] = locate_config_value(:ssh_gateway)
          bootstrap.config[:forward_agent] = locate_config_value(:forward_agent)
          bootstrap.config[:identity_file] = locate_config_value(:identity_file)
          bootstrap.config[:manual] = true
          bootstrap.config[:host_key_verify] = locate_config_value(:host_key_verify)

          bootstrap.config[:run_list] = config[:run_list]
          bootstrap.config[:prerelease] = config[:prerelease]
          bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
          bootstrap.config[:distro] = locate_config_value(:distro)
          bootstrap.config[:template_file] = locate_config_value(:template_file)
          bootstrap.config[:bootstrap_proxy] = locate_config_value(:bootstrap_proxy)
          bootstrap.config[:environment] = config[:environment]
          bootstrap.config[:encrypted_data_bag_secret] = locate_config_value(:secret)
          bootstrap.config[:encrypted_data_bag_secret_file] = locate_config_value(:secret_file)

          bootstrap
        end
    end
  end
end
