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

# grab gomplate
RUN GOMPLATE_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/packer/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo gomplate https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-${OS_ARCH} && \
    mv gomplate /usr/local/bin/ && \
    chown root:root /usr/local/bin/gomplate && \
    chmod 0755 /usr/local/bin/gomplate

# grab packer
RUN PACKER_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/packer/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${OS_ARCH}.zip && \
    unzip packer.zip packer && \
    mv packer /usr/local/bin/ && \
    chown root:root /usr/local/bin/packer && \
    chmod 0755 /usr/local/bin/packer && \
    rm -f packer.zip

# grab packer vsphere plugin
RUN VSPHERE_PLUGIN_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/packer-plugin-vsphere/releases/latest | jq -r '.tag_name') && \
    packer plugins install github.com/hashicorp/vsphere ${VSPHERE_PLUGIN_VERSION}

# grab terraform
RUN TERRAFORM_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/terraform/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${OS_ARCH}.zip && \
    unzip terraform.zip terraform && \
    mv terraform /usr/local/bin/ && \
    chown root:root /usr/local/bin/terraform && \
    chmod 0755 /usr/local/bin/terraform && \
    rm -f terraform.zip

# grab nomad
RUN NOMAD_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/nomad/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo nomad.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${OS_ARCH}.zip && \
    unzip nomad.zip nomad && \
    mv nomad /usr/local/bin/ && \
    chown root:root /usr/local/bin/nomad && \
    chmod 0755 /usr/local/bin/nomad && \
    rm -f nomad.zip

# grab consul
RUN CONSUL_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/consul/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${OS_ARCH}.zip && \
    unzip consul.zip consul && \
    mv consul /usr/local/bin/ && \
    chown root:root /usr/local/bin/consul && \
    chmod 0755 /usr/local/bin/consul && \
    rm -f consul.zip

# grab vault
RUN VAULT_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/hashicorp/vault/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${OS_ARCH}.zip && \
    unzip vault.zip vault && \
    mv vault /usr/local/bin && \
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

# install docker hub-tool cli
RUN HUB_TOOL_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/docker/hub-tool/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo hub-tool.tar.gz https://github.com/docker/hub-tool/releases/download/v${HUB_TOOL_VERSION}/hub-tool-linux-${OS_ARCH}.tar.gz && \
    tar xzf hub-tool.tar.gz hub-tool/hub-tool && \
    mv hub-tool/hub-tool /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/hub-tool && \
    rm -rf hub-tool.tar.gz hub-tool/

# install vale cli
RUN VALE_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/errata-ai/vale/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo vale.tar.gz https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz && \
    tar xzf vale.tar.gz vale && \
    mv vale /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/vale && \
    rm -rf vale.tar.gz

# install oras
RUN ORAS_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/oras-project/oras/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo oras.tar.gz "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_${OS_ARCH}.tar.gz" && \
    tar -xzf oras.tar.gz oras && \
    mv oras /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/oras && \
    rm -rf oras.tar.gz

# install crictl
RUN CRICTL_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/kubernetes-sigs/cri-tools/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo crictl.tar.gz https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-${OS_ARCH}.tar.gz && \
    tar xzf crictl.tar.gz crictl && \
    mv crictl /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/crictl && \
    rm -f crictl.tar.gz

# install fd
RUN FD_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/sharkdp/fd/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo fd.tar.gz https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-${OS_ARCH2}-unknown-linux-gnu.tar.gz && \
    tar xzf fd.tar.gz && \
    mv fd-v${FD_VERSION}-${OS_ARCH2}-unknown-linux-gnu/fd /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/fd && \
    rm -rf fd.tar.gz fd-v${FD_VERSION}-${OS_ARCH2}-unknown-linux-gnu

# install bat
RUN BAT_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/sharkdp/bat/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo bat.tar.gz https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-${OS_ARCH2}-unknown-linux-gnu.tar.gz && \
    tar xzf bat.tar.gz && \
    mv bat-v${BAT_VERSION}-${OS_ARCH2}-unknown-linux-gnu/bat /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/bat && \
    rm -rf bat.tar.gz bat-v${BAT_VERSION}-${OS_ARCH2}-unknown-linux-gnu

# install ripgrep
RUN RIPGREP_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo ripgrep.tar.gz https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-${OS_ARCH2}-unknown-linux-musl.tar.gz && \
    tar xzf ripgrep.tar.gz && \
    mv ripgrep-${RIPGREP_VERSION}-${OS_ARCH2}-unknown-linux-musl/rg /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/rg && \
    rm -rf ripgrep.tar.gz ripgrep-${RIPGREP_VERSION}-${OS_ARCH2}-unknown-linux-musl

# install fzf
RUN FZF_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/junegunn/fzf/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo fzf.tar.gz https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${OS_ARCH}.tar.gz && \
    tar xzf fzf.tar.gz && \
    mv fzf /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/fzf && \
    rm -rf fzf.tar.gz

