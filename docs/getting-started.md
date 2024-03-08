---
title: Getting Started Guide
draft: false
date: 2022-01-31
authors:
  - grumpydumpty
---

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
