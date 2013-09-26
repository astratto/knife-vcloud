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

require 'chef/knife/vc_common'

class Chef
  class Knife
    class VcVappClone < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vapp clone [VDC_ID] [SOURCE_VAPP_ID] [DEST_NAME] (options)"

      option :vm_deploy_clone,
             :long => "--[no-]deploy-clone",
             :description => "Deploy vApp after cloning (default true)",
             :proc => Proc.new { |key| Chef::Config[:knife][:vm_deploy_clone] = key },
             :boolean => true,
             :default => true

      option :vm_poweron_clone,
             :long => "--[no-]poweron-clone",
             :description => "Poweron vApp after cloning (default false)",
             :proc => Proc.new { |key| Chef::Config[:knife][:vm_poweron_clone] = key },
             :boolean => true,
             :default => false

      option :vm_delete_source,
             :long => "--[no-]delete-source",
             :description => "Delete source vApp",
             :proc => Proc.new { |key| Chef::Config[:knife][:vm_delete_source] = key },
             :boolean => true,
             :default => false

      def run
        $stdout.sync = true

        vdc_id = @name_args.shift
        vapp_id = @name_args.shift
        dest_vapp_name = @name_args.shift
        deploy_clone = locate_config_value(:vm_deploy_clone).to_s
        poweron_clone = locate_config_value(:vm_poweron_clone).to_s
        delete_source = locate_config_value(:vm_delete_source).to_s

        connection.login

        result = connection.clone_vapp vdc_id, vapp_id, dest_vapp_name, deploy_clone, poweron_clone, delete_source

        print "Cloning vApp..."
        wait_task(connection, result[:task_id])
        puts "vApp cloned with ID: #{ui.color(result[:vapp_id], :cyan)}"

        connection.logout
      end
    end
  end
end
