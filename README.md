# Overview

Documentation and helper scripts for deploying the cptc 2023 finals VMs to AWS.

## Usage

The following are the credentials

- Linux:

  - User: `root`
  - Password: `cptcadmin`

- Windows:
  - User: `Administrator`
  - Password: ``

## Setup

Since the passwords to the VMs are unknown, we must first change the passwords. For linux machines, we just change the boot parameters such that we boot into a root shell, then we can remount the filesystem as r/w and then change the password with `passwd`.

Linux Steps (done on Ubuntu 22.04 with virt-manager)

1. Download and convert VMs to `qcow2` format:

```sh
# Download
curl -O https://mirrors.rit.edu/cptc/2023/virtual-machines/2023-finals-team-01-payment-web-a8fb8224.vmdk.7z

# Extract `vmdk`
7z x 2023-finals-team-01-payment-web-a8fb8224.vmdk.7z

# Convert `vmdk` to `qcow2`
qemu-img convert -O qcow2 2023-finals-team-01-payment-web-a8fb8224.vmdk cptc-payment-web.qcow2
```

2. Import `qcow2` VM to virt-manger

   - `File` -> `New Virtual Machine` -> `Import existing disk image` -> Select `cptc-payment-web.qcow2` ...

3. Start the VM and immediately hold `ESC` to enter the `GRUB` menu

4. When hovering over the first entry, press `e` then scroll to the line that starts with `linux`.

   - Delete `console=tty1 console=ttyS0`
   - Change `ro` to `rw`
   - Append `init=/bin/sh`
   - Press `ctrl+x`

5. Remount filesystem and change password

```sh
# Remount filesystem (if the filesystem fails to mount as rw on boot)
mount -o remount,rw /

# Change password
passwd
```
