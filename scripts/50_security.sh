#!/usr/bin/env bash
set -euo pipefail

echo "==> Optional security hardening (SSH, UFW, fail2ban)"

# SSH hardening (gentle)
SSHD="/etc/ssh/sshd_config"
if [ -w "$SSHD" ]; then
  sudo cp "$SSHD" "$SSHD.bak.$(date +%s)"
  sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD" || true
  sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSHD" || true
  sudo systemctl restart sshd || sudo systemctl restart ssh || true
fi

# UFW if available
if command -v ufw >/dev/null 2>&1; then
  sudo ufw allow OpenSSH || true
  sudo ufw enable || true
fi

# fail2ban
if command -v apt >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y fail2ban
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y fail2ban
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm fail2ban
elif command -v zypper >/dev/null 2>&1; then
  sudo zypper --non-interactive install -y fail2ban
fi
sudo systemctl enable --now fail2ban || true

echo "✅ Security tweaks complete."
