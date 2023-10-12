import argparse
import json
import math
import threading
import time

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
        self.client.connect(host, username="ubuntu", key_filename="./tf/key.pem")

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


def get_amis(data, statuses):
    amis = dict()
    for vm in data:
        for status in statuses["ImportImageTasks"]:
            if status["ImportTaskId"] == data[vm]:
                amis[vm] = status["ImageId"]
    return amis


def tag_images(client, data, statuses):
    amis = get_amis(data, statuses)
    for vm in vms:
        res = client.create_tags(
            Resources=[
                amis[vm],
            ],
            Tags=[
                {"Key": "Name", "Value": f"cptc8-{vm}"},
            ],
        )


def publish_images(client, data, statuses):
    amis = get_amis(data, statuses)
    final_amis = dict()

    # Copy AMIs
    for vm in vms:
        res = client.copy_image(
            Description=f"AMI for cptc8 {vm} VM",
            Name=f"cptc8-{vm}",
            SourceImageId=amis[vm],
            SourceRegion="us-east-1",
            CopyImageTags=True,
        )

        ami_id = res["ImageId"]
        print(f"Copied AMI {vm} : {ami_id}")
        final_amis[vm] = ami_id

    # Save ami ids
    with open("publish.json", "w") as f:
        json.dump(final_amis, f, indent=2)

    def pretty_print(ami, state, time=None):
        if time:
            print(f"{ami:20} {state:10} | Time Elapsed: {time}s")
        else:
            print(f"{ami:20} {state:10}")

    # Wait for AMIs to be ready
    start_time = time.time()
    while True:
        time.sleep(10)
        diff_time = math.floor(time.time() - start_time)
        ami_ids = [final_amis[vm] for vm in final_amis]

        # Get AMI statuses
        ami_status = client.describe_images(ImageIds=ami_ids)

        # Print statuses
        pretty_print("AMI", "Status", diff_time)
        for ami in ami_status["Images"]:
            pretty_print(ami["Name"], ami["State"])

        # Check if all are available
        states = [ami["State"] for ami in ami_status["Images"]]
        if all(state == "available" for state in states):
            print("Copy Complete")
            break

    # Deregister AMIs
    for vm in vms:
        print(f"Deregistering {vm}")
        res = client.deregister_image(
            ImageId=amis[vm],
        )

    # Make AMIs Public
    for ami in final_amis:
        print(f"Publishing {vm}")
        res = client.modify_image_attribute(
            Attribute="launchPermission",
            ImageId=final_amis[ami],
            LaunchPermission={
                "Add": [
                    {
                        "Group": "all",
                    },
                ],
            },
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="Image Povisioner Helper")
    parser.add_argument("-c", "--convert", action="store_true")
    parser.add_argument("-i", "--import-image", action="store_true")
    parser.add_argument("-s", "--status", action="store_true")
    parser.add_argument("-t", "--tag", action="store_true")
    parser.add_argument("-p", "--publish", action="store_true")

    args = parser.parse_args()

    if args.convert:
        hosts = []
        with open("./tf/inventory.ini", "r") as f:
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
            json.dump(info, f, indent=2)

    if args.status:
        ec2_client = boto3.client("ec2")
        with open("output.json", "r") as f:
            info = json.load(f)
            tasks = []
            for t in info:
                tasks.append(info[t])
            status = import_image_status(ec2_client, tasks)
            with open("status.json", "w") as ff:
                json.dump(status, ff, indent=2)

    if args.tag:
        ec2_client = boto3.client("ec2")
        with open("output.json", "r") as f, open("status.json", "r") as f1:
            info = json.load(f)
            status_list = json.load(f1)
            tag_images(ec2_client, info, status_list)

    if args.publish:
        ec2_client = boto3.client("ec2")
        with open("output.json", "r") as f, open("status.json", "r") as f1:
            info = json.load(f)
            status_list = json.load(f1)
            publish_images(ec2_client, info, status_list)
