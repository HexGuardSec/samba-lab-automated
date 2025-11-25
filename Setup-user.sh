#!/bin/bash

echo "===== New Employee Workstation Setup ====="

# =======================
# 1/ Create Linux User
# =======================
read -p "Enter the new Linux username: " USER_NAME
read -s -p "Enter password for $USER_NAME: " USER_PASS
echo ""

sudo useradd -m -s /bin/bash $USER_NAME
echo "$USER_NAME:$USER_PASS" | sudo chpasswd
echo "User $USER_NAME created successfully."

# ===================================
# 2/ Define role and add to groups
# ===================================

echo "Select the role for this user:"
echo "1) accountant"
echo "2) developer"
echo "3) employee"
read -p "Enter choice (1/2/3): " ROLE_CHOICE

case "$ROLE_CHOICE" in
  1)
	ROLE="accountant"
	sudo usermod -aG accountant,employee $USER_NAME
	;;
  2)
	ROLE="developer"
	sudo usermod -aG developer,employee $USER_NAME
	;;
  3)
	ROLE="employee"
	sudo usermod -aG employee $USER_NAME
	;;
  *)
	echo "Unknow role, defaulting to employee."
	ROLE="employee"
	sudo usermod -aG employee $USER_NAME
	;;
esac


echo "User $USER_NAME assigned role: $ROLE"
