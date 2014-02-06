knife-vcloud [![Dependency Status](https://gemnasium.com/astratto/knife-vcloud.png)](https://gemnasium.com/astratto/knife-vcloud)
===========

DESCRIPTION
--
A knife plugin for the VMware® vCloud API.

It uses [vcloud-rest](https://github.com/astratto/vcloud-rest) to communicate with a VMware vCloud Director instance.

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
- create/start/stop/delete/show/reset/suspend/reboot vApps and VMs
- add/edit/delete vApp networks (both internal and external)
- basic VM network configuration
- basic VM Guest Customization configuration
- OVF upload

PREREQUISITES
--
- chef >= 0.10.0
- knife-windows
- vcloud-rest ~> 1.2.0

USAGE
--

###Available commands

    knife vc catalog item show [CATALOG_ITEM] (options)
    knife vc catalog show [CATALOG] (options)
    knife vc configure (options)
    knife vc login (options)
    knife vc network show [network] (options)
    knife vc org list (options)
    knife vc org show (options)
    knife vc ovf upload VDC CATALOG VAPP_NAME VAPP_DESCRIPTION OVF_FILENAME (options)
    knife vc vapp bootstrap [VAPP] (options)
    knife vc vapp clone [VDC] [SOURCE_VAPP] [DEST_NAME] (options)
    knife vc vapp create [VDC] [NAME] [DESCRIPTION] [TEMPLATE_ID] (options)
    knife vc vapp delete [VAPP] (options)
    knife vc vapp network external [add|delete|edit| [VAPP] [NETWORK] (options)
    knife vc vapp network internal [add|delete|edit| [VAPP] [NETWORK] (options)
    knife vc vapp reboot [VAPP] (options)
    knife vc vapp reset [VAPP] (options)
    knife vc vapp show VAPP (options)
    knife vc vapp snapshot [create|revert] [VAPP] (options)
    knife vc vapp start [VAPP] (options)
    knife vc vapp stop [VAPP] (options)
    knife vc vapp suspend [VAPP] (options)
    knife vc vdc show VDC (options)
    knife vc vm bootstrap [VM] (options)
    knife vc vm config guest [VM] (options)
    knife vc vm network [add|delete|edit| [VM] [NETWORK] (options)
    knife vc vm reboot [VM] (options)
    knife vc vm reset [VM] (options)
    knife vc vm set disks [VM] (options)
    knife vc vm set info [VM] (options)
    knife vc vm show VM (options)
    knife vc vm start [VM] (options)
    knife vc vm stop [VM] (options)
    knife vc vm suspend [VM] (options)

###Configuration

A first configuration should be done using ```knife vc configure``` that would prompt user for
credentials and vCloud URL.

E.g.,

    $ bundle exec knife vc configure
    Loading existing pem
    vCloud URL (https://mycloud.test.com):
    vCloud username (testuser):
    ...

Other configuration options can be set either via arguments or inside the *.chef/knife.rb* file.
The only difference is that in *knife.rb* dashes must be converted to underscores
and *vcloud_* must be prepended.

E.g., ```$ ... --org-login XXX``` becomes ```knife[:vcloud_org_login] = 'XXX'``` in *knife.rb*.


#### Common options

The following options specify, respectively, the url of the vCloud instance and the API version
to use:

    --url URL
    --api-version API_VERSION

#### Login Configuration

The following options specify user's credentials and thus are accepted by every command:

    --user-login USER
    --org-login ORGANIZATION

**Knife.rb configuration example:**

    knife[:vcloud_url] = 'https://vcloud.server.org'
    knife[:vcloud_org_login] = 'vcloud_organization'
    knife[:vcloud_user_login] = 'vcloud_user'
    knife[:vcloud_password] = <MUST BE GENERATED WITH knife vc configure>
    (OPTIONAL) knife[:vcloud_api_version] = '1.5'

####IDs and names
Most commands accept both names and IDs.
For searches based on names, in general, at least _--vdc_ must be specified.

The examples in this document try to use names whenever is possible.
Keep in mind that ID-based search is still in place but will be dropped in future releases.

_Example:_

    $ knife vc vapp delete a3f81395-4eda-43b0-8677-b2d597014979
    Note: --vdc not specified, assuming VAPP is an ID
    Do you really want to DELETE vApp TestAppN (ID: a3f81395-4eda-43b0-8677-b2d597014979)? (Y/N) Y
    ...

**TIP:**
    Default --vdc and --vapp can be set in _knife.rb_.  
    For the sake of simplicity, the following examples assume that --vdc
    is configured in _knife.rb_.

_Example:_

    ...
    knife[:vcloud_vdc] = "vDC_Test"
    knife[:vcloud_vapp] = "Test"
    ...

#### Browse multiple organizations

Using a vCloud System Administrator account is possible to browse several organizations and thus *--org* can be used to specify different organizations.  

Only *--org-login* is valid for other users.
If *--org* is used by those users, a warning is shown:

    WARNING: --org option is available only for vCloud System Administrators. Using --org-login ('test')

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

    $ knife vc catalog show Catalog_1
    Description: Test Catalog description
    Name                    ID
    CentOS 6.3              40e5e071-8231-46c1-92b7-fbe8f633e259
    ...

###Show catalog item's details
This command shows details about a given catalog item.
e.g., retrieve a template ID

_Example:_

    $ knife vc catalog item show CentOS 6.3 --catalog Catalog_1
    Description: Linux CentOS 64 bit 6 update 3
    Name                    Template ID
    CentOS 6.3              edb5bb2f-58bc-4a44-aaf6-c244543e4a1b

###Show vDC's details
This command shows details about a given vDC.

_Example:_

    $ knife vc vdc show Test_vDC_1
    Description:
    vAPPS
    Name                    ID                                    Status    IP
    TestKnife (1 VMs)       09551b42-dca9-474d-aa50-201b223522db  running   10.102.46.237
    TestCENTOS (1 VMs)      4338a436-19fc-47b9-aaba-024841acfd66  stopped   10.102.46.23

###Manage vApp/VM status
vApp/VM's status can be managed with _start/stop/reboot/reset/suspend/delete_

Note: use _knife vc vm..._ to operate on VMs.

_Example:_

    $ knife vc vapp start clone3
    vApp startup...
    Summary: Status: success - time elapsed: 2.967 seconds


###Create vApp from template
This command creates a vApp starting from a template (see catalog item).

_Example:_

    $ knife vc vapp create vDC_Test clone4 "Create example" 89e33fd7-04a7-4b5f-830b-2423c41089e3
    vApp creation...
    Summary: Status: success - time elapsed: 28.967 seconds
    vApp created with ID: 9cdd92ad-ab65-467f-abe1-075e35c050ec

###Show vApp's details
This command shows details about a given vApp.

_Example:_

    $ knife vc vapp show TEST_CENTOS
    Name: TEST_CENTOS
    Status: running
    Networks
    TST_Data
       Gateway     Netmask        Fence Mode  Parent Network  Retain Info
       10.22.4.1   255.255.254.0  bridged     TST_Data        false
    TST_FE
       Gateway       Netmask          Fence Mode  Parent Network  Retain Info
       10.22.3.129   255.255.255.128  bridged     TST_FE          false
    VMs
    Name      Status   IPs  ID                                    Scoped ID
    CENTOS63  stopped       83f6aeb3-f624-4a79-9e6b-23e162893daf  69b0fe46-224f-4266-a424-2fe16ca99ff7

###vApp's network configuration

#### External networks
External vApp networks (from vDC) can be added, removed and modified using the _vapp network external_ command.

_Add example:_

    $ knife vc vapp network external add test_vapp4 TST_DATA
    Forcing parent network to itself
    Adding TST_Data to vApp...
    Summary: Status: success - time elapsed: 2.72 seconds

_Edit example:_

    TBD

_Delete example:_

    $ knife vc vapp network external delete test_vapp4 TST_Data
    Removing TST_Data from vApp...
    Summary: Status: success - time elapsed: 2.63 seconds

#### Internal networks
Internal vApp networks can be added, removed and modified using the _vapp network internal_ command.

_Add example:_

    $ knife vc vapp network internal add test_vapp4 INT_NET
      Gateway: 192.168.0.1
      Netmask: 255.255.255.0
      Dns1: 190.23.12.34
      Dns2: 21.33.24.21
      Dns suffix: test.suffix.local
      Start address: 192.168.0.10
      End address: 192.168.0.100
    Adding INT_NET to vApp...
    Summary: Status: success - time elapsed: 6.88 seconds

    # Note that options can also be specified on the command line
    $ knife vc vapp network internal add test_vapp4 INT_NET --gateway "192.168.0.1"...

_Edit example:_

    ## Add a parent network to this internal network
    # Note that FenceMode is automatically set to natRouted

    ## PRE-edit
    ...
    Networks
    INT_NET
       Gateway      Netmask        Fence Mode  Parent Network  Retain Network
       192.168.0.1  255.255.255.0  isolated    TST_FE          true
    TST_FE
       Gateway       Netmask          Fence Mode  Parent Network  Retain Network
       10.202.3.129  255.255.255.128  bridged     TST_FE          false
    ...

    $ knife vc vapp network internal edit test_vapp4 INT_NET --parent-network TST_FE
    Retrieving parent network details
    Setting a parent network for an internal network requires fence mode natRouted. Fixing it...
    vApp network configuration for INT_NET...
    Summary: Status: success - time elapsed: 5.324 seconds

    ## POST-edit
    ...
    Networks
    INT_NET
       Gateway      Netmask        Fence Mode  Parent Network  Retain Network
       192.168.0.1  255.255.255.0  natRouted   TST_FE          true
    TST_FE
       Gateway       Netmask          Fence Mode  Parent Network  Retain Network
       10.202.3.129  255.255.255.128  bridged     TST_FE          false
    ...

_Delete example:_

    $ knife vc vapp network internal delete test_vapp4 INT_NET
    Removing INT_NET from vApp...
    Summary: Status: success - time elapsed: 5.05 seconds

###Clone a vApp
This command clones an existing vApp.

_Example:_

    $ knife vc vapp clone vDC_Test clone_vAPP clone3
    Cloning vApp...
    Summary: Status: success - time elapsed: 24.69 seconds
    vApp cloned with ID: 587210aa-cf92-48e8-8f37-07e058c0116f

###Show VM's details
This command shows details about a given VM.

_Example:_

    $ knife vc vm show TestVM --vapp TEST_CENTOS
    VM Name: centos64-x64-s
    OS Name: CentOS 4/5/6 (64-bit)
    Status: running

    Cpu
    Number of Virtual CPUs  2 virtual CPU(s)

    Memory
    Memory Size             1024 MB of memory

    Disks
    Hard disk 1             16384 MB

    Networks
    TST_FE
    Index                   0
    Ip                      10.202.3.251
    External ip
    Is connected            true
    Mac address             00:50:21:02:01:27
    Ip allocation mode      POOL

    Guest Customizations
    Enabled                 true
    Admin passwd enabled    false
    Admin passwd auto       false
    Admin passwd            xxxxxxxx
    Reset passwd required   false
    Computer name           centos64-x64-s

###Set VM's CPUs / Memory / Name
This command sets name, CPUs and RAM info for a given VM.

Renaming a VM implies renaming its guest name.
Use ```--no-override-guest-name``` if you want to preserve the old name.

_Example:_

    $ knife vc vm set info --name NewName --vapp vApp_test vm-test
    Renaming VM from vm-test to NewName
    Summary: Status: success - time elapsed: 7.66 seconds

    $ knife vc vm set info --ram 512 --vapp vApp_test vm-test
    VM setting RAM info...
    Summary: Status: success - time elapsed: 7.69 seconds

    $ knife vc vm set info --cpu 2 --vapp vApp_test vm-test
    VM setting CPUs info...
    Summary: Status: success - time elapsed: 5.19 seconds

###Set VM's disks
This command manages disks for a given VM.

_Example:_

    # Create a new disk
    $ knife vc vm set disks --add --disk-size 3000 --vapp vApp_test vm-test
    VM setting Disks info...
    Summary: Status: success - time elapsed: 6.12 seconds

    # Resize an existing disk (note that disk size can only be increased)
    $ knife vc vm set disks --disk-name "Hard disk 2" --disk-size 3500 --vapp vApp_test vm-test
    VM setting Disks info...
    Summary: Status: success - time elapsed: 6.69 seconds

    # Delete an existing disk
    $ knife vc vm set disks --disk-name "Hard disk 2" --delete --vapp vApp_test vm-test
    Do you really want to DELETE disk Hard disk 2? (Y/N) Y
    VM setting Disks info...
    Summary: Status: success - time elapsed: 7.21 seconds

###VM's network configuration
VM networks can be added, removed and modified using the *vm network* command.
This commands allows for basic VM network configuration and accepts several options to configure a given network (see *knife vc vm network --help* for details).

Please note that you must use the human readable name of the network (i.e., _TestNet\_1_).

_Add example:_

    $ knife vc vm network edit testvm TST_Data
    Forcing parent network to itself
    VM network configuration...
    Guest customizations must be applied to a stopped VM, but it's running. Can I STOP it? (Y/N) y
    Stopping VM...
    Summary: Status: success - time elapsed: 1.617 seconds
    Adding TST_Data to VM...
    Summary: Status: success - time elapsed: 5.866 seconds
    Forcing Guest Customization to apply changes...
    Summary: Status: success - time elapsed: 13.387 seconds

_Edit example:_

    $ knife vc vm network edit testvm TST_Data --ip-allocation-mode DHCP
    Forcing parent network to itself
    VM network configuration...
    Guest customizations must be applied to a stopped VM, but it's running. Can I STOP it? (Y/N) y
    Stopping VM...
    Summary: Status: success - time elapsed: 5.34 seconds
    VM network configuration for TST_Data...
    Summary: Status: success - time elapsed: 3.397 seconds
    Forcing Guest Customization to apply changes...
    Summary: Status: success - time elapsed: 8.01 seconds

_Delete example:_

    $ knife vc vm network delete test_vm TST_Data
    VM network configuration...
    Guest customizations must be applied to a stopped VM, but it's running. Can I STOP it? (Y/N) y
    Stopping VM...
    Summary: Status: success - time elapsed: 4.77 seconds
    Removing TST_Data from VM...
    Summary: Status: success - time elapsed: 3.614 seconds
    Forcing Guest Customization to apply changes...
    Summary: Status: success - time elapsed: 11.194 seconds

###VM's Guest Customization configuration
This command allows for basic VM Guest Customization configuration.
By default it forces a guest customization, use _--no-force_ to disable it.

Please note that the vapp must be turned off.

There are several options that can be specified.

i.e.,

* admin-passwd: change guest admin password
* script: load a given file and use it as guest customization script
* guest-computer-name: change guest name

_Example:_

    $ knife vc vm config guest test_vm --vapp test_vapp1 --script guest_script.txt
    VM guest configuration...
    Summary: Status: success - time elapsed: 5.23 seconds
    Forcing Guest Customization...
    Summary: Status: success - time elapsed: 2.567 seconds

It's also possible to upload a customization script using _script_:

    $ knife vc vm config guest ... --script script_filename.txt

### Bootstrap
It's possible to bootstrap single VMs or every VM of a vApp.

_Example:_

    # Bootstrap every VM belonging to test_vapp
    $ knife vc vapp bootstrap test_vapp
    Bootstrap VM: SMALL_CentOS6.4-x86_64...
    Trying to reach xxxx (try 1/5)
        xxxx:22 replied with: SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1
    Bootstrap IP: xxxx
    Bootstrapping Chef on xxxx
    xxxx Starting Chef Client, version 11.6.2
    ...

    # Bootstrap a single VM
    $ knife vc vm bootstrap SMALL_CentOS6.4-x86_64 --vapp test_vapp
    Bootstrap VM: SMALL_CentOS6.4-x86_64...
    Trying to reach xxxx (try 1/5)
        xxxx:22 replied with: SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1
    Bootstrap IP: xxxx
    Bootstrapping Chef on xxxx
    xxxx Starting Chef Client, version 11.6.2
    ...

Since a VM may have several addresses, these commands loop over them until they
find a reachable one.

_Example:_

    $ knife vc vapp bootstrap test_vapp
    Bootstrap VM: SMALL_CentOS6.4-x86_64...
    Trying to reach 192.168.0.102 (try 1/5)
        Unable to reach 192.168.0.102:22 => Connection refused - connect(2)
    ...
    Trying to reach xxxx (try 1/5)
        xxxx:22 replied with: SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1
    Bootstrap IP: xxxx
    Bootstrapping Chef on xxxx
    xxxx Starting Chef Client, version 11.6.2
    ...

### OVF Upload
Upload a given OVF.

    $ knife vc ovf upload VDC Catalog TemplateName "Example ovf upload" centos64.ovf
    Uploading OVF...
    Time: 00:03:12 <=========> 100% Uploading: ../vm-d384582f-2457-477c-ad9b-6228740ca762-disk-0.vmdk
    Time: 00:00:32 <=========> 100% Uploading: ../vm-d384582f-2457-477c-ad9b-6228740ca762-disk-1.vmdk
    OVF uploaded. vAppTemplate created with ID: b1e58873-8227-4168-add3-87554d2043db

DEBUGGING
--

The underlying library *vcloud-rest* can be configured to print debug information.
Debug can be enabled setting the following environment variables:

* *VCLOUD_REST_DEBUG_LEVEL*: to specify the log level (e.g., INFO)
* *VCLOUD_REST_LOG_FILE*: to specify the output file (defaults to STDOUT)


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
