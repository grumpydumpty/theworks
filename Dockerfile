FROM base:dev

# set argument defaults
ARG OS_ARCH="amd64"
ARG OS_ARCH2="x86_64"
ARG HUGO_VARIANT="hugo_extended"
ARG VCENTER=10.109.195.161
ARG USER=vlabs
ARG GROUP=users

# Switch to root to install OS packages
USER root:root

# update repositories, install packages, and then clean up
RUN tdnf update -y && \
    # grab what we can via standard packages
    tdnf install -y \
        ansible \
        cdrkit \
        nodejs \
        python3 \
        python3-jinja2 \
        python3-paramiko \
        python3-pip \
        python3-pyyaml \
        python3-resolvelib \
        python3-xml && \
    # clean up
    tdnf clean all

# install mkdocs, mkdocs-material, and desired plugins
COPY ./requirements.txt .
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r ./requirements.txt && \
    rm requirements.txt

# install ansible
RUN pip3 install ansible-core && \
    pip3 install pywinrm[credssp] && \
    ansible-galaxy collection install ansible.windows

## grab kubectl vsphere plugins
# RUN curl -skSLo vsphere-plugin.zip https://${VCENTER}/wcp/plugin/linux-${OS_ARCH}/vsphere-plugin.zip && \
#     unzip -d /usr/local vsphere-plugin.zip && \
#     chown root:root /usr/local/bin/kubectl-vsphere && \
#     chmod 0755 /usr/local/bin/kubectl-vsphere && \
#     rm -f vsphere-plugin.zip

# install gitflow
RUN curl -skSLo gitflow-installer.sh https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh && \
    chmod +x ./gitflow-installer.sh && \
    ./gitflow-installer.sh install stable && \
    chown root:root /usr/local/bin/git-flow && \
    chmod 0755 /usr/local/bin/git-flow && \
    rm -rf ./gitflow-installer.sh ./gitflow/

# grab git-lfs
RUN GIT_LFS_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/git-lfs/git-lfs/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo git-lfs.tar.gz https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-${OS_ARCH}-v${GIT_LFS_VERSION}.tar.gz && \
    tar xzf git-lfs.tar.gz git-lfs-${GIT_LFS_VERSION}/git-lfs && \
    mv git-lfs-${GIT_LFS_VERSION}/git-lfs /usr/local/bin/ && \
    chown root:root /usr/local/bin/git-lfs && \
    chmod 0755 /usr/local/bin/git-lfs && \
    rm -rf git-lfs.tar.gz git-lfs-${GIT_LFS_VERSION}

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

# grab terramaid
#RUN TERRAMAID_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/RoseSecurity/Terramaid/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
RUN TERRAMAID_VERSION=2.0.1 && \
    curl -skSLo terramaid.tar.gz https://github.com/RoseSecurity/Terramaid/releases/download/v${TERRAMAID_VERSION}/terramaid_linux_${OS_ARCH2}.tar.gz && \
    tar xzf terramaid.tar.gz Terramaid && \
    mv Terramaid /usr/local/bin/terramaid && \
    chown root:root /usr/local/bin/terramaid && \
    chmod 0755 /usr/local/bin/terramaid && \
    rm -f terramaid.tar.gz

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

# grab tfcmt
RUN TFCMT_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/suzuki-shunsuke/tfcmt/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo tfcmt.tar.gz https://github.com/suzuki-shunsuke/tfcmt/releases/download/v${TFCMT_VERSION}/tfcmt_linux_${OS_ARCH}.tar.gz && \
    tar xzf tfcmt.tar.gz tfcmt && \
    mv tfcmt /usr/local/bin && \
    chown root:root /usr/local/bin/tfcmt && \
    chmod 0755 /usr/local/bin/tfcmt && \
    rm -f tfcmt.tar.gz

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

# install tini
RUN TINI_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/krallin/tini/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -L https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${ARCH} > /usr/local/bin/tini && \
    chmod 0755 /usr/local/bin/tini
    
# install hugo
RUN HUGO_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/gohugoio/hugo/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_VARIANT}_${HUGO_VERSION}_linux-${OS_ARCH}.tar.gz && \
    tar xzf hugo.tar.gz hugo && \    
    mv hugo /usr/local/bin && \
    chmod 0755 /usr/local/bin/hugo && \
    rm -rf hugo.tar.gz

# install termsvg
RUN TERMSVG_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/MrMarble/termsvg/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo termsvg.tar.gz https://github.com/MrMarble/termsvg/releases/download/v${TERMSVG_VERSION}/termsvg-${TERMSVG_VERSION}-linux-${OS_ARCH}.tar.gz && \
    tar xzf termsvg.tar.gz termsvg-${TERMSVG_VERSION}-linux-${OS_ARCH}/termsvg && \
    mv termsvg-${TERMSVG_VERSION}-linux-${OS_ARCH}/termsvg /usr/local/bin && \
    chmod 0755 /usr/local/bin/termsvg && \
    rm -rf termsvg.tar.gz termsvg-${TERMSVG_VERSION}-linux-${OS_ARCH}
    
# install yq
RUN YQ_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/mikefarah/yq/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo yq.tar.gz https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${OS_ARCH}.tar.gz && \
    tar xzf yq.tar.gz ./yq_linux_${OS_ARCH} && \    
    mv yq_linux_${OS_ARCH} /usr/local/bin/yq && \
    chmod 0755 /usr/local/bin/yq && \
    rm -rf yq.tar.gz

# install marp-cli
RUN MARP_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/marp-team/marp-cli/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo marp.tar.gz https://github.com/marp-team/marp-cli/releases/download/v${MARP_VERSION}/marp-cli-v${MARP_VERSION}-linux.tar.gz && \
    tar xzf marp.tar.gz marp && \
    mv ./marp /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/marp && \
    rm -rf marp.tar.gz

## install scc - https://github.com/boyter/scc/releases/download/v3.4.0/scc_Linux_x86_64.tar.gz
# RUN SCC_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/boyter/scc/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
#     curl -skSLo scc.tar.gz https://github.com/boyter/scc/releases/download/v${SCC_VERSION}/scc_Linux_x86_64.tar.gz && \
#     tar xzf scc.tar.gz scc && \
#     mv ./scc /usr/local/bin/ && \
#     chmod 0755 /usr/local/bin/scc && \
#     rm -rf scc.tar.gz

# install .net sdk
# RUN DOTNETSDK_VERSION="8.0.404" && \
#     DOTNET_ARCH="x64" && \
#     curl -skSLo dotnet-sdk.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_SDK_VERSION}/dotnet-sdk-${DOTNET_SDK_VERSION}-linux-${DOTNET_ARCH}.tar.gz && \
#     mkdir -p /usr/share/dotnet && tar xzf dotnet-sdk.tar.gz -C /usr/share/dotnet && \
#     export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true && \
#     export DOTNET_ROOT=/usr/share/dotnet && \
#     export PATH=$PATH:$DOTNET_ROOT

# switch back to non-root user
USER ${USER}:${GROUP}

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
