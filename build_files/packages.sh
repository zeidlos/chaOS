#!/bin/bash

set -ouex pipefail

PACKAGES=(
  # Base tools
  tmux
  btop
  just
  golang
  neovim
  unzip

  # Utilities not bundled in the COSMIC Atomic base
  NetworkManager-openvpn
  distrobox
  gdisk
  gnome-disk-utility
  playerctl
  system-config-printer
  toolbox

  # Productivity / hardware support
  adcli
  adw-gtk3-theme
  alsa-firmware
  bash-color-prompt
  bcache-tools
  bootc
  borgbackup
  cascadia-code-fonts
  clevis
  cryfs
  davfs2
  ddcutil
  evolution-data-server
  evolution-ews-core
  evtest
  fastfetch
  firewall-config
  fish
  flatpak-spawn
  foo2zjs
  fuse-encfs
  ghostty
  git-credential-libsecret
  glow
  lazygit
  gnupg2-scdaemon
  gum
  gvfs
  gvfs-archive
  gvfs-fuse
  gvfs-nfs
  gvfs-smb
  hplip
  ibus-mozc
  ifuse
  igt-gpu-tools
  iwd
  krb5-workstation
  libavcodec-free
  libcamera-gstreamer
  libcamera-tools
  libinput-utils
  libsss_autofs
  libwacom
  libwacom-data
  libwacom-utils
  libxcrypt-compat
  lm_sensors
  lsb_release
  make
  mesa-libGLU
  mozc
  nerd-fonts
  oddjob-mkhomedir
  openssh-askpass
  pam-u2f
  pam_yubico
  pulseaudio-utils
  rclone
  restic
  samba
  samba-dcerpc
  samba-ldb-ldap-modules
  samba-winbind-clients
  samba-winbind-modules
  setools-console
  sssd-ad
  sssd-krb5
  sssd-nfs-idmap
  k9s
  kubectl
  mosh
  symlinks
  topgrade
  tuned
  tuned-gtk
  tuned-ppd
  tuned-profiles-atomic
  usbip
  usbmuxd
  wireguard-tools
  wl-clipboard
  yubikey-manager

  # Gaming / Steam
  dbus-x11
  gamescope-shaders
  gamescope.x86_64
  gamescope-session-plus
  gamescope-session-steam
  gobject-introspection
  libFAudio.i686
  libFAudio.x86_64
  lutris
  mangohud.i686
  mangohud.x86_64
  steam
  umu-launcher
  vkBasalt.i686
  vkBasalt.x86_64
  xdg-user-dirs

  # Hyprland ecosystem (solopasha COPR)
  # Note: hyprland itself is excluded — the COPR aquamarine dep conflicts
  # with Fedora 44's libdisplay-info-0.3.0. Re-add once COPR rebuilds.
  hyprcursor
  hypridle
  hyprlock
  hyprpaper
  hyprpicker
  hyprpolkitagent
  hyprshot
  uwsm
  waybar
  wofi
  mako
  grim
  slurp
  satty
  cliphist
  swww
  nwg-look
  # qt6ct excluded — Fedora 44 rebuilt it for Qt 6.11 but solopasha's
  # hyprland-qt-support (pulled by hyprpolkitagent) still needs Qt 6.10 private API.
  # Re-add once the COPR rebuilds against Qt 6.11.
  foot
  brightnessctl
  pamixer
  network-manager-applet
)

dnf5 install -y --allowerasing --setopt=install_weak_deps=False "${PACKAGES[@]}"

dnf5 remove -y firefox firefox-langpacks gamemode

# Disable repos that should not ship on the final image
[[ -f /etc/yum.repos.d/_copr_ublue-os-akmods.repo ]] && \
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo || true

dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable ublue-os/packages
dnf5 -y copr disable che/nerd-fonts
dnf5 -y copr disable atim/lazygit
dnf5 -y copr disable scottames/ghostty
dnf5 -y copr disable bazzite-org/bazzite
dnf5 -y copr disable solopasha/hyprland
