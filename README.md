# **Automated Workstation Deployment – Samba Role-Based Access Lab**

This project automates the deployment of Linux workstations in a corporate environment using a Bash script.
Each workstation is configured to automatically:

* Create a user
* Assign a role (employee, developer, or accountant)
* Mount only the appropriate Samba shares based on that role
* Apply network configuration
* Prepare the system with required packages

The goal of the lab is to simulate a real corporate onboarding workflow.

---

## **📌 Features**

### **🔐 User Creation & Role Assignment**

The script automatically:

* Creates a new Linux user
* Assigns them to the correct Linux groups
* Ensures consistent group-based access control

### **🗂️ Samba Auto-Mounting**

Depending on the selected role:

| Role       | Shares Mounted         |
| ---------- | ---------------------- |
| Employee   | `commun`               |
| Developer  | `commun`, `developer`  |
| Accountant | `commun`, `accountant` |

All shares are mounted using:

```
noperm, uid=<user>, gid=<group>, vers=3.0
```

This ensures local access works even though permissions are handled server-side.

### **🌐 Network Configuration**

The script automatically:

* Detects interfaces
* Applies static IP configuration through Netplan

### **📦 Package Installation**

It installs all required dependencies:

* net-tools
* netplan
* curl / wget

---

## **📁 Repository Structure**

```
.
├── documentation/
│   ├── architecture.md
│   └── screenshots/
├── scripts/
│   └── Setup_user.sh
├── README.md
└── LICENSE
```

---

## **🛠️ How It Works**

### 1️⃣ Launch the script

```
sudo bash Setup_user.sh
```

### 2️⃣ Provide user information

* Username
* Password
* Role (employee / developer / accountant)

### 3️⃣ Provide network configuration

* Interface name
* IP address
* Gateway
* DNS

### 4️⃣ Provide Samba server IP

The script mounts the appropriate folders based on role and creates mount points automatically.

---

## **📂 Share Mounting Logic**

### Always mounted:

✔ `commun`

### Role-specific:

* **Developer** → `/mnt/samba/developer`
* **Accountant** → `/mnt/samba/accountant`

If the role does not match, no mount point or share is created.

This ensures:

* Clean workstation
* No unauthorized visibility of other departments' folders
* Proper corporate-like segmentation

---

## **🧼 Resetting a Workstation (Cleanup)**

To remove all mounts and associated directories:

```
sudo umount /mnt/samba/commun 2>/dev/null
sudo umount /mnt/samba/developer 2>/dev/null
sudo umount /mnt/samba/accountant 2>/dev/null

sudo rm -rf /mnt/samba/commun /mnt/samba/developer /mnt/samba/accountant
```

To delete a user:

```
sudo userdel -r username
```

---

## **🖼️ Documentation**

All architecture and screenshots are available in:

```
documentation/
├── architecture.md
└─── screenshots/
```

---

## **🎯 Objective of the Lab**

This lab simulates:

* Corporate onboarding workflow
* Role-based file access
* Automated machine provisioning
* Network and Samba configuration

It provides a realistic environment for learning Linux administration and automation.