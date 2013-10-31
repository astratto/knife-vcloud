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
    class VcVappSnapshot < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVappCommon

      banner "knife vc vapp snapshot [create|revert] [VAPP] (options)"

      def run
        $stdout.sync = true

        command_arg = @name_args.shift
        vapp_arg = @name_args.shift

        unless command_arg =~ /create|revert/
          raise ArgumentError, "Invalid command #{command_arg} supplied. Only create and revert are allowed."
        end

        command = command_arg.to_sym

        connection.login

        vapp = get_vapp(vapp_arg)

        case command
          when :create
            task_id = connection.create_snapshot vapp[:id]
            ui.msg "vApp snapshot creation..."
            wait_task(connection, task_id)
          when :revert
            task_id = connection.revert_snapshot vapp[:id]
            ui.msg "vApp snapshot revert..."
            wait_task(connection, task_id)
        end

        connection.logout
      end
    end
  end
end
