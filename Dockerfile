FROM photon:5.0

# set argument defaults
ARG OS_ARCH="amd64"
ARG OS_ARCH2="x86_64"
ARG TANZU=10.109.195.161
ARG USER=vlabs
ARG USER_ID=1000
ARG GROUP=users
ARG GROUP_ID=100
#ARG LABEL_PREFIX=com.vmware.eocto

# add metadata via labels
# LABEL ${LABEL_PREFIX}.version="0.0.1"
# LABEL ${LABEL_PREFIX}.git.repo="git@gitlab.eng.vmware.com:sydney/containers/theworks.git"
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
    tdnf install -y \
        ansible \
        bash \
        ca-certificates \
        cdrkit \
        coreutils \
        curl \
        diffutils \
        gawk \
        git \
        htop \
        jq \
        mc \
        ncurses \
        nodejs \
        openssh \
        python3 \
        python3-jinja2 \
        python3-paramiko \
        python3-pip \
        python3-pyyaml \
        python3-resolvelib \
        python3-xml \
        shadow \
        tar \
        tmux \
        unzip \
        vim && \
    # add user/group
    # groupadd -g ${GROUP_ID} ${GROUP} && \
    # useradd -u ${USER_ID} -g ${GROUP} -m ${USER} && \
    useradd -g ${GROUP} -m ${USER} && \
    chown -R ${USER}:${GROUP} /home/${USER} && \
    # add /workspace and give user permissions
    mkdir -p /workspace && \
    chown -R ${USER}:${GROUP} /workspace && \
    # set git config
    git config --system --add init.defaultBranch "main" && \
    git config --system --add safe.directory "/workspace"

# install gitflow
RUN curl -skSLo gitflow-installer.sh https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh && \
    chmod +x ./gitflow-installer.sh && \
    ./gitflow-installer.sh install stable && \
    chown root:root /usr/local/bin/git-flow && \
    chmod 0755 /usr/local/bin/git-flow && \
    rm -rf ./gitflow-installer.sh /gitflow/

# install mkdocs, mkdocs-material, and desired plugins
COPY ./requirements.txt .
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r ./requirements.txt

# # grab kubectl vsphere plugins
# RUN curl -skSLo vsphere-plugin.zip https://${TANZU}/wcp/plugin/linux-${OS_ARCH}/vsphere-plugin.zip && \
#     unzip -d /usr/local vsphere-plugin.zip && \
#     chown root:root /usr/local/bin/kubectl-vsphere && \
#     chmod 0755 /usr/local/bin/kubectl-vsphere && \
#     rm -f vsphere-plugin.zip

# grab gh
RUN GHCLI_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/cli/cli/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo gh-cli.tar.gz https://github.com/cli/cli/releases/download/v${GHCLI_VERSION}/gh_${GHCLI_VERSION}_linux_${OS_ARCH}.tar.gz && \
    tar xzf gh-cli.tar.gz gh_${GHCLI_VERSION}_linux_${OS_ARCH}/bin/gh && \
    mv gh_${GHCLI_VERSION}_linux_${OS_ARCH}/bin/gh /usr/local/bin/ && \
    chown root:root /usr/local/bin/gh && \
    chmod 0755 /usr/local/bin/gh && \
    rm -rf gh-cli.tar.gz gh_${GHCLI_VERSION}_linux_${OS_ARCH}

# grab helm
RUN HELM_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/helm/helm/releases/latest | jq -r '.tag_name') && \
    curl -skSLo helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-${OS_ARCH}.tar.gz && \
    tar xzf helm.tar.gz linux-${OS_ARCH}/helm && \
    mv linux-${OS_ARCH}/helm /usr/local/bin/ && \
    chown root:root /usr/local/bin/helm && \
    chmod 0755 /usr/local/bin/helm && \
    rm -rf helm.tar.gz linux-${OS_ARCH}

# grab kubectx
RUN KUBECTX_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/ahmetb/kubectx/releases/latest | jq -r '.tag_name') && \
    curl -skSLo kubectx.tar.gz https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_${OS_ARCH2}.tar.gz && \
    tar xzf kubectx.tar.gz kubectx && \
    mv kubectx /usr/local/bin && \
    chown root:root /usr/local/bin/kubectx && \
    chmod 0755 /usr/local/bin/kubectx && \
    rm -rf kubectx.tar.gz

# grab kubens
RUN KUBENS_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/ahmetb/kubectx/releases/latest | jq -r '.tag_name') && \
    curl -skSLo kubens.tar.gz https://github.com/ahmetb/kubectx/releases/download/${KUBENS_VERSION}/kubens_${KUBENS_VERSION}_linux_${OS_ARCH2}.tar.gz && \
    tar xzf kubens.tar.gz kubens && \
    mv kubens /usr/local/bin && \
    chown root:root /usr/local/bin/kubens && \
    chmod 0755 /usr/local/bin/kubens && \
    rm -rf kubens.tar.gz

# grab clusterctl
RUN CLUSTERCTL_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/kubernetes-sigs/cluster-api/releases/latest  | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo clusterctl https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CLUSTERCTL_VERSION}/clusterctl-linux-${OS_ARCH} && \
    mv clusterctl /usr/local/bin/clusterctl && \
    chown root:root /usr/local/bin/clusterctl && \
    chmod 0755 /usr/local/bin/clusterctl

# grab packer
RUN PACKER_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/packer/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ packer.zip && \
    chown root:root /usr/local/bin/packer && \
    chmod 0755 /usr/local/bin/packer && \
    rm -f packer.zip

