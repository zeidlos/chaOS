#!/bin/bash

set -ouex pipefail

# Overlay system_files onto /
cp -avf /ctx/system_files/. /

# Systemd units
systemctl --global enable podman-auto-update.timer
systemctl enable podman.socket
systemctl enable sysfs-read-powercap-intel.service 2>/dev/null || true

# Hide TUI tools from desktop launchers (Hidden removes mime associations too)
[[ -f /usr/share/applications/htop.desktop ]] && \
  sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/htop.desktop || true
[[ -f /usr/share/applications/nvtop.desktop ]] && \
  sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/nvtop.desktop || true
