#!/bin/bash

function get_os() {
    local os="unknown"
    case $(uname) in
        Linux)   os="linux";;
        Darwin)  os="darwin";;
        FreeBSD) os="freebsd";;
        OpenBSD) os="openbsd";;
        NetBSD ) os="netbsd ";;
        SunOS)   os="sunos";;
        Solaris) os="solaris";;
        *)       os="unknown";;
    esac
    echo $os
}

function get_os_arch() {
    local arch="unknown"
    case $(uname -m) in
        arm64 | aarch64) arch="arm64";;
        m68k)            arch="m68k";;
        mips)            arch="mips";;
        mips64)          arch="mips64";;
        ppc)             arch="ppc";;
        ppc64)           arch="ppc64";;
        sparc)           arch="sparc";;
        sparc64)         arch="sparc64";;
        amd64 | x86_64)  arch="amd64";;
        i386 | i486 | i586 | i686) arch="x86";;
        *)               arch="unknown";;
    esac
    echo $arch
}

requirements_check() {
    commands=( awk bash curl gawk git grep jq less sed sha256sum sort tr tar unzip )
    for i in ${commands[*]}; do
        echo ">> checking $i <<";
        command -v $i > /dev/null 2>&1 || { echo "Error: $i is required but not installed." >&2; exit 1; }
    done
}

requirements_check

# OS=$(get_os)
# if [[ $OS == "windows" ]]; then
#     BINARY_NAME=opa_$(get_os)_$(get_os_arch).exe
# else
#     BINARY_NAME=opa_$(get_os)_$(get_os_arch)
# fi
# echo $BINARY_NAME

# rel=$(gh api /repos/open-policy-agent/opa/releases/latest | jq -r .tag_name)
# gh release view -R open-policy-agent/opa ${rel} --json assets | jq '.assets[] | { "name": .name, "url": .url }'

# if ! command -v opa > /dev/null 2>&1; then
#     BINARY_NAME=opa_$(get_os())_$(get_os_arch())
#     curl -skSLO https://openpolicyagent.org/downloads/latest/$BINARY_NAME
#     curl -skSLO https://openpolicyagent.org/downloads/latest/$BINARY_NAME.sha256
#     sha256sum -c $BINARY_NAME.sha256
#     mv $BINARY_NAME /usr/local/bin/opa
#     rm $BINARY_NAME.sha256
#     chmod 0755 /usr/local/bin/opa
# fi

# if ! command -v opa > /dev/null 2>&1; then
#     OWNER=open-policy-agent
#     REPO=opa
#     COMMAND=opa
#     # VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/${OWNER}/${REPO}/releases/latest | jq -r '.tag_name' | tr -d 'v')
#     VERSION=$(curl -H 'Accept: application/json' -sSL https://github.com/${OWNER}/${REPO}/releases/latest | jq -r '.tag_name' )
#     OS=$(get_os)
#     ARCH=$(get_os_arch)
#     # echo "curl -skSLo ${COMMAND} https://github.com/${OWNER}/${REPO}/releases/download/v${VERSION}/${COMMAND}_${OS}_${ARCH}"
#     echo "curl -skSLo ${COMMAND} https://github.com/${OWNER}/${REPO}/releases/download/${VERSION}/${COMMAND}_${OS}_${ARCH}"
#     echo "mv ${COMMAND} /usr/local/bin"
#     echo "chown root:root /usr/local/bin/${COMMAND}"
#     echo "chmod 0755 /usr/local/bin/${COMMAND}"
# fi

############################################
# taken from here: [Go (Golang) GOOS and GOARCH](https://gist.github.com/asukakenji/f15ba7e588ac42795f421b48b8aede63)
# GOOS values out-of-the-box
# { "aix", "android", "darwin", "dragonfly", "freebsd", "illumos", "ios", "js", "linux", "netbsd", "openbsd", "plan9", "solaris", "windows" }

# GOARCH values out-of-the-box
# 32-bit
# { "386", "arm", "mips", "mipsle" }
# 64-bit
# { "amd64", "arm64", "mips64", "mips64le", "ppc64", "ppc64le", "riscv64", "s390x", "wasm" }

# ###############################################

# gh release -R bitwarden/clients list --json tagName,id
# gh release -R bitwarden/clients list --json tagName | jq    '.[] | select(.tagName | startswith("cli-"))'
# gh release -R bitwarden/clients list --json tagName | jq -r '.[] | select(.tagName | startswith("cli-"))'
# gh release -R bitwarden/clients list --json tagName | jq -r '.[] | select(.tagName | startswith("cli-"))| .tagName'
# gh release -R bitwarden/clients list --json tagName | jq -r '.[] | select(.tagName | startswith("cli-"))| .tagName' | sort
# gh release -R bitwarden/clients list --json tagName | jq -r '.[] | select(.tagName | startswith("cli-"))| .tagName' | sort -r
# gh release -R bitwarden/clients list --json tagName | jq 'sort_by(.tagName)'
# gh release -R bitwarden/clients list --json tagName | jq 'sort_by(.tagName) | reverse'
# gh release -R bitwarden/clients list --json tagName | jq 'sort_by(.tagName) | reverse' | jq -r '[.[] | select(.tagName | startswith("cli-"))] | .[0].tagName'

# ################################################

# TAG=$(gh release -R bitwarden/clients list --json tagName | jq 'sort_by(.tagName) | reverse' | jq -r '[.[] | select(.tagName | startswith("cli-"))] | .[0].tagName')
# gh api /repos/bitwarden/clients/releases/tags/${TAG} | jq '.assets[] | select(.name,.url | startswith("bw-oss-") and contains("linux") and contains("arm64"))' | jq -r '.browser_download_url'

# ################################################

# gh release list -R open-policy-agent/opa
# gh release view -R open-policy-agent/opa --json tagName | jq -r '.tagName'
# gh api /repos/open-policy-agent/opa/releases/latest
# gh api /repos/open-policy-agent/opa/releases/latest | jq -r '.tag_name'
# gh release view -R open-policy-agent/opa v1.21.1
# gh release view -R open-policy-agent/opa v1.21.1 --json assets
# gh release view -R open-policy-agent/opa v1.21.1 --json assets | jq '.assets[] | { "name": .name, "url": .url }'

# ################################################

# gh release view -R open-policy-agent/opa $(gh release view -R open-policy-agent/opa --json tagName | jq -r '.tagName') --json assets | jq '[ .assets[] | { "name": .name, "url": .url }]' | jq -r '.[] | select(.name == "opa_linux_arm64") | .url'

# ################################################

# gh repo view open-policy-agent/opa

# gh api /repos/open-policy-agent/opa/tags | jq -r '.[].name'

# #######################################################
