# **Network Architecture – Automated Workstation Deployment Lab**

This lab consists of one Ubuntu Samba server and multiple client workstations created using an automated setup script.

## **Infrastructure Overview**

### **Server**

* **srv-linux (Ubuntu Server)**

  * Hosts all Samba shares
  * Manages permissions based on Linux groups:

    * `employee`
    * `developer`
    * `accountant`

### **Client Workstations**

Client VMs are created and configured with an **automation script** that:

* Creates a Linux user
* Assigns a role (`employee`, `developer`, or `accountant`)
* Mounts only the Samba shares corresponding to the user’s role

Examples:

| Workstation | Role       | Accessible Shares      |
| ----------- | ---------- | ---------------------- |
| Emilie VM   | Accountant | `commun`, `accountant` |
| Clement VM  | Developer  | `commun`, `developer`  |
| Paul VM     | Employee   | `commun` only          |

---

## **Connectivity**

* All machines can ping each other.
* Traffic stays inside the lab (Host-Only or Internal Network).

---

## **Samba Shares & Role-Based Access**

| Share Folder | Group Allowed | Description                 |
| ------------ | ------------- | --------------------------- |
| `commun`     | All users     | Shared company folder       |
| `developer`  | Developer     | Development team resources  |
| `accountant` | Accountant    | Accounting department files |

Each share is mounted with:

* `rw` access
* `uid` set to the local user
* `gid` set to the share group
* `noperm` (permissions handled server-side)

---

# **Diagram**

```
                 +-----------------------+
                 |    HexGuard_server    |
                 |     Samba Server      |
                 +----------+------------+
                            |
         ------------------------------------------------
         |                       |                      |
 +---------------+      +----------------+      +----------------+
 | Emilie VM     |      | Clement VM     |      | Paul VM        |
 | Accountant    |      | Developer      |      | Employee       |
 +---------------+      +----------------+      +----------------+
       |                         |                    |
       |                         |                    |
   commun ------------------- commun --------------- commun
       |                         |  
 accountant                developer
```

This diagram shows which workstation can access which Samba shares based on the user role defined in the automation script.