# grab packer vsphere plugin
RUN VSPHERE_PLUGIN_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/packer-plugin-vsphere/releases/latest | jq -r '.tag_name') && \
    packer plugins install github.com/hashicorp/vsphere ${VSPHERE_PLUGIN_VERSION}

# grab terraform
RUN TERRAFORM_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/terraform/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ terraform.zip && \
    chown root:root /usr/local/bin/terraform && \
    chmod 0755 /usr/local/bin/terraform && \
    rm -f terraform.zip

# grab nomad
RUN NOMAD_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/nomad/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo nomad.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ nomad.zip && \
    chown root:root /usr/local/bin/nomad && \
    chmod 0755 /usr/local/bin/nomad && \
    rm -f nomad.zip

# grab consul
RUN CONSUL_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/consul/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ consul.zip && \
    chown root:root /usr/local/bin/consul && \
    chmod 0755 /usr/local/bin/consul && \
    rm -f consul.zip

# grab vault
RUN VAULT_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/vault/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${OS_ARCH}.zip && \
    unzip -o -d /usr/local/bin/ vault.zip && \
    chown root:root /usr/local/bin/vault && \
    chmod 0755 /usr/local/bin/vault && \
    rm -f vault.zip

# grab terraform-docs
RUN TERRAFORMDOCS_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/terraform-docs/terraform-docs/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORMDOCS_VERSION}/terraform-docs-v${TERRAFORMDOCS_VERSION}-linux-${OS_ARCH}.tar.gz && \
    tar xzf terraform-docs.tar.gz terraform-docs && \
    mv terraform-docs /usr/local/bin && \
    chown root:root /usr/local/bin/terraform-docs && \
    chmod 0755 /usr/local/bin/terraform-docs && \
    rm -f terraform-docs.tar.gz

# grab terrascan
RUN TERRASCAN_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/tenable/terrascan/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo terrascan.tar.gz https://github.com/tenable/terrascan/releases/download/v${TERRASCAN_VERSION}/terrascan_${TERRASCAN_VERSION}_linux_${OS_ARCH2}.tar.gz && \
    tar xzf terrascan.tar.gz terrascan && \
    mv terrascan /usr/local/bin && \
    chown root:root /usr/local/bin/terrascan && \
    chmod 0755 /usr/local/bin/terrascan && \
    rm -f terrascan.tar.gz

# grab tfnotify
RUN TFNOTIFY_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/mercari/tfnotify/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo tfnotify.tar.gz https://github.com/mercari/tfnotify/releases/download/v${TFNOTIFY_VERSION}/tfnotify_linux_${OS_ARCH}.tar.gz && \
    tar xzf tfnotify.tar.gz tfnotify && \
    mv tfnotify /usr/local/bin && \
    chown root:root /usr/local/bin/tfnotify && \
    chmod 0755 /usr/local/bin/tfnotify && \
    rm -f tfnotify.tar.gz

# grab tfsec (depreciated)
RUN TFSEC_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/aquasecurity/tfsec/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo tfsec.tar.gz https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec_${TFSEC_VERSION}_linux_${OS_ARCH}.tar.gz && \
    tar xzf tfsec.tar.gz tfsec && \
    mv tfsec /usr/local/bin && \
    chown root:root /usr/local/bin/tfsec && \
    chmod 0755 /usr/local/bin/tfsec && \
    rm -f tfsec.tar.gz

# grab trivy (replacing tfsec)
RUN TRIVY_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/aquasecurity/trivy/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo trivy.tar.gz https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
    tar xzf trivy.tar.gz trivy && \
    mv trivy /usr/local/bin && \
    chown root:root /usr/local/bin/trivy && \
    chmod 0755 /usr/local/bin/trivy && \
    rm -f trivy.tar.gz

# grab k9s
RUN K9S_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/derailed/k9s/releases/latest | jq -r '.tag_name') && \
    curl -skSLo k9s.tar.gz https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${OS_ARCH}.tar.gz && \
    tar xzf k9s.tar.gz k9s && \
    mv k9s /usr/local/bin && \
    chown root:root /usr/local/bin/k9s && \
    chmod 0755 /usr/local/bin/k9s && \
    rm -f k9s.tar.gz

# grab lazygit
RUN LAZYGIT_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/jesseduffield/lazygit/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_${OS_ARCH2}.tar.gz && \
    tar xzf lazygit.tar.gz lazygit && \
    mv lazygit /usr/local/bin && \
    chown root:root /usr/local/bin/lazygit && \
    chmod 0755 /usr/local/bin/lazygit && \
    rm -f lazygit.tar.gz

# grab lazydocker
RUN LAZYDOCKER_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/jesseduffield/lazydocker/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo lazydocker.tar.gz https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_linux_${OS_ARCH2}.tar.gz && \
    tar xzf lazydocker.tar.gz lazydocker && \
    mv lazydocker /usr/local/bin && \
    chown root:root /usr/local/bin/lazydocker && \
    chmod 0755 /usr/local/bin/lazydocker && \
    rm -f lazydocker.tar.gz

# harden and remove unecessary packages
RUN chown -R root:root /usr/local/bin/ && \
    chown root:root /var/log && \
    chmod 0640 /var/log && \
    chown root:root /usr/lib/ && \
    chmod 755 /usr/lib/

# clean up
RUN tdnf erase -y unzip shadow && \
    tdnf clean all

# set user
USER ${USER}

# set working directory
WORKDIR /workspace

# set entrypoint to a shell
ENTRYPOINT ["bash"]

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
