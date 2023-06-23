# Ansible GitOps Framework (AGOF)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Start Here

This repository is part of Red Hat's [Hybrid Cloud Patterns](https://hybrid-cloud-patterns.io) effort, which in general
aims to provide Reference Architectures that can be run through CI/CD systems.

The goal of this project in particular is to provide an extensible framework to do GitOps with Ansible Automation
Platform, and as such to provide useful facilities for developing Patterns (community and validated) that function with Ansible as the GitOps engine.

The thinking behind this effort is documented in the [Ansible Pattern Theory](https://github.com/mhjacks/ansible-pattern-theory) repository.

## How to Use It

### Installation

```shell
$ ./pattern.sh make install
```

### Uninstallation

```shell
$ ./pattern.sh make uninstall
```

## Acknowledgements

This repository represents an interpretation of GitOps principles, as developed in the Hybrid Cloud Patterns GitOps framework for Kubernetes, and an adaptation and fusion of two previous ongoing efforts at Red Hat: [Ansible-Workshops](https://github.com/ansible/workshops) and [LabBuilder2/RHISbuilder](https://github.com/parmstro/labbuilder2).

The AWS interactions come from Ansible Workshops (with some changes); the IDM and Satellite build components come from LabBuilder2/RHISbuilder. I would also like to specifically thank Mike Savage and Paul Armstrong, co-workers of mine at
Red Hat, who have provided encouragement and advice on how to proceed with various techniques in Ansible in particular.
