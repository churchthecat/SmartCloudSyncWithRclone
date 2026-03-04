# SmartCloudSyncWithRclone

SmartCloudSyncWithRclone is an automated cloud sync and mount manager built around **rclone + systemd**.

It provides:

- Automatic cloud mounting
- Folder-based sync configuration
- Live / Backup / Hybrid sync modes
- Bandwidth control
- Systemd integration
- Automated release packaging
- Installer script
- Version tracking via git tags

---

# 🚀 Installation

### Clone Repository

```bash
git clone git@github.com:churchthecat/SmartCloudSyncWithRclone.git
cd SmartCloudSyncWithRclone
```

### Install

```bash
chmod +x install.sh
./install.sh
```

This will:

- Symlink `smartcloud` to `/usr/local/bin`
- Make scripts executable

---

# 🚀 Usage

## Setup

```bash
smartcloud setup
```

Creates:

- Remote configuration
- Folder mapping setup

---

## Sync

```bash
smartcloud sync --mode live
smartcloud sync --mode backup
smartcloud sync --mode both
```

| Mode   | Description |
|--------|------------|
| live   | One-way live sync |
| backup | Backup to cloud |
| both   | Run both strategies |

---

## Release

Generate packaged release:

```bash
tools/create_release.sh
```

It creates:

```
release/SmartCloudSyncWithRclone-vX.X.X.tar.gz
release/SmartCloudSyncWithRclone-vX.X.X.sha256
```

---

# 🚀 Versioning

Version is automatically detected from git tags:

```bash
git tag -a v1.1.0 -m "Release message"
git push origin v1.1.0
```

The tool prints the version when executed.

---

# 📂 Project Structure

```
scripts/      Core engine
tools/        Helpers & release builder
config/       Configuration templates
release/      Packaged builds
install.sh    Installer
README.md     Documentation
```

---

# 🔐 Security

Do NOT commit:

- `config/folders.conf`
- Secrets
- rclone credentials

Use `folders.example.conf` as template.

---

# 📜 License

MIT
