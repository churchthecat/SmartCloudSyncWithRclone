# SmartCloudSyncWithRclone

SmartCloudSyncWithRclone is a lightweight automation layer around **rclone** that provides structured, configurable cloud synchronization using simple folder rules.

It works with any rclone-supported remote and is designed for personal cloud backups with automation support.

Features:

* Folder-based sync configuration
* Global exclusion rules
* Custom remote path mapping
* Bandwidth limiting
* Systemd timer automation
* Lock protection
* Clean CLI interface

---

# 📦 Project Structure

```
SmartCloudSyncWithRclone/

scripts/
└── main.sh

sync_engine.sh

config/
├── config.sh
└── folders.conf

tools/
└── helper scripts

install.sh
README.md
```

---

# 🔧 Requirements

Install required software:

```
sudo apt install rclone
```

Or install from:

https://rclone.org/install/

You must also have:

* bash
* systemd (optional for automated scheduling)

---

# 🚀 Installation

Clone the repository:

```
git clone https://github.com/your-username/SmartCloudSyncWithRclone.git
cd SmartCloudSyncWithRclone
```

Install the tool:

```
./install.sh
```

Reload shell command cache:

```
hash -r
```

Verify installation:

```
smartcloud version
```

---

# 🔑 Step 1 — Configure rclone Remote

Before using SmartCloud, create a remote in rclone.

Run:

```
rclone config
```

Create a remote and assign it a name:

Example:

```
myremote
```

Test it:

```
rclone ls myremote:
```

SmartCloud will use this remote name inside its configuration.

---

# ⚙ Step 2 — Configure SmartCloud

Edit:

```
config/config.sh
```

Example:

```
REMOTE_NAME="myremote"
REMOTE_ROOT="backup-root"
LOG_FILE="$HOME/smartcloud.log"
```

---

# 📂 Step 3 — Configure Folder Rules

Edit:

```
config/folders.conf
```

This file defines which local folders are synced and where they are stored remotely.

Example:

```
# Folder mappings

/home/user/Documents -> backup-root/Documents
/home/user/Music -> backup-root/Music
/home/user/Pictures -> backup-root/Pictures
/home/user/Videos -> backup-root/Videos


EXCLUDE:
Downloads/**
.cache/**
.local/**
node_modules/**
*.tmp
```

Rules:

* Each line maps: local path → remote path
* Exclusions apply globally
* Exclusions are relative to the sync root

---

# ▶ Usage

Run manual sync:

```
smartcloud sync
```

Run combined mode:

```
smartcloud sync --mode both
```

Run live-only sync:

```
smartcloud sync --mode live
```

---

# ⏰ Automatic Scheduling (Systemd Timer)

If systemd is enabled, SmartCloud can run automatically.

List timers:

```
systemctl --user list-timers
```

Restart service:

```
systemctl --user restart smartcloud-sync.service
```

View logs:

```
journalctl --user -u smartcloud-sync.service -f
```

---

# 🔐 Lock Protection

SmartCloud prevents overlapping sync jobs using a lock file:

```
/tmp/smartcloud.lock
```

If another sync is already running:

```
SmartCloud already running. Exiting.
```

---

# 📊 Logging

Logs are written to:

```
~/smartcloud.log
```

Monitor live:

```
tail -f ~/smartcloud.log
```

---

# 🛑 Exclusion Rules

Exclusions are defined after the `EXCLUDE:` section in `folders.conf`.

Example:

```
EXCLUDE:
Downloads/**
.cache/**
node_modules/**
dist/**
*.tmp
*.part
```

These are passed directly to rclone via `--exclude-from`.


---

# 🔮 Future Improvements

Planned:

* `smartcloud status`
* `smartcloud doctor`
* real-time filesystem watch mode
* improved bandwidth control
* multi-user support

---

# License

MIT
