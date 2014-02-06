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

class Chef
  class Knife
    class ConfigurationError < StandardError; end

    module VcCommon
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'vcloud-rest/connection'
            require 'chef/api_client'
          end

          option :vcloud_url,
                 :short => "-H URL",
                 :long => "--url URL",
                 :description => "The vCloud endpoint URL",
                 :proc => Proc.new { |url| Chef::Config[:knife][:vcloud_url] = url }

          option :vcloud_user_login,
                 :short => "-U USER",
                 :long => "--user-login USER",
                 :description => "Your vCloud User",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_user_login] = key }

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

          unless pemfile
            raise ConfigurationError, "PEM file not configured. Please run 'knife vc configure'"
          end

          unless locate_config_value(:vcloud_password)
            raise ConfigurationError, "Password not configured. Please run 'knife vc configure'"
          end

          passwd = get_password(pemfile)

          @connection = VCloudClient::Connection.new(
              locate_config_value(:vcloud_url),
              locate_config_value(:vcloud_user_login),
              passwd,
              locate_config_value(:vcloud_org_login),
              locate_config_value(:vcloud_api_version)
          )
        end

        @connection
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

      def sort_by_key(collection)
        collection.sort_by {|k, v| k }
      end

      # Generate a new key pair and store it on knife.rb
      def generate_key(output="vc_key.pem")
        dir = File.dirname(get_config_file)
        key = OpenSSL::PKey::RSA.new 2048

        pemfile = File.join(dir, output)

        File.open("#{pemfile}", 'w') do |io| io.write key.to_pem end
        FileUtils.chmod 0600, pemfile

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
        configfile = get_config_file
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
        def get_config_file
          knife_cfg = File.join('.chef', 'knife.rb')

          if File.exists?(File.join(Dir.pwd, knife_cfg))
            File.join(Dir.pwd, knife_cfg)
          else
            File.join(Dir.home, knife_cfg)
          end
        end

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
