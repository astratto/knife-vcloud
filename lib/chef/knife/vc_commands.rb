#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2012-2013
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

# ORG
require 'chef/knife/org/vc_org_list'
require 'chef/knife/org/vc_org_show'

# VDC
require 'chef/knife/common/vc_vdc_common'
require 'chef/knife/vdc/vc_vdc_show'

# Catalog
require 'chef/knife/common/vc_catalog_common'
require 'chef/knife/catalog/vc_catalog_show'
require 'chef/knife/catalog/vc_catalog_item_show'

# Network
require 'chef/knife/common/vc_network_common'
require 'chef/knife/network/vc_network_show'

# VAPP
require 'chef/knife/common/vc_bootstrap_common'
require 'chef/knife/common/vc_vapp_common'
require 'chef/knife/vapp/vc_vapp_network_external'
require 'chef/knife/vapp/vc_vapp_network_internal'
require 'chef/knife/vapp/vc_vapp_create'
require 'chef/knife/vapp/vc_vapp_delete'
require 'chef/knife/vapp/vc_vapp_reboot'
require 'chef/knife/vapp/vc_vapp_reset'
require 'chef/knife/vapp/vc_vapp_show'
require 'chef/knife/vapp/vc_vapp_start'
require 'chef/knife/vapp/vc_vapp_stop'
require 'chef/knife/vapp/vc_vapp_suspend'
require 'chef/knife/vapp/vc_vapp_clone'
require 'chef/knife/vapp/vc_vapp_bootstrap'
require 'chef/knife/vapp/vc_vapp_snapshot'

# VM
require 'chef/knife/common/vc_vm_common'
require 'chef/knife/vm/vc_vm_config_guest'
require 'chef/knife/vm/vc_vm_network'
require 'chef/knife/vm/vc_vm_show'
require 'chef/knife/vm/vc_vm_set_info'
require 'chef/knife/vm/vc_vm_set_disks'
require 'chef/knife/vm/vc_vm_reboot'
require 'chef/knife/vm/vc_vm_reset'
require 'chef/knife/vm/vc_vm_start'
require 'chef/knife/vm/vc_vm_stop'
require 'chef/knife/vm/vc_vm_suspend'
require 'chef/knife/vm/vc_vm_bootstrap'

# OVF
require 'chef/knife/ovf/vc_ovf_upload'
