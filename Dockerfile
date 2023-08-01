FROM photon:5.0

# set argument defaults
ARG OS_ARCH="amd64"
ARG OS_ARCH2="x86_64"
ARG K9S_VERSION="0.27.4"
ARG LAZYGIT_VERSION="0.39.4"
ARG LAZYDOCKER_VERSION="0.21.0"
ARG HELM_VERSION="3.11.2"
ARG PACKER_VERSION="1.8.6"
ARG TERRAFORM_VERSION="1.4.5"
ARG VSPHERE_PLUGIN_VERSION="1.1.1"
ARG TANZU=10.109.195.161
ARG USER=vlabs
ARG USER_ID=1000
ARG GROUP=users
ARG GROUP_ID=100
#ARG LABEL_PREFIX=com.vmware.eocto

# add metadata via labels
# LABEL ${LABEL_PREFIX}.version="0.0.1"
# LABEL ${LABEL_PREFIX}.git.repo="git@gitlab.eng.vmware.com:sydney/commonpool/containers/thework.git"
# LABEL ${LABEL_PREFIX}.git.commit="DEADBEEF"
# LABEL ${LABEL_PREFIX}.maintainer.name="Richard Croft"
# LABEL ${LABEL_PREFIX}.maintainer.email="rcroft@vmware.com"
# LABEL ${LABEL_PREFIX}.maintainer.url="https://gitlab.eng.vmware.com/rcroft/"
# LABEL ${LABEL_PREFIX}.released="9999-99-99"
# LABEL ${LABEL_PREFIX}.based-on="photon:5.0"
# LABEL ${LABEL_PREFIX}.project="containers"

# update repositories
RUN tdnf update -y && \
    tdnf install -y glibc-i18n && \
    tdnf clean all && \
    locale-gen.sh

ENV LOCALE=en_US.utf-8
ENV LC_ALL=en_US.utf-8

# update repositories, install packages, and then clean up
RUN tdnf update -y && \
    # grab what we can via standard packages
    tdnf install -y ansible bash ca-certificates cdrkit curl diffutils gawk git htop mc nodejs openssh python3 python3-jinja2 python3-paramiko python3-pip python3-pyyaml python3-resolvelib python3-xml shadow tar tmux unzip && \
    # add user/group
    useradd -u ${USER_ID} -m ${USER} && \
    chown -R ${USER_ID}:${GROUP_ID} /home/${USER} && \
    # add /workspace and give user permissions
    mkdir -p /workspace && \
    chown -R ${USER_ID}:${GROUP_ID} /workspace && \
    # set git config
    #git config --global --add safe.directory /workspace && \
    echo -e "[safe]\n\tdirectory=/workspace" > /etc/gitconfig && \
    # grab kubectl vsphere plugins
    curl -skSLo vsphere-plugin.zip https://${TANZU}/wcp/plugin/linux-${OS_ARCH}/vsphere-plugin.zip && \
    unzip -d /usr/local vsphere-plugin.zip && \
    rm -f vsphere-plugin.zip && \
    # grab helm
    curl -skSLo helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-${OS_ARCH}.tar.gz && \
    tar xzf helm.tar.gz linux-${OS_ARCH}/helm && \
    mv linux-${OS_ARCH}/helm /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/helm && \
    rm -rf helm.tar.gz linux-${OS_ARCH} && \
    # grab kubectx
    curl -skSLo kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && \
    mv kubectx /usr/local/bin && \
    chmod 0755 /usr/local/bin/kubectx && \
    # grab kubens
    curl -skSLo kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens && \
    mv kubens /usr/local/bin && \
    chmod 0755 /usr/local/bin/kubens && \
    # grab packer
    curl -skSLo packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ packer.zip && \
    rm -f packer.zip && \
    # grab terraform
    curl -skSLo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ terraform.zip && \
    rm -f terraform.zip && \
    # grab k9s
    curl -skSLo k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${OS_ARCH}.tar.gz && \
    tar xzf k9s.tar.gz k9s && \
    mv k9s /usr/local/bin && \
    chmod 0755 /usr/local/bin/k9s && \
    rm -f k9s.tar.gz && \
    # grab lazygit
    curl -skSLo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_${OS_ARCH2}.tar.gz && \
    tar xzf lazygit.tar.gz lazygit && \
    mv lazygit /usr/local/bin && \
    chmod 0755 /usr/local/bin/lazygit && \
    rm -f lazygit.tar.gz && \
    # grab lazydocker
    curl -skSLo lazydocker.tar.gz https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_linux_${OS_ARCH2}.tar.gz && \
    tar xzf lazydocker.tar.gz lazydocker && \
    mv lazydocker /usr/local/bin && \
    chmod 0755 /usr/local/bin/lazydocker && \
    rm -f lazydocker.tar.gz && \
    # clean up
    tdnf erase -y unzip shadow && \
    tdnf clean all

# set user
USER ${USER}

# set working directory
WORKDIR /workspace

# set entrypoint to a shell
ENTRYPOINT ["bash"]

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
