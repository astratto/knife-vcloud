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
    class VcNetworkShow < Chef::Knife
      include Knife::VcCommon
      include Knife::VcNetworkCommon

      banner "knife vc network show [network] (options)"

      def run
        $stdout.sync = true

        network_arg = @name_args.shift
        connection.login
        network = get_network(network_arg)
        connection.logout

        out_msg('ID', network[:id])
        out_msg('Name', network[:name])
        out_msg('Description', network[:description])
        out_msg('Gateway', network[:gateway])
        out_msg('Netmask', network[:netmask])
        out_msg('Fence mode', network[:fence_mode])
        out_msg('IP Range', "#{network[:start_address]} - #{network[:end_address]}")
      end
    end
  end
end
