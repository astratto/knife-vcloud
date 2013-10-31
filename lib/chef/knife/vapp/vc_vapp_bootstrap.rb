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
    class VcVappBootstrap < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVappCommon
      include Knife::VcBootstrapCommon

      banner "knife vc vapp bootstrap [VAPP] (options)"

      def run
        $stdout.sync = true
        @test_connection_timeout = 5

        vapp_arg = @name_args.shift

        connection.login

        vapp = get_vapp(vapp_arg)

        if locate_config_value(:bootstrap_windows)
          ui.msg "Windows bootstrapping is not available, yet."
        else
          vapp[:vms_hash].each do |vm_name, details|
            addresses = details[:addresses].reject(&:nil?)
            bootstrap_vm(vm_name, details[:id], addresses)
          end
        end

        connection.logout
      end
    end
  end
end
