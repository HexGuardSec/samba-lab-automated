#!/bin/bash

echo "===== New Employee Workstation Setup ====="

# ======================================
# 1/ Update & Install required packages
# ======================================
echo "[INFO] Updating the system..."
sudo apt update && sudo apt upgrade -y
echo "[INFO] Installing required packages..."
sudo apt install -y netplan.io net-tools curl wget cifs-utils

# ===========================
# 2/ Create company groups
# ===========================
sudo groupadd employee 2>/dev/null
sudo groupadd developer 2>/dev/null
sudo groupadd accountant 2>/dev/null

# ===========================
# 3/ Create Linux User
# ===========================
read -p "Enter the new Linux username: " USER_NAME
read -s -p "Enter password for $USER_NAME: " USER_PASS
echo ""

sudo useradd -m -s /bin/bash "$USER_NAME"
echo "$USER_NAME:$USER_PASS" | sudo chpasswd
echo "User $USER_NAME created successfully."

# ===================================
# 4/ Define role and add to groups
# ===================================
echo "Select the role for this user:"
echo "1) accountant"
echo "2) developer"
echo "3) employee"
read -p "Enter choice (1/2/3): " ROLE_CHOICE

case "$ROLE_CHOICE" in
  1)
    ROLE="accountant"
    sudo usermod -aG accountant,employee "$USER_NAME"
    ;;
  2)
    ROLE="developer"
    sudo usermod -aG developer,employee "$USER_NAME"
    ;;
  3)
    ROLE="employee"
    sudo usermod -aG employee "$USER_NAME"
    ;;
  *)
    echo "Unknown role, defaulting to employee."
    ROLE="employee"
    sudo usermod -aG employee "$USER_NAME"
    ;;
esac

echo "User $USER_NAME assigned role: $ROLE"

# =====================================
# 5/ Configure static IP via Netplan
# =====================================
ip a | grep 3:
read -p "Enter the network interface name (e.g., enp0s8): " NET_IF
read -p "Enter static IP with CIDR (e.g.,192.168.56.101/24): " IP_ADDR
read -p "Enter DNS (e.g., 8.8.8.8): " DNS

NETPLAN_FILE="/etc/netplan/01-$USER_NAME.yaml"

sudo tee "$NETPLAN_FILE" > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $NET_IF:
      dhcp4: no
      addresses: [$IP_ADDR]
      nameservers:
        addresses: [$DNS]
EOF

sudo netplan apply
echo "Static IP applied on $NET_IF: $IP_ADDR"

echo "[INFO] Testing connectivity to server..."
if ping -c 3 192.168.56.10 > /dev/null; then
    echo "[SUCCESS] Connection to server successful!"
else
    echo "[ERROR] Could not reach server. Check network configuration."
fi

# =========================
# 6/ Create mount points
# =========================
MOUNT_BASE="/mnt/samba"

if [ "$ROLE" == "accountant" ]; then
    sudo mkdir -p "$MOUNT_BASE/accountant" "$MOUNT_BASE/commun"
elif [ "$ROLE" == "developer" ]; then
    sudo mkdir -p "$MOUNT_BASE/developer" "$MOUNT_BASE/commun"
elif [ "$ROLE" == "employee" ]; then
    sudo mkdir -p "$MOUNT_BASE/commun"
fi

# ======================================
# 7/ Mount Samba shares based on role
# ======================================
read -p "Enter Samba server IP: " SERVER_IP

mount_share() {
    SHARE=$1
    MOUNT_POINT="$MOUNT_BASE/$SHARE"
    sudo mount -t cifs "//$SERVER_IP/$SHARE" "$MOUNT_POINT" \
        -o username="$USER_NAME",password="$USER_PASS",uid="$USER_NAME",vers=3.0,noperm
    if [ $? -eq 0 ]; then
        echo "$SHARE mounted successfully at $MOUNT_POINT"
    else
        echo "Failed to mount $SHARE"
    fi
}

if [ "$ROLE" == "accountant" ]; then
    mount_share "accountant"
    mount_share "commun"
elif [ "$ROLE" == "developer" ]; then
    mount_share "developer"
    mount_share "commun"
elif [ "$ROLE" == "employee" ]; then
    mount_share "commun"
fi

echo "Setup completed for user $USER_NAME."
