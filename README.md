# SmartCloudSyncWithRclone

**SmartCloudSyncWithRclone** is a Bash-based synchronization tool for Linux, built on top of [rclone](https://rclone.org/). It allows selective folder syncing to cloud remotes, dry-run previews, mirror deletes, and skipping empty files automatically.

---

## Features

- Sync multiple local folders to cloud remotes
- Dry-run mode to preview changes
- Optional mirror delete
- Skips empty files automatically
- Supports rclone-compatible cloud remotes
- Handles rate-limited remotes safely

---

## Requirements

- Linux
- [rclone](https://rclone.org/) installed and configured
- Bash shell (tested on Bash 5+)

---

## Setup

**Clone the repository**

```bash
git clone https://github.com/churchthecat/SmartCloudSyncWithRclone.git
cd SmartCloudSyncWithRclone
```
**Copy and edit the configuration**
```
cp config/config.example.sh config/config.sh
nano config/config.sh
```
**Update placeholders: REMOTE (your cloud remote) and HOME_DIR (local root path)**

Optional: adjust TRANSFERS, CHECKERS, BWLIMIT, DELETE, and MODE

**Make scripts executable**
```
chmod +x sync_engine.sh
chmod +x scripts/main.sh
```
**Optional: install globally**
```
sudo ln -sf $(pwd)/scripts/main.sh /usr/local/bin/smartcloud
```
**Folder Mapping**
Edit config/folders.conf to map local → remote paths. Example:
```
Music:Music
Torrents:Torrents
Documents:Private/DEVICE/Documents
Pictures:Private/DEVICE/Pictures
Videos:Private/DEVICE/Videos
Desktop:Private/DEVICE/Desktop
```
Music and Torrents sync to the remote root.

Other folders sync under Private/DEVICE/.

**Usage**
```
Preview changes (dry-run)
```
```
smartcloud --mode dry-run
```
```
Perform live sync
```
```
smartcloud
```

Additional options
```
smartcloud --mode live --extra "--size-only"
```
**Excluding Files**

Edit config/exclude.conf to skip unwanted files or folders. Example:
```
*.part
*.torrent
.cache/**
.local/**
.snap/**
.local/share/Trash/**
```
Notes

Empty files are skipped automatically

Mirror delete is optional via DELETE=true in config.sh

Safe to use with rate-limited cloud remotes

Works on Linux with Bash and rclone


```