# install skim
RUN SKIM_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/skim-rs/skim/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo skim.tar.gz https://github.com/skim-rs/skim/releases/download/v${SKIM_VERSION}/skim-${OS_ARCH2}-unknown-linux-musl.tgz && \
    tar xzf skim.tar.gz && \
    mv sk /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/sk && \
    rm -rf skim.tar.gz

# install dockerfmt
RUN DOCKERFMT_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/reteps/dockerfmt/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo dockerfmt.tar.gz https://github.com/reteps/dockerfmt/releases/download/v${DOCKERFMT_VERSION}/dockerfmt-v${DOCKERFMT_VERSION}-linux-${OS_ARCH}.tar.gz && \
    tar xzf dockerfmt.tar.gz && \
    mv dockerfmt /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/dockerfmt && \
    rm -rf dockerfmt.tar.gz

# install atuin
RUN ATUIN_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/atuinsh/atuin/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo atuin.tar.gz https://github.com/atuinsh/atuin/releases/download/${ATUIN_VERSION}/atuin-${OS_ARCH2}-unknown-linux-gnu.tar.gz && \
    tar xzf atuin.tar.gz && \
    mv atuin-${OS_ARCH2}-unknown-linux-gnu/atuin /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/atuin && \
    rm -rf atuin.tar.gz atuin-${OS_ARCH2}-unknown-linux-gnu/

# install threatcl (threat modelling configuration language with hcl)
RUN THREATCL_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/threatcl/threatcl/releases/latest | jq -r '.id') && \
    THREATCL_DOWNLOAD_URL=$(curl -H 'Accept: application/json' -sSL https://api.github.com/repos/threatcl/threatcl/releases/${THREATCL_VERSION} |  jq -r '.assets[] | select( .browser_download_url | contains("linux-amd64")) | .browser_download_url') && \
    curl -skSLo threatcl.tar.gz ${THREATCL_DOWNLOAD_URL} && \
    tar xzf threatcl.tar.gz && \
    mv threatcl /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/threatcl && \
    rm -rf threatcl.tar.gz

# install wtf
RUN WTF_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/wtfutil/wtf/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo wtf.tar.gz https://github.com/wtfutil/wtf/releases/download/v${WTF_VERSION}/wtf_${WTF_VERSION}_linux_${OS_ARCH}.tar.gz && \
    mkdir ~/.config/wtf/ && \
    curl -skSLo ~/.config/wtf/config.yml https://raw.githubusercontent.com/wtfutil/wtf/refs/heads/master/_sample_configs/sample_config.yml && \
    tar xzf wtf.tar.gz && \
    mv wtf_${WTF_VERSION}_linux_${OS_ARCH}/wtfutil /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/wtfutil && \
    rm -rf wtf.tar.gz wtf_${WTF_VERSION}_linux_${OS_ARCH}/

# install scc (i.e. sloc, cloc, code)
RUN SCC_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/boyter/scc/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo scc.tar.gz https://github.com/boyter/scc/releases/download/v${SCC_VERSION}/scc_Linux_x86_64.tar.gz && \
    tar xzf scc.tar.gz scc && \
    mv ./scc /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/scc && \
    rm -rf scc.tar.gz

# install tldr client
RUN TLDR_VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/tldr-pages/tlrc/releases/latest | jq -r '.tag_name' | tr -d 'v') && \
    curl -skSLo tldr.tar.gz https://github.com/tldr-pages/tlrc/releases/download/v${TLDR_VERSION}/tlrc-v${TLDR_VERSION}-${OS_ARCH2}-unknown-linux-musl.tar.gz && \
    tar xzf tldr.tar.gz tldr && \
    mv ./tldr /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/tldr && \
    rm -rf tldr.tar.gz

# install .net sdk
# RUN DOTNETSDK_VERSION="8.0.404" && \
#     DOTNET_ARCH="x64" && \
#     curl -skSLo dotnet-sdk.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_SDK_VERSION}/dotnet-sdk-${DOTNET_SDK_VERSION}-linux-${DOTNET_ARCH}.tar.gz && \
#     mkdir -p /usr/share/dotnet && tar xzf dotnet-sdk.tar.gz -C /usr/share/dotnet && \
#     export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true && \
#     export DOTNET_ROOT=/usr/share/dotnet && \
#     export PATH=$PATH:$DOTNET_ROOT

#############################################################################
##
## Would be nice if projects could come up with standard naming convention:
## e.g.
##     echo "project-version-$(uname -s)-$(uname -m).tar.gz" | tr '[A-Z]' '[a-z]'
##
## This would make the above steps more consistent and easier to automate.
##
#############################################################################

# switch back to non-root user
USER ${USER}:${GROUP}

#############################################################################
# vim: ft=unix sync=dockerfile ts=4 sw=4 et tw=78:
