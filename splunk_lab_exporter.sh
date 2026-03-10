#!/bin/bash

# --- CONFIGURATION ---
SPLUNK_ETC="/opt/splunk/etc"

# Logic to find the real user and their HOME directory
if [ -n "$SUDO_USER" ]; then
    # If run with sudo, get the name of the user who initiated it
    REAL_USER="$SUDO_USER"
    # Find their home directory via the system password database
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    # If run directly (without sudo)
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

# Export path in the user's home directory
BASE_EXPORT_DIR="$REAL_HOME/splunk_exports"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
CURRENT_LAB_DIR="$BASE_EXPORT_DIR/lab_export_$TIMESTAMP"

echo "==========================================================="
echo "   Splunk Lab to GitHub Exporter (Fix: User Context)"
echo "==========================================================="
echo "User detected: $REAL_USER"
echo "Target path: $CURRENT_LAB_DIR"

# Privilege check (Splunk ETC requires root access for reading)
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this script with sudo to access Splunk configs."
  exit 1
fi

# Create export directories
mkdir -p "$CURRENT_LAB_DIR/system"
mkdir -p "$CURRENT_LAB_DIR/apps"

echo "1. Exporting system-wide local configurations..."
if [ -d "$SPLUNK_ETC/system/local" ]; then
    cp -r "$SPLUNK_ETC/system/local" "$CURRENT_LAB_DIR/system/"
    echo "   -> [OK] /etc/system/local"
fi

echo "2. Scanning for custom App configurations and Dashboards..."
for app_path in "$SPLUNK_ETC/apps/"*; do
    app_name=$(basename "$app_path")
    
    # List of apps to ignore (default Splunk apps)
    if [[ ! "$app_name" =~ ^(search|launcher|learned|splunk_.*|introspection_generator_addon|framework|gettingstarted|alert_log_export)$ ]]; then
        
        # Check for local settings
        if [ -d "$app_path/local" ]; then
            echo "   -> [Found] App: $app_name"
            mkdir -p "$CURRENT_LAB_DIR/apps/$app_name/local"
            cp -r "$app_path/local/"* "$CURRENT_LAB_DIR/apps/$app_name/local/" 2>/dev/null
        fi
        
        # --- CLASSIC XML DASHBOARDS ---
        if [ -d "$app_path/local/data/ui/views" ]; then
            echo "      - Classic Dashboards found"
            mkdir -p "$CURRENT_LAB_DIR/apps/$app_name/local/data/ui/views"
            cp -r "$app_path/local/data/ui/views/"* "$CURRENT_LAB_DIR/apps/$app_name/local/data/ui/views/" 2>/dev/null
        fi

        # --- DASHBOARD STUDIO (JSON) ---
        if [ -d "$app_path/local/data/ui/definition" ]; then
            echo "      - Dashboard Studio (JSON) found"
            mkdir -p "$CURRENT_LAB_DIR/apps/$app_name/local/data/ui/definition"
            cp -r "$app_path/local/data/ui/definition/"* "$CURRENT_LAB_DIR/apps/$app_name/local/data/ui/definition/" 2>/dev/null
        fi
    fi
done

# --- CRITICAL STEP: Restore file ownership ---
# Since the script runs as root, files are created as root.
# This step transfers ownership back to the real user.
chown -R "$REAL_USER":"$REAL_USER" "$BASE_EXPORT_DIR"

echo "==========================================================="
echo "✅ Export complete!"
echo "Files are now in: $CURRENT_LAB_DIR"
echo "You can now push these to GitHub without sudo."
echo "==========================================================="
