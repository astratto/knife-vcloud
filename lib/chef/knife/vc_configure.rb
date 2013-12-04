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

require 'chef/knife/common/vc_common'

class Chef
  class Knife
    class VcConfigure < Chef::Knife
      include Knife::VcCommon

      banner "knife vc configure (options)"

      option :change_password,
             :short => "-p",
             :long => "--[no-]change-password",
             :description => "Change the stored password",
             :boolean => true,
             :default => false

      def run
        $stdout.sync = true

        # Load or generate a keypair to encrypt info
        pemfile = locate_config_value(:vcloud_pem)
        if pemfile
          ui.msg("Loading existing pem")
          keyfile = "#{pemfile}"
        else
          ui.msg("PEM file not existing. Creating one.")
          generate_key()
          keyfile = locate_config_value(:vcloud_pem)
        end

        value = ui.ask("vCloud URL (%s): " % locate_config_value(:vcloud_url))
        unless value.empty?
          store_config(:vcloud_url, value)
        end

        value = ui.ask("vCloud username (%s): " % locate_config_value(:vcloud_user_login))
        unless value.empty?
          store_config(:vcloud_user_login, value)
        end

        value = ui.ask("vCloud API version (%s): " % (locate_config_value(:vcloud_api_version) || "5.1"))
        unless value.empty?
          store_config(:vcloud_api_version, value)
        end

        if !locate_config_value(:vcloud_password) ||
                locate_config_value(:change_password)
          store_password(keyfile)
        end
      end
    end
  end
end