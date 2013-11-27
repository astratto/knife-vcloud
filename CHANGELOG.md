Changes
==
Next Version (0.x.y)
--

FEATURES:
* Add commands to resume/suspend/reset vApps
* Show CPU/RAM/Disks info for VMs
* Add command to set VM's info (Name, CPUs & RAM)
* Add command to manage VM's disks (add, delete, resize)
* Add command to clone an existing vApp
* Org show searches by name by default
* VDCs can be searched by ID or by Name and Organization
* Catalogs can be searched by ID or by Name and Organization
* vApps can be searched by ID or by Name, Organization and VDC
* VMs can be searched by ID or by Name, Organization, VDC and vApp
* Add support for customization scripts
* Add commands to manage VM's status (start/stop/delete/reset/suspend/reboot)
* Add command to show details about a given network
* Guest customization: ensure VM is stopped or stop it
* Show network details in vapp show
* Split commands to manage internal and external vApp networks
* Add command to bootstrap single VMs
* Add command to bootstrap every VM of a vApp
* Add command to create/revert a vApp snapshot
* Add command to upload OVF

CHANGES:
* Renamed & enhanced command _vapp config network_ to _vapp network external_
* Several options have been revisited (see README.md for details)

VARIOUS:
* Update dependency vcloud-rest v. 0.4.0

2012-12-28 (0.2.3)
--

VARIOUS:
* Update dependency vcloud-rest v. 0.2.1
* Update documentation

FIXES:
* Minor fixes

2012-12-27 (0.2.2)
--

FIXES:
* VM Network config: use command line arguments
* Properly use boolean options
* Minor fixes

2012-12-27 (0.2.1)
--

FIXES:
* Change namespace to fix import error under 1.9.x (system-wide)

2012-12-24 (0.2.0)
--

FEATURES:
* Add command for basic VM Guest Customization configuration
* Add command for basic VM Network configuration
* Add command for basic vApp Network configuration

FIXES:
* Renamed _Common#msg_ to _Common#out\_msg_

2012-12-21 (0.1.0)
--

Initial release

* Add support for main operations:
 * login (useful for testing connectivity/credentials)
 * organization _list/show_
 * vdc _show_
 * catalog _show_
 * catalog item _show_
 * vapp _create/delete/startup/shutdown_
