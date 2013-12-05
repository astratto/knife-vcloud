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
    class VcVmBootstrap < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVmCommon
      include Knife::VcBootstrapCommon

      banner "knife vc vm bootstrap [VM] (options)"

      def run
        $stdout.sync = true
        @test_connection_timeout = 5

        vm_arg = @name_args.shift

        vm = get_vm(vm_arg)

        if locate_config_value(:bootstrap_windows)
          ui.msg "Windows bootstrapping is not available, yet."
        else
          addresses = vm.network.connections.collect{|c| c[:ip_address]}.reject{|ip| ip.nil?}
          bootstrap_vm(vm.name, vm.id, addresses)
        end
      end
    end
  end
end
