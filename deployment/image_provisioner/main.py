import argparse
import configparser
import json
import threading

import boto3
import paramiko
from paramiko.client import SSHClient


# CHANGE THIS IF DOING CUSTOM DEPLOYMENT
bucket = "cptc-vms"
bucket_path = f"s3://{bucket}/"
base_key = "cptc-{}"
raw_extension = ".raw"
compressed_extenstion = f"{raw_extension}.7z"

compressed_key = f"{base_key}{compressed_extenstion}"
raw_key = f"{base_key}{raw_extension}"

s3_ini_path = f"{bucket_path}{base_key}{compressed_extenstion}"
s3_out_path = f"./{base_key}{compressed_extenstion}"

raw_key = f"{base_key}{raw_extension}"
raw_path = f"./{raw_key}"
s3_upl_path = f"{bucket_path}{raw_key}"

vms = [
    "adcs",
    "dc01",
    "doapi",
    "hms",
    "kiosk01",
    "kiosk02",
    "kiosk03",
    "kiosk04",
    "ldap",
    "lps",
    "media",
    "payment-db",
    "payment-web",
    "profiler",
    "workstation01",
    "workstation02",
]


class VMConverter(threading.Thread):
    def __init__(self, vm: str, host: str) -> None:
        super(VMConverter, self).__init__()
        self.vm = vm
        self.host = host
        self.client = SSHClient()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.client.connect(
            host, username="ubuntu", key_filename="./image_builder/key.pem"
        )

    def run(self):
        self.exec(
            "sudo apt update && sudo apt install -y p7zip-full && sudo snap install aws-cli --classic"
        )
        self.download()
        self.extract()
        self.upload()

    def exec(self, command) -> None:
        stdin, stdout, stderr = self.client.exec_command(command)
        exit = stdout.channel.recv_exit_status()
        print(f"Host: {self.host} Command: {command} Status: {exit}")

    def download(self) -> None:
        self.exec(
            f"aws s3 cp {s3_ini_path.format(self.vm)} {s3_out_path.format(self.vm)}"
        )

    def extract(self) -> None:
        self.exec(f"7z x {s3_out_path.format(self.vm)}")

    def upload(self) -> None:
        self.exec(f"aws s3 cp {raw_path.format(self.vm)} {s3_upl_path.format(self.vm)}")


def import_image(client, vm, vm_path):
    res = client.import_image(
        Description=f"CPTC VM Import {vm}",
        DiskContainers=[
            {
                "Description": f"CPTC VM Import {vm}",
                "Format": "raw",
                "UserBucket": {"S3Bucket": "cptc-vms", "S3Key": f"{vm_path}"},
            },
        ],
        TagSpecifications=[
            {
                "ResourceType": "import-image-task",
                "Tags": [
                    {"Key": "Name", "Value": f"CPTC VM {vm}"},
                ],
            },
        ],
    )

    return res["ImportTaskId"]


def import_image_status(client, ids):
    res = client.describe_import_image_tasks(
        ImportTaskIds=ids,
    )

    def pretty_print(img_arg, status_arg, prog_arg):
        print(f"{img_arg:16} {status_arg:10} {prog_arg}")

    stats = res["ImportImageTasks"]
    pretty_print("Image", "Status", "Progress")
    for stat in stats:
        img = stat["Description"].split(" ")[-1]
        if "Progress" in stat:
            pretty_print(img, stat["Status"], stat["Progress"])
        else:
            pretty_print(img, stat["Status"], "Done")

    return res


def tag_images(client, data, statuses):
    for vm in data:
        for status in statuses["ImportImageTasks"]:
            if status["ImportTaskId"] == data[vm]:
                res = client.create_tags(
                    Resources=[
                        status["ImageId"],
                    ],
                    Tags=[
                        {"Key": "Name", "Value": f"cptc8-{vm}"},
                    ],
                )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="Image Povisioner Helper")
    parser.add_argument("-c", "--convert", action="store_true")
    parser.add_argument("-i", "--import-image", action="store_true")
    parser.add_argument("-s", "--status", action="store_true")
    parser.add_argument("-t", "--tag", action="store_true")

    args = parser.parse_args()

    if args.convert:
        hosts = []
        with open("./image_builder/inventory.ini", "r") as f:
            while line := f.readline().strip():
                hosts.append(line)
        for index, vm in enumerate(vms):
            conv = VMConverter(vm, hosts[index])
            conv.start()

    if args.import_image:
        info = {}
        ec2_client = boto3.client("ec2")
        for vm in vms:
            import_task_id = import_image(ec2_client, vm, raw_key.format(vm))
            print(import_task_id)
            info[vm] = import_task_id

        with open("output.json", "w") as f:
            json.dump(info, f)

    if args.status:
        ec2_client = boto3.client("ec2")
        with open("output.json", "r") as f:
            info = json.load(f)
            tasks = []
            for t in info:
                tasks.append(info[t])
            status = import_image_status(ec2_client, tasks)
            with open("status.json", "w") as ff:
                json.dump(status, ff)

    if args.tag:
        ec2_client = boto3.client("ec2")
        with open("output.json", "r") as f, open("status.json", "r") as f1:
            info = json.load(f)
            status_list = json.load(f1)
            tag_images(ec2_client, info, status_list)
