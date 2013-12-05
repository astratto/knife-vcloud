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
    module VcVmCommon

      def self.included(includer)
        includer.class_eval do
          option :vcloud_vdc,
                 :long => "--vdc VDC_NAME",
                 :description => "VDC to whom VM's vApp belongs",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_vdc] = key }

          option :vcloud_vapp,
                 :long => "--vapp VAPP_NAME",
                 :description => "vApp to whom VM belongs",
                 :proc => Proc.new { |key| Chef::Config[:knife][:vcloud_vapp] = key }
        end
      end

      # Accept only characters and hyphens
      #
      # Underscores are converted to hyphens
      def sanitize_guest_name(name)
        name.gsub(/_/, '-').gsub(/[^[0-9]|^[a-z]|^[A-Z]|^-]/, '')
      end

      # Verify a VM and stop it if it's running
      #
      # Return :nothing if nothing was made
      #        :errored for errors
      #        :stopped if was stopped
      def stop_if_running(vm)
        if vm.ready?
          if ui.confirm("Guest customizations must be applied to a stopped VM, " \
                        "but it's running. Can I #{ui.color('STOP', :red)} it")
            ui.msg "Stopping VM..."
            vm.shutdown
            return :errored
          end
          return :stopped
        end
        return :nothing
      end
    end
  end
end
