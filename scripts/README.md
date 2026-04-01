# Proxmox Debian template

It follows the recommended Proxmox pattern:

* Uses a downloaded Debian cloud image
* Creates a VM template
* Enables cloud-init
* Lets you clone quickly afterward

---

## What this script does

1. Downloads a Debian cloud image
2. Creates a VM
3. Imports the disk into Proxmox storage
4. Attaches cloud-init drive
5. Configures:

   * User
   * SSH key
   * Network (DHCP or static)
6. Converts the VM into a template

---

## How to use

```bash
chmod +x create-debian-cloudinit-template.sh
./create-debian-cloudinit-template.sh
```

---

## Deploy new VM from template

```bash
qm clone 9000 101 --name debian-vm-1
qm start 101
```

---

## Optional improvements

## 1. Set static IP per VM

```bash
qm set 101 --ipconfig0 ip=192.168.1.101/24,gw=192.168.1.1
```

## 2. Resize disk

```bash
qm resize 101 scsi0 20G
```

## 3. Add DNS

```bash
qm set 101 --nameserver 1.1.1.1
```

---
