#!/bin/bash
# Script to extract user-modified Splunk configurations, XML and Studio Dashboards

SPLUNK_ETC="/opt/splunk/etc"
EXPORT_DIR="$HOME/splunk_lab_export_$(date +"%Y%m%d_%H%M")"

echo "==========================================================="
echo "   Splunk Lab to GitHub Exporter (Classic & Studio)"
echo "==========================================================="

mkdir -p "$EXPORT_DIR/system"
mkdir -p "$EXPORT_DIR/apps"

echo "1. Exporting system-wide local configurations..."
if [ -d "$SPLUNK_ETC/system/local" ]; then
    cp -r "$SPLUNK_ETC/system/local" "$EXPORT_DIR/system/"
    echo "   -> Copied /etc/system/local"
fi

echo "2. Scanning for custom App configurations and Dashboards..."
for app_path in "$SPLUNK_ETC/apps/"*; do
    app_name=$(basename "$app_path")
    
    # Exclude default/built-in Splunk apps
    if [[ ! "$app_name" =~ ^(search|launcher|learned|splunk_.*|introspection_generator_addon)$ ]]; then
        
        # Check for local settings (props, transforms, inputs)
        if [ -d "$app_path/local" ]; then
            echo "   -> Found modifications in: $app_name"
            mkdir -p "$EXPORT_DIR/apps/$app_name/local"
            cp -r "$app_path/local/"* "$EXPORT_DIR/apps/$app_name/local/" 2>/dev/null
        fi
        
        # --- CLASSIC XML DASHBOARDS ---
        if [ -d "$app_path/local/data/ui/views" ]; then
            echo "   -> Found Classic Dashboards (XML) in: $app_name"
            mkdir -p "$EXPORT_DIR/apps/$app_name/local/data/ui/views"
            cp -r "$app_path/local/data/ui/views/"* "$EXPORT_DIR/apps/$app_name/local/data/ui/views/" 2>/dev/null
        fi

        # --- DASHBOARD STUDIO (JSON DEFINITIONS) ---
        # Dashboard Studio saves definitions in 'local/data/ui/definition'
        if [ -d "$app_path/local/data/ui/definition" ]; then
            echo "   -> Found Dashboard Studio (JSON) in: $app_name"
            mkdir -p "$EXPORT_DIR/apps/$app_name/local/data/ui/definition"
            cp -r "$app_path/local/data/ui/definition/"* "$EXPORT_DIR/apps/$app_name/local/data/ui/definition/" 2>/dev/null
        fi
    fi
done

# Fix permissions
chown -R $USER:$USER "$EXPORT_DIR"

echo "==========================================================="
echo "✅ Export complete!"
echo "Location: $EXPORT_DIR"
echo "Format: Classic (XML) and Studio (JSON) included."
echo "==========================================================="
