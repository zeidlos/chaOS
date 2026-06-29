#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Install sandbox proxy CA if present (needed for HTTPS in sandboxed build environments)
if [[ -f /ctx/proxy-ca.crt ]]; then
  cp /ctx/proxy-ca.crt /etc/pki/ca-trust/source/anchors/proxy-ca.crt
  update-ca-trust
fi

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux btop just golang neovim dnf5-plugins

# Add Cosmic Repo
# if [[ "${IMAGE}" =~ beta ]]; then
dnf5 -y copr enable ryanabx/cosmic-epoch
# fi

# Add Staging repo
dnf5 -y copr enable ublue-os/staging

# Ublue Packages
dnf5 -y copr enable ublue-os/packages

# Add Nerd Fonts Repo
dnf5 -y copr enable che/nerd-fonts

# Add lazygit Repo
dnf5 -y copr enable atim/lazygit

# Add RPMFusion (needed for steam, ffmpeg, etc.)
dnf5 install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Add and Enable Tailscale Repo
dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf5 config-manager setopt tailscale-stable.enabled=1

# Cosmic Packages
PACKAGES=(
  NetworkManager-openvpn
  cosmic-files
  cosmic-initial-setup
  cosmic-player
  cosmic-session
  cosmic-store
  cosmic-term
  distrobox
  fedora-release-cosmic-atomic
  fedora-release-identity-cosmic-atomic
  flatpak
  gdisk
  gnome-disk-utility
  gnome-keyring
  gnome-keyring-pam
  playerctl
  plymouth-system-theme
  pop-launcher
  system-config-printer
  toolbox
  xdg-desktop-portal-gtk
)

# Bluefin Packages
PACKAGES+=(
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
  symlinks
  tailscale
  tmux
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
)

dnf5 install -y --allowerasing \
  --setopt=install_weak_deps=False \
  "${PACKAGES[@]}"

# Remove Unneeded and Disable Repos
UNINSTALL_PACKAGES=(
  firefox
  firefox-langpacks
)

dnf5 remove -y "${UNINSTALL_PACKAGES[@]}"
[[ -f /etc/yum.repos.d/_copr_ublue-os-akmods.repo ]] && sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo || true

# Starship Shell Prompt
curl -L "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz" -o /tmp/starship.tar.gz
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin

# Systemd
systemctl enable cosmic-greeter
systemctl --global enable podman-auto-update.timer

# Hide Desktop Files. Hidden removes mime associations
[[ -f /usr/share/applications/htop.desktop ]] && sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/htop.desktop || true
[[ -f /usr/share/applications/nvtop.desktop ]] && sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/nvtop.desktop || true
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
# this allows mangohud to read CPU power wattage
systemctl enable sysfs-read-powercap-intel.service 2>/dev/null || true

dnf5 -y copr enable bazzite-org/bazzite
dnf5 -y config-manager setopt "*bazzite*".priority=1

STEAM_PACKAGES=(
  dbus-x11
  gamescope-shaders
  gamescope.x86_64
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
)

dnf5 install -y --setopt=install_weak_deps=False "${STEAM_PACKAGES[@]}"

dnf5 remove -y gamemode

dnf5 install -y \
  --enable-repo="copr:copr.fedorainfracloud.org:bazzite-org:bazzite" \
  gamescope-session-plus \
  gamescope-session-steam

# Hyprland ecosystem (solopasha COPR)
# Note: hyprland itself is excluded — the COPR aquamarine dep (libdisplay-info.so.2)
# conflicts with Fedora 44's libdisplay-info-0.3.0. Re-add once COPR rebuilds.
dnf5 -y copr enable solopasha/hyprland

HYPRLAND_PACKAGES=(
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
  qt6ct
  foot
  brightnessctl
  pamixer
  network-manager-applet
)

dnf5 install -y --setopt=install_weak_deps=False "${HYPRLAND_PACKAGES[@]}"

