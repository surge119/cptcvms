resource "aws_ebs_snapshot_import" "aws_ebs_snapshot_import" {
  disk_container {
    format = "RAW"
    user_bucket {
      s3_bucket = "cptc-vms"
      s3_key    = "cptc-hms.raw"
    }
  }

  tags = {
    Name = "cptc-payment-web Snapshot Import"
  }
}

resource "aws_ami" "aws_ami_import" {
  root_device_name = "/dev/sda1"
  name             = "cptc-hms"
  ebs_block_device {
    device_name           = "/dev/sda1"
    snapshot_id           = aws_ebs_snapshot_import.aws_ebs_snapshot_import.id
    volume_size           = aws_ebs_snapshot_import.aws_ebs_snapshot_import.volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  ena_support         = true
  virtualization_type = "hvm"

  tags = {
    Name = "cptc-payment-web"
  }
}
