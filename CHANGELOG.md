Changes
==
2014-02-06 (1.2.0)
--

This version requires vcloud-rest v. 1.2.0.

FEATURES:

* Honor local .chef/knife.rb precedence

DEPRECATIONS:

* Remove `vm config network` deprecated in 1.1.0
* Remove *knife[:vcloud_password_login]* deprecated in 1.1.0

2013-12-13 (1.1.0)
--

This version introduces new features and deprecations.  
Deprecated features will be dropped in the future release.

FEATURES:

* Add option *--override-guest* to `vm set info` to rename also its guest name (*false* by default for backward-compatibility)
* Add command `vm network [add|delete|edit]` to manage multiple networks
* Use RSA keys to manage passwords
* Add command `knife vc configure` to manage knife-vcloud's configuration

DEPRECATIONS:

* `vm config network` is now deprecated
* *knife[:vcloud_password_login]* is now deprecated and should be replaced using ```knife vc configure```

2013-11-29 (1.0.0)
--

This is the first release that leaves beta status.
It's actively used in production by at least one company and thus it's important
to offer a more stable interface.

This version requires vcloud-rest v. 1.0.0.

FEATURES:

* vApp management
    * Add commands to resume/suspend/reset vApps
    * Add command to clone an existing vApp
    * Show network details in vapp show
    * Split commands to manage internal and external vApp networks
    * Add command to create/revert a vApp snapshot
* VM management
    * Add commands to manage VM's status (start/stop/delete/reset/suspend/reboot)
    * Show CPU/RAM/Disks info for VMs
    * Add command to set VM's info (Name, CPUs & RAM)
    * Add command to manage VM's disks (add, delete, resize)
    * Add support for customization scripts
    * Guest customization: ensure VM is stopped or stop it
    * Add command to bootstrap single VMs
    * Add command to bootstrap every VM of a vApp
* CLI revisited
    * Almost every command accepts names in addition to IDs
* Various
    * Add command to show details about a given network
    * Add command to upload OVF

CHANGES:

* Renamed & enhanced command _vapp config network_ to _vapp network external_
* Several options have been revisited (see README.md for details)
* Sort VDC, Networks, vApps, Catalogs and Catalog Items by name

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

CHANGES:

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
