# SmartCloudSyncWithRclone

![License](https://img.shields.io/badge/license-MIT-blue)
![Status](https://img.shields.io/badge/status-production--ready-green)
![Shell](https://img.shields.io/badge/language-bash-yellow)

SmartCloudSyncWithRclone is a lightweight automation layer around **rclone** that provides structured, configurable cloud synchronization using folder-based rules.

It is designed for:

- Personal cloud backups
- Automated synchronization
- Self-hosted storage replication
- Secure local → remote mirroring

---

# 🚀 Architecture

SmartCloud consists of:

```
smartcloud (CLI)
 ├── main.sh
 ├── sync_engine.sh
 ├── configure.sh
 └── install.sh
```

Workflow:

```
User → smartcloud CLI
         ↓
  Parses config
         ↓
  Executes rclone sync
         ↓
  Applies exclusions + bandwidth + timers
```

Automation (optional):

- Hourly live sync
- Weekly backup sync
- Systemd user timers

---

# 📦 Features

✅ Folder-based sync configuration  
✅ Global exclusion rules  
✅ Remote base path support  
✅ Bandwidth throttling  
✅ Lock protection  
✅ Optional systemd automation  
✅ Interactive configuration CLI  
✅ Safe public repository design  

---

# 🔧 Requirements

Install dependencies:

```bash
sudo apt install rclone bash
```

Or install rclone manually:

https://rclone.org/install/

Systemd is optional but recommended for automation.

---

# 🚀 Installation

Clone:

```bash
git clone https://github.com/your-username/SmartCloudSyncWithRclone.git
cd SmartCloudSyncWithRclone
```

Install binary only:

```bash
bash install.sh
```

Install with systemd timers:

```bash
bash install.sh --enable-timers
```

Reload shell:

```bash
hash -r
```

Verify:

```bash
smartcloud version
```

---

# 🔐 Initial Setup

Configure everything safely using the interactive CLI:

```bash
smartcloud config
```

This will:

- Ask for remote name
- Ask for remote base path
- Configure bandwidth
- Add folder mappings
- Add exclusions
- Optionally enable timers

It generates:

```
config/config.sh
config/folders.conf
```

⚠ These files should NOT be committed to git.

---

# 📂 Folder Configuration

Edit:

```
config/folders.conf
```

Example:

```
/home/user/Documents -> Documents
/home/user/Music     -> Music

EXCLUDE:
Downloads/**
.cache/**
node_modules/**
*.tmp
*.part
```

Format:

```
LOCAL_PATH -> REMOTE_PATH
```

Remote path is relative to the configured `REMOTE_BASE_PATH`.

---

# ▶ Usage

Manual live sync:

```bash
smartcloud sync --mode live
```

Live + backup:

```bash
smartcloud sync --mode both
```

Check system status:

```bash
smartcloud status
```

Show version:

```bash
smartcloud version
```

---

# ⏰ Automatic Scheduling (Optional)

If enabled via `install.sh --enable-timers`:

- Live mode runs hourly
- Backup mode runs weekly

Check timers:

```bash
systemctl --user list-timers
```

Restart service:

```bash
systemctl --user restart smartcloud-sync.service
```

View logs:

```bash
journalctl --user -u smartcloud-sync.service -f
```

---

# 📊 Logging

Logs are stored at:

```
~/smartcloud.log
```

Monitor in real time:

```bash
tail -f ~/smartcloud.log
```

---

# 🔒 Security & Safety

Never commit:

```
config/config.sh
config/folders.conf
smartcloud.log
```

Add to `.gitignore`:

```
config/
*.log
/tmp/
```

SmartCloud prevents:

- Overlapping sync jobs
- Accidental recursive syncing into project root
- Timer collisions

---

# 🏗 Project Structure

```
SmartCloudSyncWithRclone/

scripts/
 ├── main.sh
 ├── sync_engine.sh
 ├── configure.sh
 └── install.sh

config/
 ├── config.sh
 └── folders.conf

README.md
```

---

# 🤝 Contributing

Pull requests are welcome.

Before submitting:

- Run `shellcheck` on scripts
- Test manual sync
- Verify timers if enabled

---

# 🛣 Roadmap

Future improvements:

- `smartcloud doctor`
- File system watch mode
- Parallel multi-remote sync
- Snapshot versioning mode
- Docker deployment support

---

# 📜 License

MIT