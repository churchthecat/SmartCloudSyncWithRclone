# SmartCloudSyncWithRclone

SmartCloudSyncWithRclone is a lightweight automation layer around rclone that provides:

- Folder-based cloud sync
- Exclusion support
- Custom remote mapping
- Bandwidth control
- Systemd timer automation
- Lock protection to prevent overlapping sync jobs

Designed for personal private cloud backup using Internxt (or any rclone-supported remote).

------------------------------------------------------------

## 🚀 Features

✅ Sync entire home directory with exclusions  
✅ Override specific folders to custom remote paths  
✅ Exclude Downloads / cache / temporary files  
✅ Automatic systemd timer scheduling  
✅ Lock protection to prevent overlapping sync  
✅ Bandwidth-aware sync engine  
✅ Clean CLI interface  

------------------------------------------------------------

## 📦 Project Structure

SmartCloudSyncWithRclone/

├── scripts/  
│   └── main.sh  

├── sync_engine.sh  

├── config/  
│   ├── config.sh  
│   └── folders.conf  

├── tools/  
│   └── utility scripts  

└── install.sh  

------------------------------------------------------------

## 🔧 Installation

Clone:

git clone git@github.com:churchthecat/SmartCloudSyncWithRclone.git  
cd SmartCloudSyncWithRclone  

Install:

./install.sh  

Reload shell:

hash -r  

------------------------------------------------------------

## ▶ Usage

### Run Manual Sync

smartcloud sync  

### Sync with both modes

smartcloud sync --mode both  

### View Version

smartcloud version  

------------------------------------------------------------

## ⏰ Automatic Scheduling (Systemd Timer)

Check timers:

systemctl --user list-timers  

View logs:

journalctl --user -u smartcloud-sync.service -f  

------------------------------------------------------------

## 🔐 Lock Protection

SmartCloud prevents overlapping sync jobs using:

/tmp/smartcloud.lock  

If a sync is already running:

⚠ SmartCloud already running. Exiting.

------------------------------------------------------------

## 📂 Folder Configuration

Edit:

config/folders.conf  

Example:

/home/anders -> privat/2_HP_pav  

/home/anders/Music     -> privat/Music  
/home/anders/Torrents  -> privat/Torrents  

EXCLUDE:  
Downloads/**  
.cache/**  
.snap/**  

Rules:

- Custom folder mappings are processed first  
- Root backup runs after  
- Exclusions apply globally  

------------------------------------------------------------

## 🛑 Exclusions

You can exclude:

node_modules/**  
dist/**  
build/**  
*.tmp  

These are passed directly to rclone via --exclude-from.

------------------------------------------------------------

## 📊 Logging

Sync logs are stored in:

~/smartcloud.log  

Monitor live:

tail -f ~/smartcloud.log  

------------------------------------------------------------

## 🛡 Safety

- No duplicate sync execution  
- Timer safe restart  
- Script path auto-detection  
- Clean project-root resolution  
- Config-driven  

------------------------------------------------------------

## 🔮 Future Improvements

Planned upgrades:

- smartcloud status  
- smartcloud doctor  
- Live filesystem watcher mode  
- Better bandwidth auto-detection  
- Multi-user support  

------------------------------------------------------------

Built for automation. Built for control.