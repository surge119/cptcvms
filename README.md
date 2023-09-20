# Overview

Documentation and helper scripts for deploying the cptc 2023 finals VMs to AWS.

## Usage

The following are the credentials

- Linux:

  - User: `root`
  - Password: `cptcadmin`

- Windows (all except kiosks):
  - User: `Administrator`
  - Password: `cptcadminA1!`

## Setup

Since the passwords to the VMs are unknown, we must first change the passwords. For linux machines, we just change the boot parameters such that we boot into a root shell, then we can remount the filesystem as r/w and then change the password with `passwd`. For windows, we change the binary for sticky keys (via a Windows PE bootable usb) and then we can access a command prompt from the login page

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

Windows Steps (done on Ubuntu 22.04 with virt-manager)

This requires a Windows PE usb stick.

1. Follows steps 1 & 2 from the Linux section above (but change windows specific things)

- In addition, select `Customize configuration before install` at step 4 of creating new vm
- Then select next and at the next page click `Add Hardware`
- Select `USB Host Device` -> choose your WinPE usb -> `Finish`
- Select `Boot Options` -> enable your usb device and move it to the top
- Select `Enable boot menu` with `Boot Options`
- Finish setting up the VM

2. Start the VM and boot into WinPE

Use the following commands

```sh
C:
cd Windows\system32
move sethc.exe sethc.back
copy cmd.exe sethc.exe
```

Wait a few seconds for files to copy then power off the vm

3. Boot the VM into the qcow2 image (windows)

4. Press `shift` 5 times to open a command prompt

5. Use the following command to change the password

```sh
net user Administrator cptcadminA1!
```

## AWS EC2 Helper

```sh
sudo apt update && sudo apt install -y qemu-utils p7zip-full && sudo snap install aws-cli --classic
```
