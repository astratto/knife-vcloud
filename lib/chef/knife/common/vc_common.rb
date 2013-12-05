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

require 'chef/knife'
require 'date'
require 'openssl'
require 'base64'
require 'fog/vcloud_director/compute'

class Chef
  class Knife
    class ConfigurationError < StandardError; end

    module VcCommon
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'fog'
            require 'chef/api_client'
          end

          option :vcloud_url,
                 :short => "-H URL",
                 :long => "--url URL",
                 :description => "The vCloud endpoint URL",
                 :proc => Proc.new { |url| Chef::Config[:knife][:vcloud_url] = url }

          option :vcloud_host,
                 :long => "--host HOST",
                 :description => "The vCloud endpoint HOST",
                 :proc => Proc.new { |url| Chef::Config[:knife][:vcloud_host] = host }

          option :vcloud_user_login,
                 :short => "-U USER",
                 :long => "--user-login USER",
                 :description => "Your vCloud User",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_user_login] = key }

          option :vcloud_password_login,
                 :short => "-P SECRET",
                 :long => "--password-login SECRET",
                 :description => "Your vCloud secret key",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_password_login] = key }

          option :vcloud_org_login,
                 :long => "--org-login ORGANIZATION",
                 :description => "Your vCloud Organization",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_org_login] = key }

          option :vcloud_api_version,
                 :short => "-A API_VERSION",
                 :long => "--api-version API_VERSION",
                 :description => "vCloud API version (1.5 and 5.1 supported)",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_api_version] = key }

          option :vcloud_system_admin,
                 :long => "--[no-]system-admin",
                 :description => "Set to true if user is a vCloud System Administrator",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_system_admin] = key },
                 :boolean => true,
                 :default => false

          option :vcloud_org,
                 :long => "--org ORG_NAME",
                 :description => "Organization to use (only for System Administrators)",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_org] = key }
        end
      end

      def connection
        unless @connection
          pemfile = locate_config_value(:vcloud_pem)

          if locate_config_value(:vcloud_password_login)
            ui.info("#{ui.color('DEPRECATION WARNING:', :bold)} knife[:vcloud_password_login] is deprecated" \
                  " and will be removed in the next version. You should remove it and run 'knife vc configure'.")
            passwd = locate_config_value(:vcloud_password_login)
          else
            unless pemfile
              raise ConfigurationError, "PEM file not configured. Please run 'knife vc configure'"
            end

            unless locate_config_value(:vcloud_password)
              raise ConfigurationError, "Password not configured. Please run 'knife vc configure'"
            end

            passwd = get_password(pemfile)
          end

          if locate_config_value(:vcloud_url)
            ui.info("#{ui.color('DEPRECATION WARNING:', :bold)} knife[:vcloud_url] is deprecated" \
                  " and will be removed in the next version. You should remove it and run 'knife vc configure'.")
            host = locate_config_value(:vcloud_url).gsub(/^http[s]*\:\/\//, '')
          else
            host = locate_config_value(:vcloud_host)
          end

          @connection = Fog::Compute::VcloudDirector.new ({
            :vcloud_director_username  => "#{locate_config_value(:vcloud_user_login)}@#{locate_config_value(:vcloud_org_login)}",
            :vcloud_director_password => passwd,
            :vcloud_director_host => host,
            :vcloud_director_api_version => locate_config_value(:vcloud_api_version),
            :connection_options => { :ssl_verify_peer => false} # TODO: handle proper certificate
          })
        end

        @connection
      end

      # Retrieve the current organization
      def organization
        @organization ||= connection.organizations.get_by_name(locate_org_option)
      end

      def get_vdc(vdc_arg)
        vdc = nil
        vdc = organization.vdcs.get_by_name vdc_arg
        raise ArgumentError, "VDC #{vdc_arg} not found" unless vdc
        vdc
      end

      def get_vapp(vapp_arg)
        vapp = nil
        vdc_name = locate_config_value(:vcloud_vdc)
        vdc = get_vdc(vdc_name)
        vapp = vdc.vapps.get_by_name(vapp_arg)
        raise ArgumentError, "VApp #{vapp_arg} not found" unless vapp
        vapp
      end

      def get_vm(vm_arg)
        vm = nil

        vapp_name = locate_config_value(:vcloud_vapp)
        vapp = get_vapp(vapp_name)

        vm = vapp.vms.get_by_name(vm_arg)

        raise ArgumentError, "VM #{vm_arg} not found" unless vm
        vm
      end

      # Convert vApp status codes into human readable description
      def convert_vapp_status(status_code)
        case status_code.to_i
          when 0
            'suspended'
          when 3
            'paused'
          when 4
            'running'
          when 8
            'stopped'
          when 10
            'mixed'
          else
            "Unknown #{status_code}"
        end
      end

      def short_description(text, length=15)
        line, rest = text.gsub(/\n/, '')
        if line
          result = "#{line[0..length]}"
          result << "..." if line.size > length
          result
        else
          ''
        end
      end

      # Locate the correct organization option
      #
      # System Administrators can browse several organizations and thus --org
      # can be used to specify different organizations
      #
      # Only --org-login is valid for other users
      def locate_org_option
        org = locate_config_value(:vcloud_org_login)

        if locate_config_value(:vcloud_system_admin)
          return locate_config_value(:vcloud_org) || org
        end

        if locate_config_value(:vcloud_org)
          ui.warn("--org option is available only for vCloud System Administrators. " \
                  "Using --org-login ('#{org}').")
        end
        return org
      end

      def out_msg(label, value)
        if value && !value.empty?
          ui.msg("#{ui.color(label, :cyan)}: #{value}")
        end
      end

      def notice_msg(value)
        if value && !value.empty?
          ui.info("#{ui.color('Note:', :bold)} #{value}")
        end
      end

      def deprecation_msg(value)
        if value && !value.empty?
          ui.info("#{ui.color('DEPRECATION WARNING:', :bold)} This method is deprecated" \
                  " and will be removed in the next version. You should use #{value}.")
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def wait_task(connection, task_id)
        result = connection.wait_task_completion task_id

        elapsed = humanize_elapsed_time(result[:start_time], result[:end_time])

        out_msg("Summary",
          "Status: #{ui.color(result[:status], :cyan)} - time elapsed: #{elapsed}")

        if result[:errormsg]
          ui.warn(ui.color("ATTENTION: #{result[:errormsg]}", :red))
        end

        result[:errormsg].nil?
      end

      def pretty_symbol(key)
        key.to_s.gsub('_', ' ').capitalize
      end

      def sort_by(collection, method)
        collection.sort_by(&method)
      end

      def method_missing(method_name, *args, &block)
        if method_name =~ /sort_by_(.*)/
          sort_by(args.first, $1.to_sym)
        else
          super
        end
      end

      # Generate a new key pair and store it on knife.rb
      def generate_key(dir="#{File.join(Dir.home, '.chef')}", output="vc_key.pem")
        key = OpenSSL::PKey::RSA.new 2048

        pemfile = File.join(dir, output)

        File.open("#{pemfile}", 'w') do |io| io.write key.to_pem end

        store_config(:vcloud_pem, pemfile)
      end

      # Store a password in knife.rb
      def store_password(keyfile)
        pub_key = OpenSSL::PKey::RSA.new(File.read(keyfile)).public_key
        result = Base64.encode64(pub_key.public_encrypt(ui.ask("Enter your password: ") { |q| q.echo = false }))
        store_config(:vcloud_password, result.gsub("\n", ''))
      end

      # Retrieve a stored password
      def get_password(keyfile)
        priv_key = OpenSSL::PKey::RSA.new(File.read(keyfile))
        result = priv_key.private_decrypt(Base64.decode64(locate_config_value(:vcloud_password)))
        result
      end

      # Update knife.rb with an entry knife[:KEY] = VALUE
      #
      # It checks whether a given configuration already exists and, if so, updates it
      def store_config(key, value)
        configfile = File.join(Dir.home, '.chef', 'knife.rb')
        old_config = File.open(configfile, 'r').readlines
        full_key = "knife[:#{key}]"

        if Chef::Config[:knife][key]
          # Replace existing key
          File.open("#{configfile}.tmp", 'w') do |new_config|
            old_config.each do |line|
              if line =~ Regexp.new("^#{Regexp.escape(full_key)}")
                line = "#{full_key} = '#{value}'"
              end
              new_config.puts line
            end
          end

          FileUtils.mv("#{configfile}.tmp", configfile)
        else
          # Create a new one
          File.open(configfile, 'a') do |new_config|
            new_config.puts "#{full_key} = '#{value}'"
          end
        end

        # Reload Chef configuration
        self.configure_chef
      end

      private
        def humanize_elapsed_time(start_time, end_time)
          start_time = Time.parse(start_time || Time.now)
          end_time = Time.parse(end_time || Time.now)
          secs = (end_time - start_time)

          [[60, :seconds],
            [60, :minutes],
            [24, :hours]].map do |count, name|
            secs, n = secs.divmod(count)
            "#{n} #{name}" unless n <= 0
          end.compact.reverse.join(' ')
        end
    end
  end
end
