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

| Name                      | Description                          | Required | Optional | Default            |
| ------------------------- | ------------------------------------ | -------- | -------- | ------------------ |
| admin_user                | Admin User (for AAP and/or Hub)      |    x     | true     | 'admin'            |
| admin_password            | Admin Password (for AAP and/or Hub)  |    x     | false    |                    |
| aap_verison               | AAP Version to Use                   |          | true     | '2.3'              |
| offline_token             | Red Hat Offline Token                |    x     | false    |                    |
| redhat_username           | Red Hat Subscriber Username          |    x     | false    |                    |
| redhat_password           | Red Hat Subscriber Password          |    x     | false    |                    |
| redhat_registry_username_vault  | Red Hat Subscriber Username    |    x     | false    |              |
| redhat_registry_password_vault  | Red Hat Subscriber Password    |    x     | false    |              |
| manifest_content          | Base64 encoded Manifest to Entitle   |    x     | false    |                    |
| automation_hub_url_vault  | Subscriber-specific URL for Content  |    x     | false    |                    |
| automation_hub_token_vault| Subscriber-specific token for Content |    x     | false    |                    |
| init_env_collection_install | Whether to install collections required by the framework |  | true | true |
| init_env_collection_install_force | Whether to use the `force` argument when installing collections |  | true | false |
| controller_configs_dir    | Directory to pass to controller_configuration |    x     | false    |                    |
| automation_hub            | Flag to build an enable Automation Hub |        | true     | false              |

### Automation Hub Specific Configuration

| Name                      | Description                          | Required | Optional | Default            |
| ------------------------- | ------------------------------------ | -------- | -------- | ------------------ |
| aap_admin_username        | Admin User (for AAP)                 |          | true     | '{{ admin_user }}' |
| aap_admin_password        | Admin Password (for AAP)             |          | true     | '{{ admin_password }} ' |
| private_hub_username        | Admin User (for Automation Hub)    |          | true     | '{{ admin_user }}' |
| private_hub_password        | Admin Password (for Automation Hub) |          | true     | '{{ admin_password }} ' |
| custom_execution_environments | Array of Execution Environments to build on Hub |        | true     |  []     |

### AWS-Specific Configuration

| Name                      | Description                          | Required | Optional | Default            |
| ------------------------- | ------------------------------------ | -------- | -------- | ------------------ |
| aws_account_nbr_vault     | AWS Account Number                   |    x     | false    |                    |
| aws_access_key_vault      | AWS Access Key String                |    x     | false    |                    |
| aws_secret_key_vault      | AWS Secret Key String                |    x     | false    |                    |
| ec2_region                | EC2 region to use for builds         |    x     | false     |                   |
| ec2_name_prefix           | Text to add for EC2                  |    x     | false     |                   |
| pattern_dns_zone          | Zone to use for route53 updates      |    x     | false     |                   |
| build_idm                 | Flag to build an idm VM on AWS       |          | true     | false              |
| build_sat                 | Flag to build a Satellite VM on AWS  |          | true     | false              |

### ImageBuilder-Specific Configuration

| Name                      | Description                          | Required | Optional | Default            |
| ------------------------- | ------------------------------------ | -------- | -------- | ------------------ |
| org_number_vault          | Red Hat Subscriber Organization Number |         | true     |                   |
| activation_key_vault      | Activation Key Name to embed in image  |         | true     |                   |
| skip_imagebuilder_build   | Flag to skip imagebuilder build (also set `imagebuilder_ami` if true)  |         | true     |    false               |
| imagebuilder_ami   | AMI to use for VM creation in AWS  |         | true     |       |

## Acknowledgements

This repository represents an interpretation of GitOps principles, as developed in the Hybrid Cloud Patterns GitOps framework for Kubernetes, and an adaptation and fusion of two previous ongoing efforts at Red Hat: [Ansible-Workshops](https://github.com/ansible/workshops) and [LabBuilder2/RHISbuilder](https://github.com/parmstro/labbuilder2).

The AWS interactions come from Ansible Workshops (with some changes); the IDM and Satellite build components come from LabBuilder2/RHISbuilder. I would also like to specifically thank Mike Savage and Paul Armstrong, co-workers of mine at
Red Hat, who have provided encouragement and advice on how to proceed with various techniques in Ansible in particular.
