FROM photon:5.0

# set argument defaults
ARG OS_ARCH="amd64"
ARG HELM_VERSION="3.11.2"
ARG PACKER_VERSION="1.8.6"
ARG TERRAFORM_VERSION="1.4.5"
ARG VSPHERE_PLUGIN_VERSION="1.1.1"
ARG TANZU=10.109.195.161
#ARG LABEL_PREFIX=com.vmware.eocto

# add metadata via labels
#LABEL ${LABEL_PREFIX}.version="0.0.1"
#LABEL ${LABEL_PREFIX}.git.repo="git@gitlab.eng.vmware.com:sydney/commonpool/containers/thework.git"
#LABEL ${LABEL_PREFIX}.git.commit="DEADBEEF"
#LABEL ${LABEL_PREFIX}.maintainer.name="Richard Croft"
#LABEL ${LABEL_PREFIX}.maintainer.email="rcroft@vmware.com"
#LABEL ${LABEL_PREFIX}.maintainer.url="https://gitlab.eng.vmware.com/rcroft/"
#LABEL ${LABEL_PREFIX}.released="9999-99-99"
#LABEL ${LABEL_PREFIX}.based-on="photon:4.0"
#LABEL ${LABEL_PREFIX}.project="commonpool"

# set working to user's home directory
WORKDIR /root

# update repositories, install packages, and then clean up
RUN tdnf update -y && \
    # grab what we via stand packages
    tdnf install -y ansible cdrkit git wget openssh tar unzip && \
    # grab vsphere kubectl plugins
    curl -skSLo vsphere-plugin.zip https://${TANZU}/wcp/plugin/linux-${OS_ARCH}/vsphere-plugin.zip && \
    unzip -d /usr/local vsphere-plugin.zip && \
    rm -f vsphere-plugin.zip && \
    # grab helm
    curl -skSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${OS_ARCH}.tar.gz -o helm-v${HELM_VERSION}-linux-${OS_ARCH}.tar.gz && \
    tar xzf helm-v${HELM_VERSION}-linux-${OS_ARCH}.tar.gz linux-${OS_ARCH}/helm && \
    mv linux-${OS_ARCH}/helm /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/helm && \
    rm -rf helm-v${HELM_VERSION}-linux-${OS_ARCH}.tar.gz linux-${OS_ARCH} && \
    # grab kubectx/kubens
    curl -o kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens && \
    curl -o kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && \
    mv kubens kubectx /usr/local/bin && \
    chmod 0755 /usr/local/bin/kubectx && \
    chmod 0755 /usr/local/bin/kubens && \
    # grab packer/terraform
    wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    rm packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    # clean up
    tdnf erase -y unzip && \
    tdnf clean all

# set entrypoint to terraform, not a shell
ENTRYPOINT ["bash"]

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
