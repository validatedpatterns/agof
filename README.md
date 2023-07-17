# Ansible GitOps Framework (AGOF)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Start Here

This repository is part of Red Hat's [Hybrid Cloud Patterns](https://hybrid-cloud-patterns.io) effort, which in general
aims to provide Reference Architectures that can be run through CI/CD systems.

The goal of this project in particular is to provide an extensible framework to do GitOps with Ansible Automation
Platform, and as such to provide useful facilities for developing Patterns (community and validated) that function with Ansible Automation Platform as the GitOps engine.

The thinking behind this effort is documented in the [Ansible Pattern Theory](https://github.com/mhjacks/ansible-pattern-theory) repository.

## How to Use It

### Installation

```shell
$ ./pattern.sh make install
```

### Uninstallation

```shell
$ ./pattern.sh make aws_uninstall
```

## What this is

This is a framework for building Validated Patterns that use Ansible Automation Platform (AAP) as their underlying GitOps engine. To that end, the framework has three deployment models (in increasing level of complexity):

### "API" Install (aka "Bare")

```shell
$ ./pattern.sh make api_install
```

In this model, you provide an AAP endpoint. It does not need to be entitled, it just needs to be running the AAP Controller. You supply the manifest contents, endpoint hostname, admin username (defaults to "admin"), and admin password, and then the installation hands off to a `controller_config_dir` you define. This is provided for users who have their own AAP installations on bare metal or on-prem or do not want to run on AWS.

### "From OS" Install

```shell
$ ./pattern.sh make from_os_install INVENTORY=(your_inventory_file)
```

In this model, you provide an inventory file with up to two fresh RHEL installations. The model is tested with one AAP and one Hub instance. (Many other topologies are possible with the AAP installation framework; see the Ansible Automation Platform Planning and Installation guides for details.) If you need to install a pattern on a cluster with a different topology than this, use the API install mechanism. This mechanism will run a (slightly) opinionated install of the AAP and Hub components, and will add some conveniences like default execution environments and credentials. Like the "API" install, the install will then be handed over to a `controller_config_dir` you define.

The reason for making this a separate option is to make it easy for those who are not used to installing AAP to get up and running with it given a couple of VMs (or baremetal instances). Requirements for this mode are as follows:

* Must be running a version of RHEL that AAP supports
* Must be properly entitled with a subscription that makes the appropriate AAP repository available

It is not possible to test all possible scenarios in this mode, and we do not try.

Note that INVENTORY defaults to '~/inventory_agof' if you do not specify one.

Your inventory *must* define an `aap_controllers` group (which will be configured as the AAP node) and an `automation_hub` group which will be configured as the automation hub, if you want one.

Example `~/agof_inventory` (for just AAP, which is the default):

```ini
[build_control]
localhost

[aap_controllers]
192.168.5.207

[automation_hub]

[aap_controllers:vars]

[automation_hub:vars]

[all:vars]
ansible_user=myuser
ansible_ssh_pass=mypass
ansible_become_pass=mypass
ansible_remote_tmp=/tmp/.ansible
```

Example `~/agof_inventory` (including both AAP and Hub):

```ini
[build_control]
localhost

[aap_controllers]
192.168.5.207

[automation_hub]
192.168.5.209

[aap_controllers:vars]

[automation_hub:vars]

[all:vars]
ansible_user=myuser
ansible_ssh_pass=mypass
ansible_become_pass=mypass
ansible_remote_tmp=/tmp/.ansible
```

### Default Install

```shell
$ ./pattern.sh make install
```

In this model, you provide AWS credentials in addition to the other components needed in the "bare" install. The framework will build an AWS image using Red Hat's ImageBuilder, deploy that image onto a new AWS VPC and subnet, and deploy AAP on that image using the command line installer. It will then hand over the configuration of the AAP installation to the specified `controller_config_dir`.

### Convenience Features Install (defined by options in the "default" install)

```shell
$ ./pattern.sh make install
```

This model builds on the Default installation by adding the options for building extra VMs besides AAP - the configured VM options include Private Automation Hub (hub), Identity Management (idm), and Satellite (satellite). The framework will configure Automation Hub in this mode, and configure AAP to use it; it will not configure idm or satellite beyond what they need to be managed by AAP. (The configuration of idm and satellite is the subject of the first pattern to use this framework.)

The variables to include builds for the extra components are all Ansible booleans that can be included in your configuration:

`automation_hub`
`build_idm`
`build_sat`

## agof_vault.yml Configuration

### Common Configuration

| Name                      | Description                          | Required | Default  | Notes |
| ------------------------- | ------------------------------------ | -------- | -------- | ------ | 
| admin_user                | Admin User (for AAP and/or Hub)      | false     | 'admin' |        |
| admin_password            | Admin Password (for AAP and/or Hub)  | true    |           |        |
| aap_verison               | AAP Version to Use                   | true     | '2.3'    | Can also be '2.4' currently |
| redhat_username           | Red Hat Subscriber Username          | true    |           |        |
| redhat_password           | Red Hat Subscriber Password          | true    |           |        |
| redhat_registry_username_vault  | Red Hat Subscriber Username    | true    |           |  |
| redhat_registry_password_vault  | Red Hat Subscriber Password    | true    |           |  |
| manifest_content          | Base64 encoded Manifest to Entitle   | true    |           | Can be loaded directly from a file using a construct like this: `"{{ lookup('file', '~/Downloads/manifest.zip') | b64encode }}"` |
| automation_hub_url_vault  | Subscriber-specific URL for Content  | true    |  | This refers to the automation hub section on https://console.redhat.com.  It is the endpoint that is used to download Validated Content in addition to any public Galaxy content needed |
| automation_hub_token_vault| Subscriber-specific token for Content | true    |                    |
| automation_hub            | Flag to build an enable Automation Hub | false     | false |  | Building a Private Automation Hub is necessary if your pattern builds an Execution Environment that is not hosted on a public container registry. |
| controller_configs_dir    | Directory to pass to controller_configuration | true  |  | This directory is the key one to load all other AAP Controller configuration. The framework is not opinionated about how the directory gets there - you may wish to generate it yourself or check it out from a git repo |
| controller_launch_jobs    | List of jobs to run after controller_configuration has run | false     |  | Use this to start a job (or jobs) that do not have aggressive schedules, and that are ready to run as soon as the controller is configured. The fewer jobs listed here the better. |

### Initialization Environment Configuration

| Name                      | Description                          | Required | Default  | Notes |
| ------------------------- | ------------------------------------ | -------- | -------- | ------------------ |
| init_env_collection_install | Whether to install collections required by the framework | false | true |  |
| init_env_collection_install_force | Whether to use the `force` argument when installing collections | false | false | Forces the installation of declared dependencies if true |
| special_collection_installs | "Bundled" collection installations (references files in repodir) | false | `[]` | A mechanism to allow the installation of collections bundled into the pattern, if the ones published in galaxy and/or Automation Hub are not sufficient |
| offline_token             | Red Hat Offline Token                | false    |          | Used to build the imagebuilder image |

### Automation Hub Specific Configuration

| Name                      | Description                          | Required | Default            | Notes |
| ------------------------- | ------------------------------------ | -------- | ------------------ | ------ | 
| aap_admin_username        | Admin User (for AAP)                 | false    | '{{ admin_user }}' | | 
| aap_admin_password        | Admin Password (for AAP)             | true     | '{{ admin_password }} ' | |
| private_hub_username        | Admin User (for Automation Hub)    | true     | '{{ admin_user }}' | | 
| private_hub_password        | Admin Password (for Automation Hub) |true     | '{{ admin_password }} ' | | 
| custom_execution_environments | Array of Execution Environments to build on Hub | true     |  `[]`  | The execution environments will be built on the hub node, and then pushed into the hub registry from there. |

### AWS-Specific Configuration

| Name                      | Description                          | Required | Default            | Notes  |
| ------------------------- | ------------------------------------ | -------- | ------------------ | ------ |
| aws_account_nbr_vault     | AWS Account Number                   | false    |                    |  |
| aws_access_key_vault      | AWS Access Key String                | false    |                    |  |
| aws_secret_key_vault      | AWS Secret Key String                | false    |                    | |
| ec2_region                | EC2 region to use for builds         | false    |                   | |
| ec2_name_prefix           | Text to add for EC2                  | false    |                   | This is a name to disambiguate your pattern from anything else that might be running in your AWS account. A VPC, subnet, and security group is built from this, and the prefix is added to the `pattern_dns_zone` by default. Additionally, the SSH private key is stored locally in `~/{{ ec2_name_prefix }}`. |
| pattern_dns_zone          | Zone to use for route53 updates      | false    |                   | |
| build_idm                 | Flag to build an idm VM on AWS       | false    | false             | This is a flag to indicate whether to build a VM called `idm` on AWS, for later installation of the idm software. Note that the framework just instantiates the VM, it does not install the IDM software. |
| build_sat                 | Flag to build a Satellite VM on AWS  | false    | false             | This is a flag to indicate whether to install a Satellite VM on AWS, for later installation of the Satellite software. The framework does not include the Ansible code to install Satellite itself. |

### ImageBuilder-Specific Configuration

*Note:* If you are providing an AMI via the `imagebuilder_ami` variable as opposed to building one from console.redhat.com for the pattern, the pattern still assumes that the RHEL instance will be entitled and will be running a suitable version of RHEL.

| Name                      | Description                          | Required | Default            | Notes |
| ------------------------- | ------------------------------------ | -------- | ------------------ | ------- |
| org_number_vault          | Red Hat Subscriber Organization Number | true  |  | This is the organization number associated with the RHEL instances you need to entitle |
| activation_key_vault      | Activation Key Name to embed in image  | true  |                    | This is an activation key for the Red Hat CDN. It is expected to be able to enable both the base RHEL repos and the AAP repos. |
| skip_imagebuilder_build   | Flag to skip imagebuilder build (also set `imagebuilder_ami` if true) |  false | false     | |
| imagebuilder_ami   | AMI to use for VM creation in AWS  | false             | | It is very possible to re-use another imagebuilder build from a previous installation of the pattern framework, and saves ~15 minutes on a new pattern install to re-use such an image. |

## What the Framework Does, Step-by-Step

### Pre-GitOps Steps

#### [Pre-init](init_env/pre_init_env.yml) (mandatory)

Pre-initialization, for our purposes, refers to things that have to be installed on the installation workstation/provisioner node to set up the Ansible environment to deploy the rest of the pattern.

##### Build ansible.cfg

Because ansible.cfg needs to be built with your automation hub token inside it, we generate it from a template. The ansible.cfg includes your token, endpoints for both public and Automation Hub galaxy servers, and a vault password path (for `ansible-vault`). The template used is [here](init_env/templates/ansible.cfg.j2).

##### Collection dependency install

The next thing the pre-init play does is install dependency collections based on what's contained in [requirements.yml](requirements.yml). If there are any "special" collections contained in the root of the framework they can also be installed at this time. When the framework was under development this was necessary with redhat.satellite but the necessary changes have been upstreamed as of 3.11; 3.12 has been released since then, so this mechanism is no longer needed but is left in as it might be necessary in the future.

#### [Environment Initialization](init_env/main.yml) (optional; enabled by default)

Environment initialization includes the steps necessary to build the environment (VMs) to install AAP and related tooling; currently the framework can do this on AWS. This step is optional if you wish to provide either an AAP controller API endpoint OR else bring your own inventory/VMs to install AAP Controller and (optionally) Automation Hub on.

##### [image build (optional)](buildimage/main.yml)

This play builds an image using the Red Hat Console's imagebuilder service; the end result of this process is an image that will serve as an AMI in AWS. (ImageBuilder can build other types of images as well.) The key aspects of this image are that they include the cloud-init package (which helps with certain aspects of initialization), but more importantly, they include the organization number and activation key so that images that are instantiated with this AMI are automatically registered and enabled to install content via the Red Hat CDN.

These images tend to be fairly static, so it is not necessary to build a brand new image every time you run the pattern. You can save the AMI from a previous pattern run, and re-use it as long as you like. Building and uploading the image to AWS represents about 15 minutes of the runtime of the pattern installation.

##### [Initialize the Environment (for AWS)](init_env/aws/main.yml)

This play handles all the AWS-specific setup necessary to run AAP, (optionally) Automation Hub, (optionally) IdM, (optionally) Satellite, and also offers you the ability to install VMs of your own for a pattern via overrides. The reason for this is that installing the VMs at this stage allows the customer/user to not have to involve AWS credentials in the pattern itself if they do not wish to do so. Of course they are free to include workflows that interact with AWS or other infrastructure if they want - this was done with the intention of simplifying that process if AWS was an implementation detail of the pattern as opposed to the intention of it.

The two key roles that are invoked here are [manage_ec2_infra](init_env/aws/roles/manage_ec2_infra/) and [manage_ec2_instances](init_env/aws/roles/manage_ec2_instances/). Both of these have been adapted from [ansible-workshops](https://github.com/ansible/workshops). The `manage_ec2_infra` role is responsible for setting up the VPC, subnet, and security group for the patten. `manage_ec2_instances` is responsible for actually building the VM instances. It will also manage route53 DNS entries. It is safe to run these roles repeatedly; they will not "double allocate" VMs as long as the VMs are running.

##### [Update Route53 DNS (if needed))](init_env/aws/fix_aws_dns.yml)

The standard public IPs that are offered by AWS (which are used by this framework) are not permanently associated with the VMs. When the VMs cold start, in particular, we can expect IP change events. The VMs themselves are not directly aware of their external IPs. In order to handle this situation, this play can be run from the provisioner node/workstation to update the route53 DNS mappings based on the AWS API.

##### [Teardown AWS Environment)](init_env/aws/teardown.yml) (`make aws_uninstall`)

The teardown play will terminate all VMs associated with a VPC and subnet, and remove the DNS entries managed by the "bootstrap set".

#### Host Initialization

##### AAP Installation (mandatory)
##### Private Automation Hub Installation (optional)


##### AAP Configuration

###### Entitle Controller

###### Configure Controller

###### Run "immediate" jobs

### GitOps Step

The framework is only truly in GitOps mode once the configuration has been fully applied to the AAP controller and the AAP controller has taken responsibility for managing the environment. Prior to that point, there are many opportunities (by design) to inject non-declarative elements into the environment. Beyond that point, changes should be made to the environment or the workflows that configure it by pushing git commits to the repositories the pattern uses.

## Acknowledgements

This repository represents an interpretation of GitOps principles, as developed in the Hybrid Cloud Patterns GitOps framework for Kubernetes, and an adaptation and fusion of two previous ongoing efforts at Red Hat: [Ansible-Workshops](https://github.com/ansible/workshops) and [LabBuilder2/RHISbuilder](https://github.com/parmstro/labbuilder2).

The AWS interactions come from Ansible Workshops (with some changes); the IDM and Satellite build components come from LabBuilder2/RHISbuilder. I would also like to specifically thank Mike Savage and Paul Armstrong, co-workers of mine at
Red Hat, who have provided encouragement and advice on how to proceed with various techniques in Ansible in particular.
