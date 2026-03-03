# SmartCloudSyncWithRclone

🚀 Portable cloud automation framework built on top of rclone.

Supports:

- Live folder mirroring
- Versioned backup snapshots
- Hybrid mode (live + backup)
- Custom folder mapping
- Automatic bandwidth detection
- Network awareness
- Battery awareness
- Portable deployment via GitHub

---

# 📦 Modes

You can choose how sync behaves:

## ✅ Live Mode (Default)

Real-time mirror behavior.

Files:
- Updated
- Deleted
- Added

Are mirrored to the cloud.

```bash
smartcloud sync --mode live
```

Or:

```bash
smartcloud sync
```

---

## 🧊 Backup Mode

Creates timestamped backup snapshots.

Instead of mirroring, it copies data into:

```
<destination>_backup_YYYYMMDD_HHMMSS
```

Files accumulate as versions.

```bash
smartcloud sync --mode backup
```

---

## 🔥 Hybrid Mode

Runs:

1. Live sync
2. Backup snapshot

In one execution.

```bash
smartcloud sync --mode both
```

---

# ⚙ Setup

## Install

```bash
chmod +x install.sh
./install.sh
```

---

## Configure Remote

If not configured:

```bash
rclone config
```

Then:

```bash
smartcloud setup
```

---

## Configure Folders

Copy template:

```bash
cp config/folders.example.conf config/folders.conf
```

Edit:

```bash
nano config/folders.conf
```

Example:

```
/home/user/Documents -> Backup/Documents
/home/user/Music     -> Media/Music

EXCLUDE:
Downloads/**
.cache/**
.snap/**
```

---

## Run Sync

```bash
smartcloud sync --mode live
smartcloud sync --mode backup
smartcloud sync --mode both
```

---

## Build Release Package

```bash
smartcloud release
```

Creates:

```
release/SmartCloudSyncWithRclone-VERSION.tar.gz
```

---

# 🔒 Architecture

Core components:

```
scripts/
 ├── main.sh
 ├── sync_engine.sh
 ├── bandwidth.sh
 ├── validator.sh
 └── remote_setup.sh

tools/
 ├── interactive_builder.sh
 └── release_builder.sh
```

---

# 🚀 Roadmap

Future features:

- Restore command
- Snapshot rotation (auto cleanup)
- Snapshot browser
- Incremental backup mode
- Web dashboard
- Encryption layer
- Auto GitHub release publishing
- Windows version
---
