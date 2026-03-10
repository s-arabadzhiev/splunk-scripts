Splunk Automation Scripts

A collection of high-quality Bash scripts designed to automate the installation, configuration, and management of **Splunk Enterprise** and **Splunk Universal Forwarder (UF)** on Linux environments.

---

## 🚀 Features

* **Automated OS User Management**: Automatically checks for and creates the `splunk` system user with the correct home directory and shell.
* **Secure Credential Handling**: Utilizes the `user-seed.conf` method to pre-set the Splunk `admin` password, bypassing the manual setup wizard.
* **Automated Downloads**: Includes a built-in URL validator that extracts the direct `.tgz` link even if the user accidentally pastes the full `wget` command from the Splunk website.
* **Systemd Integration**: Configures Splunk to run as a service, enabling auto-start on boot and standard process management via `systemctl`.
* **Permission Enforcement**: Ensures all directories and binaries have the correct ownership (`splunk:splunk`) to prevent permission-related errors.

---

Installation & Usage

1. Clone the Repository
Open your terminal and run:
git clone git@github.com:s-arabadzhiev/splunk-scripts.git
cd splunk-scripts

2. Make Scripts Executable
chmod +x *.sh

3. Run the Installation
You must run these scripts with sudo or as root.

    For Splunk Enterprise:
        sudo ./splunk_install.sh

    For Splunk Universal Forwarder:
        sudo ./splunk_uf_install.sh

## Prerequisites ##
Supported OS: Ubuntu 20.04/22.04+, RHEL/CentOS 8/9, or any Debian-based distribution.

## Privileges ##
Root or Sudo access is required for user creation and service configuration.

## Dependencies ##
 wget, tar, and systemd must be installed on the host system.

## Repository Structure ##
splunk_install.sh: Full Splunk Enterprise deployment script.
splunk_uf_install.sh: Lightweight Universal Forwarder deployment script.
.gitignore: Optimized to exclude Splunk binaries and sensitive metadata while keeping scripts visible.

## Security Best Practices ##
Passwords: These scripts use read -s to prevent your passwords from being displayed on the screen during input.

## Cleanup ##
The downloaded .tgz archives are stored in /tmp and should be cleared after a successful installation to save disk space.

## Secret Management ##
 Do not hardcode passwords directly into these scripts if you plan to share them publicly.

## Contributing ##
Feel free to fork this repository, open issues, or submit pull requests with improvements (e.g., adding support for Splunk Cluster configurations).