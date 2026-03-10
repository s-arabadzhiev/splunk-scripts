#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run the script as root (e.g., sudo ./install_splunk.sh)"
  exit 1
fi

echo "=== Preparation for Splunk installation ==="

# Prompt for passwords
read -s -p "Enter the desired password for the OS user 'splunk': " SPLUNK_OS_PASS
echo
read -s -p "Enter the desired password for Splunk Web (user 'admin'): " SPLUNK_ADMIN_PASS
echo

# Prompt for Splunk download URL and validate
while true; do
    read -p "Please paste the Splunk direct download URL (.tgz): " RAW_INPUT
    
    # Extract URL if the user pasted the entire wget command
    if [[ "$RAW_INPUT" =~ (https?://[^ ]+\.tgz) ]]; then
        SPLUNK_DOWNLOAD_URL="${BASH_REMATCH[1]}"
        echo "Extracted URL: $SPLUNK_DOWNLOAD_URL"
        break
    else
        echo "Error: Invalid URL. Please make sure the link points to a .tgz file."
    fi
done

SPLUNK_ARCHIVE="/tmp/splunk.tgz"
SPLUNK_DIR="/opt/splunk"

# 1. Create splunk OS user
if id "splunk" &>/dev/null; then
    echo "The 'splunk' user already exists at the OS level."
else
    echo "Creating OS user 'splunk'..."
    useradd -m -d /home/splunk -s /bin/bash splunk
    echo "splunk:$SPLUNK_OS_PASS" | chpasswd
fi

# 2. Download and extract Splunk
echo "Downloading Splunk..."
wget -O "$SPLUNK_ARCHIVE" "$SPLUNK_DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    echo "Download failed! Please check your internet connection or URL."
    exit 1
fi

echo "Extracting Splunk to /opt..."
tar -xzf "$SPLUNK_ARCHIVE" -C /opt

# 3. Configure user-seed.conf for secure admin user creation
echo "Generating user-seed.conf..."
mkdir -p "$SPLUNK_DIR/etc/system/local"
cat <<EOF > "$SPLUNK_DIR/etc/system/local/user-seed.conf"
[user_info]
USERNAME = admin
PASSWORD = $SPLUNK_ADMIN_PASS
EOF

# 4. Grant permissions to the splunk user
echo "Setting permissions (chown) for $SPLUNK_DIR..."
chown -R splunk:splunk "$SPLUNK_DIR"

# 5. Configure boot-start with Systemd
echo "Configuring boot-start service..."
$SPLUNK_DIR/bin/splunk enable boot-start -user splunk -systemd-managed 1 --accept-license --answer-yes

# 6. Start Splunk
echo "Starting the Splunk service..."
systemctl start Splunkd
systemctl enable Splunkd

echo "=== Installation completed successfully! ==="
echo "You can access Splunk Web at: http://$(hostname -I | awk '{print $1}'):8000"