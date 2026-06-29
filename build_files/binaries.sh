#!/bin/bash

set -ouex pipefail

STARSHIP_VERSION="1.26.0"
KREW_VERSION="v0.5.0"

# Starship shell prompt
curl -L "https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-x86_64-unknown-linux-gnu.tar.gz" \
  -o /tmp/starship.tar.gz
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin

# krew (kubectl plugin manager) — installed as kubectl-krew so `kubectl krew` works
curl -L "https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/krew-linux_amd64.tar.gz" \
  -o /tmp/krew.tar.gz
tar -xzf /tmp/krew.tar.gz -C /tmp
install -c -m 0755 /tmp/krew-linux_amd64 /usr/bin/kubectl-krew
