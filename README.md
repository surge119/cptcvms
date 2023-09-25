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

Steps:

1. Change passwords of VMs
2. Convert, Compress, Upload VMs to S3
3. Unpack & Import VMs
4. Launch

To optimize costs, the 1st and 2nd step are done only once. But the other two will be used whenever the network needs to be setup. Alternatively, only step 4 needs to be run, if the VMs are stored as AMIs (result of step 3), but it can be costly.

### Change passwords of VMs

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

### Convert, Compress, Upload VMs to S3

Once the VMs have their passwords changed, they can be stored in S3. Optimally, they are stored as 7z compress `.raw` files.

Each VM can be converted to a raw file with the following command.

Convert - Note: The raw file is 50 GB is size...

```sh
qemu-img convert -O raw ./cptc-payment-web.qcow2 ./cptc-payment-web.raw
```

Compress - These are much smaller. They compress windows vms better than other formats (vmdk, qcow2)

```sh
7z a ./cptc-payment-web.raw.7z ./cptc-payment-web.raw
```

Once the are compressed, they can be uploaded to S3.

To be uploaded to s3, create a bucket. Then upload the compressed file. For the scripts to be compatible, the naming format should be `cptc-{VM NAME}.raw.7z`

### Unpack & Import VMs

This process is used to unpack the 7z compressed raw images and then uploads the raw images to s3 to be converted to AMIs later. There are a few helper scripts in the `deployment/image_provisioner` directory.

The following scripts exist:

1. `deployment/image_provisioner/tf`

- Terraform scripts to provision 16 EC2 instances used by the following script

2. `deployment/image_provisioner/main.py`

- Python script that:
  - Uses each EC2 instance to download a compressed vm from s3
  - Unpacks the vm
  - Uploads the raw vm
  - Imports the vm
  - Tracks the status of the import task
  - Tags the new AMI

Terraform usage. Note: Terraform needs to be installed. Additionally, brand new AWS accounts may not have the quotas required for this. You may need to request a quota increase, or do this all on a single vm, though the python script wont work. The purpose of distributing the tasks is to make it faster.

```sh
cd deployment/image_provisioner/tf
terraform apply
```

Python script. Note: There is a global variable `bucket` that will need to be changed to be your bucket name.

```sh
# SSH into each EC2 instance, download, uncompress, and upload vm. This can take ~20 min (maybe longer, maybe less).
# The script may also break and the last command will hang, so check s3 every couple minutes to check if every vm has been uploaded
python3 main.py -c

# Import images - linux images take 15-20 min, win10 takes a little bit longer,
# win server takes a long time... 2+ hours
python3 main.py -i

# Track progress
python3 main.py -s

# Tag AMIs - do this after every vm is imported
python3 main.py -t
```

#### Launch
