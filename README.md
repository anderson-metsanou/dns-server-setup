# DNS Server Setup Guide

This guide provides a step-by-step process for setting up a DNS server using BIND on a Linux VM for testing and understanding purposes.

## Quick Start Guide

### Prerequisites

- A local machine with virtualization support (we will use KVM)
- A Linux distribution ISO (e.g., Debian Server)

### Steps

1. **Download the Debian server OS ISO Image**
   - Locate the netinst version and download it https://www.debian.org/download

2. **Install KVM Packages**
   - Check if your CPU supports virtualization:
     ```bash
     egrep -c '(vmx|svm)' /proc/cpuinfo
     ```
   - Check if your CPU is 64-bit:
     ```bash
     egrep -c ' lm ' /proc/cpuinfo
     ```
   - Install necessary packages:
     ```bash
     sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
     ```
   - Add your user to the libvirt group:
     ```bash
     sudo usermod -aG libvirt $USER
     newgrp libvirt
     ```
   - Log out and log back in to apply changes.

3. **Create a VM**
   - Use the `virt-manager` command.
   - Browse to `localhost` to select the previously downloaded image.
   - For networking settings, you can leave as default.

4. **Install the OS on the VM**
   - Choose "Install" for installation options.
   - Set eg.
     - Time Zone to "South Africa",
     - Archive Packages to "Canada",
     - Domain Name to "anderson237.com",
     - Install GRUB on the default partition,
     - And proceed through all steps of installation.

5. **Access the VM**
   - Log in with the created user during the OS installation process.

6. **Configure the `sudo` Command**
   - Log in as root with the `su` command and the created password during the installation process.
   - As root, install the `sudo` command:
     ```bash
     apt install sudo
     ```
   - Set the correct path for root CLI tools:
     ```bash
     export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
     ```
   - Add the created user to the `sudo` group:
     ```bash
     adduser username sudo
     ```
   - Exit as root, exit as user, and log back in. As a user, test:
     ```bash
     sudo apt update
     ```

7. **Enable Clipboard and Screen Scrolling (this section is not completed yet)**
   - Try to enable clipboard and screen scrolling on add hardware.

8. **Check Network Connectivity**
   - Ping `google.com` and `github.com` from the server and ping the server from the local host.

9. **Install BIND9 Packages**
   ```bash
   sudo apt install bind9 bind9utils bind9-doc


## Detailed Steps for BIND9 Configuration and Testing

10. **Configure BIND9**
    - Enable BIND9 to start at boot:
      ```bash
      sudo systemctl enable named-resolvconf.service
      ```
    - Install `resolvconf`:
      ```bash
      sudo apt install resolvconf
      ```
    - Start BIND9:
      ```bash
      sudo systemctl start named-resolvconf.service
      ```
    - Verify service status:
      ```bash
      sudo systemctl status named-resolvconf.service
      ```
    - Check `/etc/resolv.conf` to ensure that the IP `127.0.0.1` is mapped as the nameserver.
    - Test DNS resolution:
      ```bash
      nslookup google.com 127.0.0.1
      ```

11. **Configure the Primary Zone File**
    - Check the system's domain name if configured (on the DNS server itself):
      ```bash
      hostname -d
      ```
    - Edit `/etc/bind/named.conf.local`:
      ```plaintext
      zone "anderson237.com" {
          type master;
          file "/etc/bind/zones/db.anderson237.com";
      };
      ```

12. **Create the Zone Directory and Add Records**
    - Create the directory where zones will be stored:
      ```bash
      sudo mkdir -p /etc/bind/zones
      ```
    - Add a A record to `/etc/bind/zones/db.anderson237.com`:
      ```plaintext
      $TTL 604800
      @   IN  SOA  omega.anderson237.com. admin.anderson237.com. (
              2025032701  ; Serial
              604800      ; Refresh
              86400       ; Retry
              2419200     ; Expire
              604800 )    ; Negative Cache TTL

      ; Name Server
      @   IN  NS  omega.anderson237.com.

      ; A Records
      ns1 IN  A   192.168.122.166
      www IN  A   192.168.122.166
      mail IN  A   192.168.122.166

      ; MX Record (Mail Server)
      @   IN  MX  10 mail.anderson237.com.
      ```

13. **Configure Reverse DNS Record**
    - Edit `/etc/bind/named.conf.local` to add:
      ```plaintext
      zone "122.168.192.in-addr.arpa" {
          type master;
          file "/etc/bind/zones/db.192.168.122";
      };
      ```
    - Create a zone file for it `/etc/bind/zones/db.192.168.122`:
      ```plaintext
      $TTL 604800
      @   IN  SOA  omega.anderson237.com. admin.anderson237.com. (
              2025032701  ; Serial
              604800      ; Refresh
              86400       ; Retry
              2419200     ; Expire
              604800 )    ; Negative Cache TTL

      ; Name Server
      @   IN  NS  omega.anderson237.com.

      ; PTR Record (Reverse Lookup)
      166 IN  PTR  omega.anderson237.com.
      166 IN  PTR  www.anderson237.com.
      166 IN  PTR  mail.anderson237.com.
      ```

14. **Check Configuration for Errors**
    - Check global config:
      ```bash
      sudo named-checkconf
      ```
    - Check zone file:
      ```bash
      sudo named-checkzone anderson237.com /etc/bind/zones/db.anderson237.com
      ```
    - Check reverse zone:
      ```bash
      sudo named-checkzone 122.168.192.in-addr.arpa /etc/bind/zones/db.192.168.122
      ```

15. **Restart and Test the DNS**
    - Restart BIND9:
      ```bash
      sudo systemctl restart bind9
      ```
    - Check BIND9 status:
      ```bash
      sudo systemctl status bind9
      ```
    - Test DNS resolution:
      ```bash
      nslookup github.com omega.anderson237.com
      ```

16. **Modify the `resolv.conf` File**
    - Add the following to `/etc/resolv.conf`:
      ```plaintext
      nameserver 127.0.0.1
      nameserver 192.168.122.166
      search anderson237.com
      ```

17. **Add the DNS Server to Your Local Machine**
    - Check your network interface:
      ```bash
      ip a
      ```
    - Add the DNS server:
      ```bash
      resolvectl dns yournet-interface your-dns-server-ip
      ```
    - Verify the configuration:
      ```bash
      resolvectl status
      ```

18. **Test the DNS Server**
    - Test DNS resolution:
      ```bash
      ping omega.anderson237.com
      nslookup google.com omega.anderson237.com
      ```
