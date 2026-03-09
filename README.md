# SmartCloudSyncWithRclone

SmartCloudSyncWithRclone is a bash-based synchronization tool built on top of rclone for Linux. It allows selective folder syncing to cloud remotes, dry-run previews, mirror deletes, and skipping empty files automatically.

## Setup

Clone the repository:

git clone https://github.com/YOUR_USER/SmartCloudSyncWithRclone.git
cd SmartCloudSyncWithRclone

Copy the example configuration and edit it:

cp config/config.example.sh config/config.sh
nano config/config.sh

Edit placeholders for REMOTE (your cloud remote) and HOME_DIR (your local root path). Optionally adjust TRANSFERS, CHECKERS, BWLIMIT, DELETE, and MODE.

Make scripts executable:

chmod +x sync_engine.sh
chmod +x scripts/main.sh

Optional: install globally:

sudo ln -sf $(pwd)/scripts/main.sh /usr/local/bin/smartcloud

## Folder Mapping

Edit `config/folders.conf` to map local → remote paths. Example:

Music:Music
Torrents:Torrents
Documents:Private/DEVICE/Documents
Pictures:Private/DEVICE/Pictures
Videos:Private/DEVICE/Videos
Desktop:Private/DEVICE/Desktop


- Music and Torrents sync to remote root.
- Other folders sync under Private/DEVICE/.

## Usage

Dry-run (preview changes):

smartcloud --dry-run

Live sync:

smartcloud

## Excluding Files

Edit `config/exclude.conf` to skip unwanted files or folders. Example:

*.part
*.torrent
.cache/**
.local/**
.snap/**
.local/share/Trash/**

## Notes

- Empty files are skipped automatically.
- Mirror delete is optional via DELETE=true in config.sh.
- Supports dry-run and live sync modes.
- Safe for rate-limited cloud remotes.