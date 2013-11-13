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
    class VcOvfUpload < Chef::Knife
      include Knife::VcCommon
      include Knife::VcVDCCommon
      include Knife::VcCatalogCommon

      banner "knife vc ovf upload VDC CATALOG VAPP_NAME VAPP_DESCRIPTION OVF_FILENAME (options)"

      option :ovf_show_progress_bar,
             :long => "--[no-]progressbar",
             :description => "Show a progress bar for uploads",
             :proc => Proc.new { |key| Chef::Config[:knife][:ovf_show_progress_bar] = key },
             :boolean => true,
             :default => true

      option :ovf_send_manifest,
             :long => "--[no-]send-manifest",
             :description => "Send a manifest",
             :boolean => true,
             :default => false

      def run
        $stdout.sync = true

        vdc_arg = @name_args.shift
        catalog_arg = @name_args.shift
        vapp_name = @name_args.shift
        vapp_description = @name_args.shift
        ovf_filename = @name_args.shift

        show_progress_bar = locate_config_value(:ovf_show_progress_bar)
        send_manifest = locate_config_value(:ovf_send_manifest)

        connection.login

        vdc = get_vdc(vdc_arg)
        catalog = get_catalog(catalog_arg)

        ui.msg "Uploading OVF..."

        result = connection.upload_ovf(vdc[:id], vapp_name,
                          vapp_description, ovf_filename, catalog[:id],
                          { :send_manifest => send_manifest,
                            :progressbar_enable => show_progress_bar})

        ui.msg "OVF uploaded. vAppTemplate created with ID: #{ui.color(result[:id], :cyan)}"

        connection.logout
      end
    end
  end
end
