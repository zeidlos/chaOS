#!/bin/bash

set -ouex pipefail

STARSHIP_VERSION="1.26.0"
KREW_VERSION="v0.5.0"
YAZI_VERSION="26.5.6"

# Starship shell prompt
curl -L "https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-x86_64-unknown-linux-gnu.tar.gz" \
  -o /tmp/starship.tar.gz
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin

# Yazi terminal file manager (not in Fedora repos)
curl -L "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip" \
  -o /tmp/yazi.zip
unzip -j /tmp/yazi.zip "yazi-x86_64-unknown-linux-musl/yazi" "yazi-x86_64-unknown-linux-musl/ya" -d /tmp/yazi
install -c -m 0755 /tmp/yazi/yazi /tmp/yazi/ya /usr/bin

# krew (kubectl plugin manager) — installed as kubectl-krew so `kubectl krew` works
curl -L "https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/krew-linux_amd64.tar.gz" \
  -o /tmp/krew.tar.gz
tar -xzf /tmp/krew.tar.gz -C /tmp
install -c -m 0755 /tmp/krew-linux_amd64 /usr/bin/kubectl-krew
