```sh
aws s3 cp s3://cptc-vms/cptc-payment-web.qcow2 ./cptc-payment-web.qcow2

qemu-img convert -O raw cptc-payment-web.qcow2 cptc-payment-web.raw
```
