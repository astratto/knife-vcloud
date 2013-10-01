knife-vcloud [![Dependency Status](https://gemnasium.com/astratto/knife-vcloud.png)](https://gemnasium.com/astratto/knife-vcloud)
===========

DESCRIPTION
--
A knife plugin for the VMware® vCloud API.

It uses [vcloud-rest](https://github.com/astratto/vcloud-rest) to communicate with a VMware vCloud Director instance.

This code is BETA QUALITY.

INSTALLATION
--
This plugin is distributed as a Ruby Gem. To install it, run:

    gem install knife-vcloud

Depending on your system's configuration, you may need to run this command with root privileges.


FEATURES
--
- login/logout
- list/show Organizations
- show VDCs
- show Catalogs
- show Catalog Items
- create/start/stop/delete/show/reset/suspend/reboot vApps
- show VMs
- basic vApp network configuration
- basic VM network configuration
- basic VM Guest Customization configuration

PREREQUISITES
--
- chef >= 0.10.0
- knife-windows
- vcloud-rest

USAGE
--

###Available commands

    knife vc catalog item show [CATALOG_ID] (options)
    knife vc catalog show [CATALOG] (options)
    knife vc login (options)
    knife vc org list (options)
    knife vc org show [ORG] (options)
    knife vc vapp clone [VDC] [SOURCE_VAPP] [DEST_NAME] (options)
    knife vc vapp config network [VAPP_ID] [NETWORK_NAME] (options)
    knife vc vapp create [VDC] [NAME] [DESCRIPTION] [TEMPLATE_ID] (options)
    knife vc vapp delete [VAPP] (options)
    knife vc vapp reboot [VAPP_ID] (options)
    knife vc vapp reset [VAPP_ID] (options)
    knife vc vapp show VAPP (options)
    knife vc vapp start [VAPP_ID] (options)
    knife vc vapp stop [VAPP_ID] (options)
    knife vc vapp suspend [VAPP_ID] (options)
    knife vc vdc show VDC (options)
    knife vc vm config guest [VM_ID] [COMPUTER_NAME] (options)
    knife vc vm config network [VM_ID] [NETWORK_NAME] (options)
    knife vc vm set disks [VM_ID] [SIZE (in MB)] (options)
    knife vc vm set info [VM_ID] (options)
    knife vc vm show VM (options)

####Note about IDs and names
Most commands now accept both names and IDs.
For searches based on names, in general, _--org_ and _--vdc_ must be specified.

The examples in this document try to use names whenever is possible.
Keep in mind that ID-based search is still in place.

_Example:_

    $ knife vc vapp delete a3f81395-4eda-43b0-8677-b2d597014979
    Note: --org and --vdc not specified, assuming VAPP is an ID
    Do you really want to DELETE vApp TestAppN (ID: a3f81395-4eda-43b0-8677-b2d597014979)? (Y/N) Y
    ...

###Configuration
All commands accept the following options:

    --vcloud-url URL
    --vcloud-user USER
    --vcloud-password SECRET
    --vcloud-organization ORGANIZATION
    --vcloud-api-version API_VERSION

In addition, those options can be specified inside your _.chef/knife.rb_ file.

####Knife.rb configuration:

    knife[:vcloud_url] = 'https://vcloud.server.org'
    knife[:vcloud_org] = 'vcloud_organization'
    knife[:vcloud_user] = 'vcloud_user'
    knife[:vcloud_password] = 'vcloud_password'
    (OPTIONAL) knife[:vcloud_api_version] = '1.5'

###Login
This command can be used to verify that vCloud Director can be reached and credentials are correct.

_Example:_

    $ knife vc login
    Authenticated successfully, code: 9NkgOPh8tH6hPmujAvc99UBSyuqm713/23mFW1f7lJ0=

###List organizations
This command lists the available organizations.

_Example:_

    $ knife vc org list
    Name                    ID
    TEST-ORG                9f3ac2a8-92dd-4921-b48b-85b42f4d247c

###Show organization's details
This command shows details about a given organization.

_Example:_

    $ knife vc org show TEST-ORG
    CATALOGS
    Name                    ID
    Catalog_1               7414bc46-44fc-44ed-9844-0aa6ea9f5cf9
    Catalog_2               97a1e07f-7c1a-49fe-9cda-6ccfd4658ab7

    VDCs
    Name                    ID
    Test_vDC_1              440d5134-d2dd-4be7-8692-79a28c86f55b

    NETWORKS
    Name                    ID
    TestNet_1               35e5bed1-8475-4fd9-b495-ed1f062ca9c1
    TestNet_2               d56d8035-4b9e-454e-aa75-6ff450fb432d

    TASKLISTS
    Name                    ID
    <unnamed list>          9f3ac2a8-92dd-4921-b48b-85b42f4d247c

###Show catalog's details
This command shows details about a given catalog.

_Example:_

    $ knife vc catalog show Catalog_1 --org TEST-ORG
    Description: Test Catalog description
    Name                    ID
    CentOS 6.3              40e5e071-8231-46c1-92b7-fbe8f633e259
    ...

###Show catalog item's details
This command shows details about a given catalog item.
e.g., retrieve a template ID

_Example:_

    $ knife vc catalog item show 40e5e071-8231-46c1-92b7-fbe8f633e259
    Description: Linux CentOS 64 bit 6 update 3
    Name                    Template ID
    CentOS 6.3              edb5bb2f-58bc-4a44-aaf6-c244543e4a1b

###Show vDC's details
This command shows details about a given vDC.

_Example:_

    $ knife vc vdc show Test_vDC_1 --org TEST-ORG
    Description:
    vAPPS
    Name                    ID                                    Status    IP
    TestKnife (1 VMs)       09551b42-dca9-474d-aa50-201b223522db  running   10.102.46.237
    TestCENTOS (1 VMs)      4338a436-19fc-47b9-aaba-024841acfd66  stopped   10.102.46.23

###Startup vApp
This command starts up a given vApp.

_Example:_

    $ knife vc vapp start 4338a436-19fc-47b9-aaba-024841acfd66
    vApp startup...Done!
    Summary: Status: success - started at 2012-12-19T16:50:31.030+01:00 and ended at 2012-12-19T16:50:38.487+01:00

###Shutdown vApp
This command halts a given vApp.

_Example:_

    $ knife vc vapp stop 09551b42-dca9-474d-aa50-201b223522db
    vApp shutdown...Done!
    Summary: Status: success - started at 2012-12-19T16:56:31.100+01:00 and ended at 2012-12-19T16:56:38.667+01:00

###Delete vApp
This command deletes a given vApp.

_Example:_

    $ knife vc vapp delete clone2 --vdc vDC_Test --org Test  -VV
    Do you really want to DELETE vApp clone2 (ID: ddd059c3-8988-4fd6-b125-4eac049ca77c)?? (Y/N) Y
    vApp deletion...Done!
    Summary: Status: success - started at 2013-10-01T11:37:45.690+02:00 and ended at 2013-10-01T11:37:45.973+02:00

###Reboot vApp
This command reboots a given vApp.

_Example:_

    $ knife vc vapp reboot 4338a436-19fc-47b9-aaba-024841acfd66
    vApp reboot...Done!
    Summary: Status: success - started at 2013-07-19T16:50:31.030+01:00 and ended at 2013-07-19T16:50:38.487+01:00

###Suspend vApp
This command suspends a given vApp.

_Example:_

    $ knife vc vapp suspend 4338a436-19fc-47b9-aaba-024841acfd66
    vApp suspend...Done!
    Summary: Status: success - started at 2013-07-19T16:50:31.030+01:00 and ended at 2013-07-19T16:50:38.487+01:00

###Reset vApp
This command resets a given vApp.

_Example:_

    $ knife vc vapp reset 4338a436-19fc-47b9-aaba-024841acfd66
    vApp reset...Done!
    Summary: Status: success - started at 2013-07-19T16:50:31.030+01:00 and ended at 2013-07-19T16:50:38.487+01:00

###Create vApp from template
This command creates a vApp starting from a template (see catalog item).

_Example:_

    $ knife vc vapp create 440d5134-d2dd-4be7-8692-79a28c86f55b TestvApp "Test vApp description" 14b63ef2-fe93-4d0b-91f0-ccbd3847c665
    vApp creation...Done!
    Summary: Status: success - started at 2012-12-19T17:02:32.797+01:00 and ended at 2012-12-19T17:02:53.943+01:00
    vApp created with ID: 9cdd92ad-ab65-467f-abe1-075e35c050ec

###Show vApp's details
This command shows details about a given vApp.

_Example:_

    $ knife vc vapp show TEST_CENTOS --org TEST-ORG --vdc Test_vDC_1
    Name: TEST_CENTOS
    Status: running
    IP: 10.102.46.237
    Name                  Status         IPs             ID                                     Scoped ID
    CENTOS63              running        10.102.46.237   8b943bf9-a8ca-4d41-b97f-316c3aa891ea   3963994b-5a0a-48fe-b9ae-7f9a2d8e8e5b

###vApp's network configuration
This command allows for basic vApp network configuration.
E.g., retain IP address across deployments (defaults to POOL), set fence mode to _Isolated_ or _Bridge_

Please note that you must use the human readable name of the network (i.e., _TestNet\_1_).

_Example:_

    $ knife vc vapp config network 31a56cf6-088b-4a43-b726-d6370b4e7d0a TestNet_1

###Clone a vApp
This command clones an existing vApp.

_Example:_

    $ knife vc vapp clone vDC_Test clone_vAPP clone3 --org Test -VV
    Cloning vApp...Done!
    Summary: Status: success - started at 2013-09-30T18:14:36.740+02:00 and ended at 2013-09-30T18:14:42.857+02:00
    vApp cloned with ID: 587210aa-cf92-48e8-8f37-07e058c0116f

###Show VM's details
This command shows details about a given VM.

_Example:_

    $ knife vc vm show TestVM --vapp TEST_CENTOS --org TEST-ORG --vdc Test_vDC_1
    Cpu
    Number of Virtual CPUs  2 virtual CPU(s)

    Memory
    Memory Size             1024 MB of memory

    Disks
    Hard disk 1             16384 MB

    Networks

    Guest Customizations
    Enabled                 true
    Admin passwd enabled    false
    Admin passwd auto       false
    Admin passwd            xxxxxxxx
    Reset passwd required   false

###VM's network configuration
This command allows for basic VM network configuration.
E.g., set IP allocation mode (defaults to POOL)

Please note that you must use the human readable name of the network (i.e., _TestNet\_1_).

_Example:_

    $ knife vc vm config network 31a56cf6-088b-4a43-b726-d6370b4e7d0a TestNet_1
    VM network configuration...Done!
    Summary: Status: success - started at 2012-12-28T11:42:32.910+01:00 and ended at 2012-12-28T11:42:37.313+01:00

###VM's Guest Customization configuration
This command allows for basic VM Guest Customization configuration.

Please note that the vapp must be turned on.

_Example:_

    $ knife vc vm config guest c5f11906-561b-4ffd-850a-60a48c6a21e9 CENTOS63 --guest --admin-passwd "testpassword"
    VM guest configuration...Done!
    Summary: Status: success - started at 2012-12-28T11:42:32.910+01:00 and ended at 2012-12-28T11:42:37.313+01:00

LICENSE
--

Author:: Stefano Tortarolo <stefano.tortarolo@gmail.com>

Copyright:: Copyright (c) 2012-2013
License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

CREDITS
--
This code was inspired by [knife-cloudstack](https://github.com/CloudStack-extras/knife-cloudstack).
