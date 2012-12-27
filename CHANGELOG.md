Changes
==
2012-12-27 (0.2.1)
--

FIXES:
* Change namespace to fix import error under 1.9.x (system-wide)

==
2012-12-24 (0.2.0)
--

FEATURES:
* Add command for basic VM Guest Customization configuration
* Add command for basic VM Network configuration
* Add command for basic vApp Network configuration

FIXES:
* Renamed _Common#msg_ to _Common#out\_msg_

==
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
