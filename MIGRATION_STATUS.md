## GAP

* Upload OVF
* Rename VM
* Assign network to vApp (it seems it's possible to assign a network at vapp creation time)
* Clone vApp
* Guest admin password cannot be set or retrieved (PR https://github.com/fog/fog/pull/2464)
* Snapshots?!

## BUG

* Unable to retrieve has_customization_script if not existing. Fog bug?

## Status

### Ready for Fog

* vc_configure.rb
* vc_login.rb

* common/vc_bootstrap_common.rb

* org/vc_org_list.rb
* org/vc_org_show.rb

* catalog/vc_catalog_show.rb (shows also item and vapp template)

* vdc/vc_vdc_show.rb

* vapp/vc_vapp_bootstrap.rb
* vapp/vc_vapp_delete.rb
* vapp/vc_vapp_reboot.rb
* vapp/vc_vapp_reset.rb
* vapp/vc_vapp_start.rb
* vapp/vc_vapp_stop.rb
* vapp/vc_vapp_suspend.rb

* vm/vc_vm_bootstrap.rb
* vm/vc_vm_network.rb
* vm/vc_vm_reboot.rb
* vm/vc_vm_reset.rb
* vm/vc_vm_start.rb
* vm/vc_vm_stop.rb
* vm/vc_vm_suspend.rb

* vm/vc_vm_disks.rb (replaces set_disks)

# WIP

* vapp/vc_vapp_show.rb (TBD snapshot management and better network management)
* vm/vc_vm_show.rb (multinetwork support in PR https://github.com/fog/fog/pull/2458 and has_customization_script)
* vm/vc_vm_edit.rb (replaces set_info, need to implement rename_vm)

# DEPRECATED

* vm/vc_vm_config_network.rb
* catalog/vc_catalog_item_show.rb
* vm/vc_vm_set_disks.rb
* vm/vc_vm_set_info.rb
* vm/vc_vm_config_guest.rb

# TODO

* common/vc_catalog_common.rb
* common/vc_common.rb
* common/vc_network_common.rb
* common/vc_vapp_common.rb
* common/vc_vdc_common.rb
* common/vc_vm_common.rb
* network/vc_network_show.rb
* ovf/vc_ovf_upload.rb
* vapp/vc_vapp_clone.rb
* vapp/vc_vapp_create.rb
* vapp/vc_vapp_network_external.rb
* vapp/vc_vapp_network_internal.rb
* vapp/vc_vapp_snapshot.rb
