# Splunk Automation Suite 🛠️

A collection of high-quality Bash scripts designed to automate the installation, configuration, and management of **Splunk Enterprise** and **Splunk Universal Forwarder (UF)** on Linux environments. Perfect for production setups and certification labs.

---

## 🚀 Features

* **Automated OS User Management:** Automatically creates the `splunk` system user with correct permissions.
* **Secure Setup:** Uses `user-seed.conf` to pre-set the admin password securely.
* **Smart Downloads:** Extracts direct links from any Splunk `wget` command automatically.
* **Forwarding Automation:** Quick `outputs.conf` setup for Universal Forwarders.
* **Configuration Backup:** Reliable "Cold Backup" of the `/etc` directory.
* **Lab Exporter:** Export your work from labs to GitHub, including **Classic XML** and **Dashboard Studio (JSON)**.
* **Systemd Integration:** Automated service management and boot persistence.

---

## 📂 Repository Structure

* `splunk_install.sh` - Full Splunk Enterprise deployment.
* `splunk_uf_install.sh` - Lightweight Universal Forwarder deployment.
* `splunk_uf_outputs_config.sh` - Connect UF to an Indexer.
* `splunk_config_backup.sh` - Daily/Manual configuration backup.
* `splunk_lab_exporter.sh` - Extract your lab work (Dashboards & Configs) for GitHub.

---

## 🛠 Installation & Usage

### 1. Clone the Repository
Open your terminal and run:

    git clone git@github.com:s-arabadzhiev/splunk-scripts.git
    cd splunk-scripts

### 2. Make Scripts Executable

    chmod +x *.sh

### 3. Execution Commands
> [!IMPORTANT]
> Always run with **sudo** or as **root**.

**Install Splunk:**
`sudo ./splunk_install.sh` OR `sudo ./splunk_uf_install.sh`

**Configure Forwarding:**
`sudo ./splunk_uf_outputs_config.sh`

**Run Backup:**
`sudo ./splunk_config_backup.sh`

**Export Lab Work (for Portfolio):**
`./splunk_lab_exporter.sh`

---

## 🎓 Certification & Lab Portfolio (Exporting)

If you are working on a cloud lab or certification, use `splunk_lab_exporter.sh` to save your progress:
* It ignores default system files to keep your repo clean.
* It captures **Classic XML Dashboards**.
* It captures **Dashboard Studio (JSON)** definitions.
* It extracts all `local` configurations (props, transforms, inputs).

---

## 📅 Automation (Daily Backups)

To automate the backup script, add it to **cron**:

1. Open crontab: `sudo crontab -e`
2. Add the following line (for 3:00 AM daily):

    00 03 * * * /bin/bash /path/to/splunk-scripts/splunk_config_backup.sh >> /var/log/splunk_backup.log 2>&1

---

## 📋 Prerequisites

* **OS:** Ubuntu 20.04/22.04+, RHEL/CentOS 8/9.
* **Privileges:** Root or Sudo access.
* **Dependencies:** `wget`, `tar`, `systemd`.

---

## 🛡 Security & Connectivity

* **Passwords:** Uses `read -s` to prevent password leaks in terminal history.
* **Firewall:** Remember to open port **9997** on your Indexer.
* **Backup Scope:** Focuses on `/etc/` (configs/apps), excluding raw data buckets to save space.

---

## 🤝 Contributing
Feel free to fork this repository, open issues, or submit pull requests!
