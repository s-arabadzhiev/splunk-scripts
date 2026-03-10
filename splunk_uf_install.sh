#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run the script as root (e.g., sudo ./install_uf.sh)"
  exit 1
fi

echo "=== Preparation for Splunk Universal Forwarder (UF) installation ==="

# Prompt for passwords
read -s -p "Enter the desired password for the OS user 'splunk': " SPLUNK_OS_PASS
echo
read -s -p "Enter the desired password for UF Admin: " SPLUNK_ADMIN_PASS
echo

# Prompt for UF download URL and validate
while true; do
    read -p "Please paste the Splunk UF direct download URL (.tgz): " RAW_INPUT
    
    # Extract URL if the user pasted the entire wget command
    if [[ "$RAW_INPUT" =~ (https?://[^ ]+\.tgz) ]]; then
        UF_DOWNLOAD_URL="${BASH_REMATCH[1]}"
        echo "Extracted URL: $UF_DOWNLOAD_URL"
        break
    else
        echo "Error: Invalid URL. Please make sure the link points to a .tgz file for Universal Forwarder."
    fi
done

UF_ARCHIVE="/tmp/splunkforwarder.tgz"
UF_DIR="/opt/splunkforwarder"

# 1. Create splunk OS user
if id "splunk" &>/dev/null; then
    echo "The 'splunk' user already exists."
else
    echo "Creating OS user 'splunk'..."
    useradd -m -d /home/splunk -s /bin/bash splunk
    echo "splunk:$SPLUNK_OS_PASS" | chpasswd
fi

# 2. Download and extract Universal Forwarder
echo "Downloading Splunk UF..."
wget -O "$UF_ARCHIVE" "$UF_DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    echo "Download failed!"
    exit 1
fi

echo "Extracting UF to /opt..."
tar -xzf "$UF_ARCHIVE" -C /opt

# 3. Configure user-seed.conf for secure admin creation
echo "Generating user-seed.conf..."
mkdir -p "$UF_DIR/etc/system/local"
cat <<EOF > "$UF_DIR/etc/system/local/user-seed.conf"
[user_info]
USERNAME = admin
PASSWORD = $SPLUNK_ADMIN_PASS
EOF

# 4. Grant permissions to the splunk user
echo "Setting permissions (chown) for $UF_DIR..."
chown -R splunk:splunk "$UF_DIR"

# 5. Configure boot-start with Systemd (Recommended for Linux)
echo "Configuring boot-start service for UF..."
$UF_DIR/bin/splunk enable boot-start -user splunk -systemd-managed 1 --accept-license --answer-yes

# 6. Start Universal Forwarder
echo "Starting the SplunkForwarder service..."
systemctl start SplunkForwarder
systemctl enable SplunkForwarder

echo "=== UF Installation completed successfully! ==="
echo "Splunk Universal Forwarder is running as user 'splunk'."