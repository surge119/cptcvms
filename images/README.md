```sh
aws s3 cp s3://cptc-vms/cptc-payment-web.qcow2 ./cptc-payment-web.qcow2

qemu-img convert -O raw cptc-payment-web.qcow2 cptc-payment-web.raw
```

Generate password
```sh
openssl passwd -6 -salt balls cptcadmin
```

Password
```
# og
root:$6$Hn2oasenzcqjdbxn$WcaM.iQ2dCl1a6Zzf/00GUSjuC3u.DK7s5st42Thuk5Yvd1PzA4GUD6XWijvRu/J3pZum.LY.9vTkLnK0toJV/:19374:0:99999:7:::

# New
root:$6$balls$bHzICSaXxRyVH7tN.T02BBZ4Ut4xOKwT5IAzmu8mj.1ssDBtTjkL8Bk2IFYKm/XzNA7.WFAT7/VVg894lo3s31:19374:0:99999:7:::
```

```
sudo apt update

sudo apt install p7zip-full
```