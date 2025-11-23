#!/usr/bin/env bash
set -euo pipefail

# Ubuntu Desktop → Headless Server Cleanup Script
# Tested on Ubuntu 20.04 / 22.04 / 24.04

# ---------- Configurable flags ----------
DRY_RUN=false
PURGE_SNAP=false
TAME_SNAP=false
PURGE_FLATPAK=false
PURGE_GAMES=false
PURGE_NETWORKMANAGER=false
ASSUME_YES=false

usage() {
  cat <<'EOF'
Usage: sudo ./ubuntu-headless-clean.sh [options]

Options:
  -n, --dry-run            Simulate only (no changes). Applies to apt install/purge/autoremove and Snap/Flatpak actions.
  -s, --purge-snap         Remove Snap & all snaps (including snapd)
  -t, --tame-snap          Keep snapd; remove desktop snaps; set a quiet refresh window (02:00–04:00) and retain=2
  -f, --purge-flatpak      Remove Flatpak and all installed flatpaks
  -g, --purge-games        Remove casual GNOME games
  -N, --purge-nm           Remove NetworkManager (ONLY if you already use netplan/systemd-networkd)
  -y, --yes                Assume "yes" to apt prompts
  -h, --help               Show this help

Default (no flags):
- Removes desktop environments and common GUI apps
- Switches boot to text mode, disables display manager(s)
- Installs/ensures SSH
- Keeps Snap, Flatpak, NetworkManager
- Interactive apt (no -y)
EOF
}

# ---------- Parse args ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=true; shift ;;
    -s|--purge-snap) PURGE_SNAP=true; shift ;;
    -t|--tame-snap) TAME_SNAP=true; shift ;;
    -f|--purge-flatpak) PURGE_FLATPAK=true; shift ;;
    -g|--purge-games) PURGE_GAMES=true; shift ;;
    -N|--purge-nm) PURGE_NETWORKMANAGER=true; shift ;;
    -y|--yes) ASSUME_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

need_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Please run as root: sudo $0 [options]"
    exit 1
  fi
}

# Only simulate for apt install/purge/autoremove. Never simulate update/clean.
apt_cmd() {
  local subcmd="$1"; shift || true
  local simulate=""
  if $DRY_RUN; then
    case "$subcmd" in
      install|purge|autoremove) simulate="-s" ;;
      *) simulate="" ;;
    esac
  fi
  echo "+ apt-get ${simulate:+$simulate }$subcmd $*"
  apt-get ${simulate:+$simulate} "$subcmd" "$@"
}

systemctl_cmd() {
  if $DRY_RUN; then
    echo "+ systemctl $*"
  else
    systemctl "$@"
  fi
}

# ---------- Main ----------
need_root

if $ASSUME_YES; then
  export DEBIAN_FRONTEND=noninteractive
  APT_Y="-y"
else
  APT_Y=""
fi

echo "Updating apt and ensuring SSH server..."
apt_cmd update
apt_cmd install $APT_Y openssh-server

# Boot to text mode
echo "Setting default target to multi-user (text mode)..."
systemctl_cmd set-default multi-user.target

# Disable display managers if present
for DM in gdm3 lightdm sddm lxdm; do
  if systemctl list-unit-files | grep -q "^${DM}\.service"; then
    echo "Disabling display manager: $DM"
    systemctl_cmd disable "$DM" || true
    systemctl_cmd stop "$DM" || true
    systemctl_cmd mask "$DM" || true
  fi
done

# Core desktop/X/Wayland stacks (meta packages + shells, file managers, etc.)
CORE_GUI_PKGS=(
  'ubuntu-desktop' 'ubuntu-desktop-minimal' 'xorg' 'xserver-xorg*' 'x11-*' 'xwayland'
  'wayland*' 'wlroots*' 'gnome-*' 'kde-*' 'plasma-*' 'kubuntu-desktop' 'xubuntu-desktop'
  'lubuntu-desktop' 'lxqt-*' 'mate-*' 'ubuntustudio-desktop' 'budgie-desktop*' 'ubuntu-budgie-desktop'
  'yaru*' 'gnome-shell*' 'nautilus*' 'mutter*' 'plymouth*'
)

# Common GUI applications
GUI_APPS=(
  'update-manager*' 'software-properties-gtk' 'gnome-software*'
  'thunderbird*' 'libreoffice*' 'gedit*' 'eog' 'evince*' 'shotwell*' 'cheese'
  'simple-scan' 'remmina*' 'transmission-gtk*' 'vlc*' 'totem*' 'rhythmbox*'
  'gimp*' 'hexchat*' 'file-roller*' 'seahorse*' 'baobab*'
  'printer-driver-*'
)

