#!/bin/bash

set -ouex pipefail

# Install dnf5 COPR plugin
dnf5 install -y dnf5-plugins

# Enable COPRs
dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable che/nerd-fonts
dnf5 -y copr enable atim/lazygit
dnf5 -y copr enable scottames/ghostty
dnf5 -y copr enable bazzite-org/bazzite
dnf5 -y copr enable solopasha/hyprland

# Bazzite packages should win version conflicts
dnf5 -y config-manager setopt "*bazzite*".priority=1

# RPMFusion (needed for steam, ffmpeg, etc.)
dnf5 install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Kubernetes repo (for kubectl)
cat > /etc/yum.repos.d/kubernetes.repo << 'EOF'
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/repodata/repomd.xml.key
EOF
