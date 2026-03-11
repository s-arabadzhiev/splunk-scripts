#!/bin/bash

# --- DYNAMIC CONFIGURATION ---
# Detect if we are on Splunk Enterprise or Universal Forwarder
if [ -d "/opt/splunk/etc" ]; then
    SPLUNK_ETC="/opt/splunk/etc"
    TYPE="Splunk Enterprise"
elif [ -d "/opt/splunkforwarder/etc" ]; then
    SPLUNK_ETC="/opt/splunkforwarder/etc"
    TYPE="Universal Forwarder"
else
    echo "❌ Error: Splunk installation not found in /opt/splunk or /opt/splunkforwarder"
    exit 1
fi

# Logic to find the real user and their HOME directory
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER="$USER"
    REAL_HOME="$HOME"
fi

# Export path in the user's home directory
BASE_EXPORT_DIR="$REAL_HOME/splunk_exports"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
CURRENT_LAB_DIR="$BASE_EXPORT_DIR/lab_export_$TIMESTAMP"

echo "==========================================================="
echo "   Splunk Lab to GitHub Exporter (Universal Version)"
echo "==========================================================="
echo "Detected Type: $TYPE"
echo "User detected: $REAL_USER"
echo "Target path:   $CURRENT_LAB_DIR"

# Privilege check
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this script with sudo to access Splunk configs."
  exit 1
fi

mkdir -p "$CURRENT_LAB_DIR/system"
mkdir -p "$CURRENT_LAB_DIR/apps"

# 1. Export system-wide local configurations
echo "1. Exporting system-wide local configurations..."
if [ -d "$SPLUNK_ETC/system/local" ]; then
    cp -r "$SPLUNK_ETC/system/local" "$CURRENT_LAB_DIR/system/"
    echo "   -> [OK] /etc/system/local"
fi

# 2. Scanning for custom App configurations and Dashboards
echo "2. Scanning for custom App configurations and Dashboards..."
for app_path in "$SPLUNK_ETC/apps/"*; do
    [ -e "$app_path" ] || continue
    app_name=$(basename "$app_path")
    
    if [[ ! "$app_name" =~ ^(search|launcher|learned|splunk_.*|introspection_generator_addon|framework|gettingstarted|alert_log_export)$ ]]; then
        if [ -d "$app_path/local" ]; then
            echo "   -> [Found] App: $app_name"
            mkdir -p "$CURRENT_LAB_DIR/apps/$app_name/local"
            cp -r "$app_path/local/"* "$CURRENT_LAB_DIR/apps/$app_name/local/" 2>/dev/null
        fi
        
        # Classic Dashboards (mostly for Enterprise)
        if [ -d "$app_path/local/data/ui/views" ]; then
            echo "      - Classic Dashboards found"
            mkdir -p "$CURRENT_LAB_DIR/apps/$app_name/local/data/ui/views"
            cp -r "$app_path/local/data/ui/views/"* "$CURRENT_LAB_DIR/apps/$app_name/local/data/ui/views/" 2>/dev/null
        fi

        # Dashboard Studio (mostly for Enterprise)
        if [ -d "$app_path/local/data/ui/definition" ]; then
            echo "      - Dashboard Studio (JSON) found"
            mkdir -p "$CURRENT_LAB_DIR/apps/$app_name/local/data/ui/definition"
            cp -r "$app_path/local/data/ui/definition/"* "$CURRENT_LAB_DIR/apps/$app_name/local/data/ui/definition/" 2>/dev/null
        fi
    fi
done

# 3. Deployment Server Logic (only for Enterprise)
if [ -d "$SPLUNK_ETC/deployment-apps" ]; then
    echo "3. Scanning for Deployment Apps (Server Role)..."
    mkdir -p "$CURRENT_LAB_DIR/deployment-apps"
    cp -r "$SPLUNK_ETC/deployment-apps/"* "$CURRENT_LAB_DIR/deployment-apps/" 2>/dev/null
    echo "   -> [OK] deployment-apps exported"
fi

# Restore ownership
chown -R "$REAL_USER":"$REAL_USER" "$BASE_EXPORT_DIR"

echo "==========================================================="
echo "✅ Export complete!"
echo "Files are now in: $CURRENT_LAB_DIR"
echo "==========================================================="