# Optional games
GAME_APPS=(
  'aisleriot*' 'gnome-mines*' 'gnome-sudoku*' 'quadrapassel*' 'five-or-more*'
  'four-in-a-row*' 'hitori*' 'iagno*' 'lightsoff*' 'mahjongg*' 'swell-foop*'
  'tali*' 'gnome-mahjongg*'
)

# Optional removal of NetworkManager (default keep)
NETWORK_PKGS=(
  'network-manager*' 'network-manager-gnome*'
)

# Helper: collect installed packages matching patterns
collect_installed() {
  local -n ary=$1
  local out=()
  # list all packages and filter by regex built from the glob
  mapfile -t all < <(dpkg-query -W -f='${Package}\n' 2>/dev/null || true)
  for pattern in "${ary[@]}"; do
    local rx="^${pattern//\*/.*}$"
    for pkg in "${all[@]}"; do
      if [[ $pkg =~ $rx ]]; then out+=("$pkg"); fi
    done
  done
  printf "%s\n" "${out[@]}" | sort -u
}

echo "Resolving packages to purge..."
mapfile -t LIST_CORE < <(collect_installed CORE_GUI_PKGS)
mapfile -t LIST_APPS < <(collect_installed GUI_APPS)

if $PURGE_GAMES; then
  mapfile -t LIST_GAMES < <(collect_installed GAME_APPS)
else
  LIST_GAMES=()
fi

if $PURGE_NETWORKMANAGER; then
  mapfile -t LIST_NET < <(collect_installed NETWORK_PKGS)
else
  LIST_NET=()
fi

PURGE_LIST=("${LIST_CORE[@]}" "${LIST_APPS[@]}" "${LIST_GAMES[@]}" "${LIST_NET[@]}")

if [[ ${#PURGE_LIST[@]} -gt 0 ]]; then
  echo "Purging ${#PURGE_LIST[@]} packages..."
  apt_cmd purge $APT_Y "${PURGE_LIST[@]}" || true
else
  echo "No matching GUI packages found to purge."
fi

# -------- Snap handling --------
if $PURGE_SNAP; then
  if command -v snap &>/dev/null; then
    echo "Removing Snap and snapd..."
    if $DRY_RUN; then
      echo "+ Would remove snaps: $(snap list 2>/dev/null | awk 'NR>1 {print $1}' | xargs echo || true)"
      echo "+ Would stop: systemctl stop snapd.service snapd.socket"
      echo "+ Would purge: snapd"
      echo "+ Would remove: /snap /var/snap /var/lib/snapd /var/cache/snapd"
    else
      # Remove all snaps first
      for p in $(snap list 2>/dev/null | awk 'NR>1 {print $1}'); do
        snap remove --purge "$p" || true
      done
      systemctl stop snapd.service snapd.socket || true
      apt_cmd purge $APT_Y snapd || true
      rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd 2>/dev/null || true
    fi
  else
    echo "snapd not found; skipping Snap purge."
  fi
fi

if $TAME_SNAP; then
  echo "Taming snapd (keep snapd, remove desktop snaps, set refresh window)..."
  if command -v snap &>/dev/null; then
    DESKTOP_SNAPS=(
      firefox chromium snap-store gtk-common-themes
      gnome-3-38-2004 gnome-42-2204 gnome-46-2404
      snapd-desktop-integration
    )
    if $DRY_RUN; then
      echo "+ Would remove desktop snaps: ${DESKTOP_SNAPS[*]}"
      echo "+ Would run: snap set system refresh.timer=02:00-04:00"
      echo "+ Would run: snap set system refresh.retain=2"
      echo "+ Would run: snap set system refresh.metered=hold"
    else
      for s in "${DESKTOP_SNAPS[@]}"; do
        snap remove --purge "$s" 2>/dev/null || true
      done
      snap set system refresh.timer=02:00-04:00 || true
      snap set system refresh.retain=2 || true
      snap set system refresh.metered=hold || true
    fi
  else
    echo "snapd not found; cannot tame."
  fi
fi

# -------- Flatpak handling --------
if $PURGE_FLATPAK; then
  if command -v flatpak &>/dev/null; then
    echo "Removing Flatpak and installed runtimes..."
    if $DRY_RUN; then
      echo "+ Would run: flatpak uninstall -y --all"
      echo "+ Would purge: flatpak"
      echo "+ Would remove: /var/lib/flatpak"
    else
      flatpak uninstall -y --all || true
      apt_cmd purge $APT_Y flatpak || true
      rm -rf /var/lib/flatpak 2>/dev/null || true
    fi
  else
    echo "flatpak not found; skipping."
  fi
fi

echo "Autoremoving residual packages..."
apt_cmd autoremove $APT_Y --purge || true
apt_cmd clean || true

echo
echo "✅ Cleanup complete."
echo "Boot target is multi-user.target (text mode)."
echo "Reboot when ready: sudo reboot"
echo
echo "Tip: If you removed NetworkManager, ensure netplan uses renderer: networkd and then 'sudo netplan apply'."

