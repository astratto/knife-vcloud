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

require 'chef/knife/vc_common'

class Chef
  class Knife
    class VcVmConfigGuest < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vm config guest [VAPP_ID] [COMPUTER_NAME] (options)"

      option :guest_enabled,
             :short => "-E ENABLED",
             :long => "--enable-guest true|false",
             :description => "Toggle Guest Customization"

      option :admin_passwd_enabled,
             :long => "--admin-passwd-enabled true|false",
             :description => "Toggle Admin Password"

      option :admin_passwd,
             :long => "--admin-passwd ADMIN_PASSWD",
             :description => "Set Admin Password"

      def run
        $stdout.sync = true

        vm_id = @name_args.shift
        computer_name = @name_args.shift

        connection.login

        config = {
          :enabled => locate_config_value(:guest_enabled),
          :admin_passwd_enabled => locate_config_value(:admin_passwd_enabled),
          :admin_passwd => locate_config_value(:admin_passwd)
        }

        task_id, response = connection.set_vm_guest_customization vm_id, computer_name, config

        print "VM network configuration..."
        wait_task(connection, task_id)

        connection.logout
      end
    end
  end
end
