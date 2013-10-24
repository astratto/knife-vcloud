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

class Chef
  class Knife
    module VcCommon
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
          ui.msg("#{ui.color(label, :cyan)}: #{value}")
        end
      end

      def notice_msg(value)
        if value && !value.empty?
          ui.info("#{ui.color('Note:', :bold)} #{value}")
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
