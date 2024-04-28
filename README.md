# Container Image for The Works

![](logo.png)

## Overview

Provides a container image for running:

- Ansible
- HashiCorp Packer
- HashiCorp Terraform
- VMware Packer Plugin for vSphere

This image includes the following components:

| Component                        | Version | Description                                                                                              |
|----------------------------------|---------|----------------------------------------------------------------------------------------------------------|
| VMware Photon OS                 | 4.0     | A Linux container host optimized for vSphere and cloud-computing platforms.                              |
| Ansible                          | 2.12.7  | A suite of software tools that enables infrastructure as code.                                           |
| HashiCorp Packer                 | 1.8.6   | An open source image creation tool.                                                                      |
| HashiCorp Terraform              | 1.2.7   | An open-source infrastructure-as-code software  to create, change, and improve infrastructure.           |
| Packer Plugin for VMware vSphere | 1.1.1   | Packer Plugin that uses the vSphere API to creates virtual machines remotely, starting from an ISO file. |
| Helm                             | 3.11.2  | Package manager for Kubernetes                                                                           |

## Get Started

Run the following to download the latest container from Docker Hub:

```bash
docker pull harbor.sydeng.vmware.com/rcroft/theworks:latest
```

Run the following to download a specific version from Docker Hub:

```bash
docker pull harbor.sydeng.vmware.com/rcroft/theworks:x.y.z
```

Open an interactive terminal:

```bash
docker run --rm -it harbor.sydeng.vmware.com/rcroft/theworks bash
```

Run a local plan:

```bash
cd /path/to/files
docker run --rm -it --name theworks -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/theworks bash
docker run --rm -it --name theworks -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/theworks ansible --version 
docker run --rm -it --name theworks -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/theworks packer version
docker run --rm -it --name theworks -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/theworks powercli version
docker run --rm -it --name theworks -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/theworks powershell version
docker run --rm -it --name theworks -v $(pwd):/tmp -w /tmp harbor.sydeng.vmware.com/rcroft/theworks theworks version
```

Where `/path/to/files` is the local path for your scripts.

## Variables

### Harbor Variables

These can be set at any level but we generally set them at the group or project level.

| Variable        | Value                                                                           |
|-----------------|---------------------------------------------------------------------------------|
| HARBOR_HOST     | hostname of harbor instance, no `http://` or `https://`                         |
| HARBOR_CERT     | PEM format certificate with each `\n` (actual char) replaced with `"\n"` string |
|                 | Run the following command:                                                      |
|                 | `cat harbor.crt \| sed -E '$!s/$/\\n/' \| tr -d '\n'`                           |
|                 | where `harbor.crt`                                                              |
| HARBOR_USER     | Username of harbor user with permissions to push images                         |
| HARBOR_EMAIL    | Email  of harbor user with permissions to push images                           |
| HARBOR_PASSWORD | Password of harbor user with permissions to push images                         |

### GitLab Variables

| GitLab Env Var            | Value |
|---------------------------|-------|
| CI_COMMIT_AUTHOR          |       |
| CI_COMMIT_BRANCH          |       |
| CI_COMMIT_SHA             |       |
| CI_COMMIT_SHORT_SHA       |       |
| CI_COMMIT_TIMESTAMP       |       |
| CI_PAGES_DOMAIN           |       |
| CI_PAGES_URL              |       |
| CI_PIPELINE_CREATED_AT    |       |
| CI_PROJECT_DIR            |       |
| CI_PROJECT_NAME           |       |
| CI_PROJECT_NAMESPACE      |       |
| CI_PROJECT_PATH           |       |
| CI_PROJECT_PATH_SLUG      |       |
| CI_PROJECT_ROOT_NAMESPACE |       |
| CI_PROJECT_TITLE          |       |
| CI_PROJECT_URL            |       |
| CI_SERVER_HOST            |       |
| CI_SERVER_PORT            |       |
| CI_SERVER_PROTOCOL        |       |
| CI_SERVER_URL             |       |
| CI_TEMPLATE_REGISTRY_HOST |       |
| GITLAB_USER_EMAIL         |       |
| GITLAB_USER_LOGIN         |       |
| GITLAB_USER_NAME          |       |

## Package Versions

<!-- snip -->
| Package | Version |
|---------|---------|
| HELM | v3.14.4 |
| KUBECTX | v0.9.5 |
| KUBENS | v0.9.5 |
| CLUSTERCTL | 1.7.0 |
| PACKER | 1.10.2 |
| TERRAFORM | 1.8.0 |
| NOMAD | 1.7.7 |
| CONSUL | 1.18.1 |
| VAULT | 1.16.1 |
| TERRAFORMDOCS | 0.17.0 |
| LAZYGIT | 0.41.0 |
| LAZYDOCKER | 0.23.1 |
