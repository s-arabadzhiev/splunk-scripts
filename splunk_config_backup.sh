#!/bin/bash

# --- CONFIGURATION ---
SPLUNK_HOME="/opt/splunk"
BACKUP_DIR="/opt/splunk_backups"
RETENTION_DAYS=7
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_NAME="splunk_etc_backup_$TIMESTAMP.tgz"
LOCKFILE="/tmp/splunk_backup.lock"

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

# Prevent multiple instances
if [ -e "$LOCKFILE" ]; then
    echo "Backup already in progress. Exiting."
    exit 1
fi
touch "$LOCKFILE"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "[$(date)] --- Starting Daily Splunk Backup ---"

# 1. Stop Splunk
echo "Stopping Splunk service..."
"$SPLUNK_HOME/bin/splunk" stop

# 2. Create Archive
echo "Archiving /etc directory..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$SPLUNK_HOME" etc

if [ $? -eq 0 ]; then
    echo "✅ Success: Backup saved to $BACKUP_DIR/$BACKUP_NAME"
else
    echo "❌ Error: Backup failed!"
    rm -f "$LOCKFILE"
    "$SPLUNK_HOME/bin/splunk" start
    exit 1
fi

# 3. Start Splunk
echo "Starting Splunk service..."
"$SPLUNK_HOME/bin/splunk" start

# 4. Retention (Cleanup)
echo "Removing backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -name "splunk_etc_backup_*.tgz" -mtime +$RETENTION_DAYS -delete

rm -f "$LOCKFILE"
echo "[$(date)] --- Backup Process Complete ---"
