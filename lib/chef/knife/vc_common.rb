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

class Chef
  class Knife
    # Module for operations common among commands
    module VcCommon
      # :nodoc:
      # Would prefer to do this in a rational way, but can't be done b/c of
      # Mixlib::CLI's design :(
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'vcloud-rest/connection'
            require 'chef/api_client'
          end

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
        end
      end

      def connection
        unless @connection
          @connection = VCloudClient::Connection.new(
              locate_config_value(:vcloud_url),
              locate_config_value(:vcloud_user),
              locate_config_value(:vcloud_password),
              locate_config_value(:vcloud_org),
              locate_config_value(:vcloud_api_version)
          )
        end
        @connection
      end

      def out_msg(label, value)
        if value && !value.empty?
          puts "#{ui.color(label, :cyan)}: #{value}"
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def wait_task(connection, task_id)
        result = connection.wait_task_completion task_id

        puts "Done!"
        out_msg("Summary",
          "Status: #{ui.color(result[:status], :cyan)} - started at #{result[:start_time]} and ended at #{result[:end_time]}")

        if result[:errormsg]
          puts ui.color("ATTENTION: #{result[:errormsg]}", :red)
        end
      end
    end
  end
end