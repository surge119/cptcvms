```sh
aws s3 cp s3://cptc-vms/cptc-payment-web.qcow2 ./cptc-payment-web.qcow2

qemu-img convert -O raw cptc-payment-web.qcow2 cptc-payment-web.raw

aws ec2 import-image --description "CPTC VM Import" --disk-containers "file:///home/ubuntu/vms/config.json"

aws ec2 describe-import-image-tasks --import-task-ids import-ami-07aab4494a9ec633f
```

```json
[
  {
    "Description": "CPTC VM Import",
    "Format": "raw",
    "UserBucket": {
        "S3Bucket": "cptc-vms",
        "S3Key": "cptc-payment-web.raw"
    }
  }
]
```

https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html

progress
- doapi
- ldap
- 