# Changes made to the VMs

- Root/Administrator passwords
- Converted dhcp ip to static ip

# IPs

The IPs were made to be static since it would make things significantly easier, since MAC address won't be constant.

For the linux machines, the `netplan` configuration (`/etc/netplan/50-cloud-init.yaml`) was modified.

Example:

```
network:
  version: 2
  ethernets:
    enp1s0:
     dhcp4: false
     addresses: [10.0.0.200/24]
     gateway4: 10.0.0.1
     nameservers:
       addresses: [1.1.1.1, 8.8.8.8]
```

Once the config was edited:

```sh
# Apply changes
netplan apply
```
