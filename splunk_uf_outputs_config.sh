#!/bin/bash
# Script to configure outputs.conf on Splunk UF

UF_DIR="/opt/splunkforwarder"

echo "==========================================================="
echo "   Splunk Universal Forwarder - Output Configuration"
echo "==========================================================="

read -p "Enter Indexer IP or Hostname: " INDEXER_IP
read -p "Enter Receiving Port (default 9997): " RECV_PORT
RECV_PORT=${RECV_PORT:-9997}

echo ""
echo "-----------------------------------------------------------"
echo "⚠️  IMPORTANT: FIREWALL REQUIREMENTS"
echo "Ensure that port $RECV_PORT is OPEN on the Indexer side."
echo "If you are using ufw (Ubuntu) or firewalld (RHEL):"
echo "Example (RHEL): sudo firewall-cmd --add-port=$RECV_PORT/tcp --permanent"
echo "Example (Ubuntu): sudo ufw allow $RECV_PORT/tcp"
echo "-----------------------------------------------------------"
echo ""

read -p "Press [Enter] to continue with the configuration..."

echo "Configuring outputs.conf..."
mkdir -p "$UF_DIR/etc/system/local"

cat <<EOF > "$UF_DIR/etc/system/local/outputs.conf"
[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = $INDEXER_IP:$RECV_PORT

[tcpout-server://$INDEXER_IP:$RECV_PORT]
EOF

chown -R splunk:splunk "$UF_DIR/etc/system/local/outputs.conf"

echo "Restarting Splunk UF to apply changes..."
$UF_DIR/bin/splunk restart

echo ""
echo "✅ Configuration complete and UF restarted."
echo "Check connectivity using: $UF_DIR/bin/splunk list forward-server"
