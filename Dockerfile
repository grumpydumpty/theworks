FROM photon:4.0

# set argument defaults
ARG OS_ARCH="amd64"
ARG TERRAFORM_VERSION="1.2.7"
ARG PACKER_VERSION="1.8.6"
ARG VSPHERE_PLUGIN_VERSION="1.1.1"
ARG LABEL_PREFIX=com.vmware.eocto

# add metadata via labels
LABEL ${LABEL_PREFIX}.version="0.0.1"
LABEL ${LABEL_PREFIX}.git.repo="git@gitlab.eng.vmware.com:sydney/commonpool/containers/thework.git"
LABEL ${LABEL_PREFIX}.git.commit="DEADBEEF"
LABEL ${LABEL_PREFIX}.maintainer.name="Richard Croft"
LABEL ${LABEL_PREFIX}.maintainer.email="rcroft@vmware.com"
LABEL ${LABEL_PREFIX}.released="9999-99-99"
LABEL ${LABEL_PREFIX}.based-on="photon:4.0"
LABEL ${LABEL_PREFIX}.project="commonpool"

# set working to user's home directory
WORKDIR ${HOME}

# update repositories, install packages, and then clean up
RUN tdnf update -y && \
    tdnf install -y wget tar git ansible unzip && \
    wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    rm packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    tdnf erase -y unzip && \
    tdnf clean all

# set entrypoint to terraform, not a shell
ENTRYPOINT ["bash"]

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
