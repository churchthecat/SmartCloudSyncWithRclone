#!/usr/bin/env bash
set -e

PROJECT_DIR="$(pwd)"

# Install binary
sudo ln -sf "$PROJECT_DIR/scripts/main.sh" /usr/local/bin/smartcloud
chmod +x scripts/*.sh
chmod +x install.sh
mkdir -p ~/.config/systemd/user
echo "✔ Binary installed to /usr/local/bin/smartcloud"

if [[ "$1" == "--enable-timers" ]]; then
    echo "Creating systemd timers..."
    # Live service
    cat > ~/.config/systemd/user/smartcloud-sync.service <<EOF
[Unit]
Description=SmartCloud Live Sync

[Service]
Type=oneshot
ExecStart=/usr/local/bin/smartcloud sync --mode live
EOF

    # Live timer
    cat > ~/.config/systemd/user/smartcloud-sync.timer <<EOF
[Unit]
Description=Hourly SmartCloud Sync

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Backup service
    cat > ~/.config/systemd/user/smartcloud-backup.service <<EOF
[Unit]
Description=SmartCloud Backup Sync

[Service]
Type=oneshot
ExecStart=/usr/local/bin/smartcloud sync --mode both
EOF

    # Backup timer
    cat > ~/.config/systemd/user/smartcloud-backup.timer <<EOF
[Unit]
Description=Weekly SmartCloud Backup

[Timer]
OnCalendar=Sun 03:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable --now smartcloud-sync.timer
    systemctl --user enable --now smartcloud-backup.timer
    echo "✔ Timers enabled and started"
fi

echo "Installation complete ✅"