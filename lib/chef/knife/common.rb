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

module KnifeVCloud
  # Module for operations common among commands
  module Common
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

    def msg(label, value)
      if value && !value.empty?
        puts "#{ui.color(label, :cyan)}: #{value}"
      end
    end

    def locate_config_value(key)
      key = key.to_sym
      Chef::Config[:knife][key] || config[key]
    end

    def wait_task(connection, task_id)
      status, errormsg, start_time, end_time = connection.wait_task_completion task_id
      puts "Done!"
      msg("Summary", "Status: #{ui.color(status, :cyan)} - started at #{start_time} and ended at #{end_time}")

      if errormsg
        puts ui.color("ATTENTION: #{errormsg}", :red)
      end
    end
  end
end