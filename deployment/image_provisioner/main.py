import argparse
import enum
import json
import os
import subprocess
import time
import threading

import boto3


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


class VMConverterStatus(enum.Enum):
    INITIALIZING = "Initializing"
    DOWNLOADING = "Downloading"
    EXTRACTING = "Extracting"
    UPLOADING = "Uploading"
    DONE = "Done"


class VMConverter(threading.Thread):
    def __init__(self, vm: str, s3_client) -> None:
        super(VMConverter, self).__init__()
        self.vm = vm
        self.client = s3_client
        self.status = VMConverterStatus.INITIALIZING
        self.progress = ["Waiting"]
        self.is_finished = False

    def run(self):
        self.download()
        self.extract()
        self.upload()

    def exec(self, command) -> None:
        proc = subprocess.Popen(command, stdout=subprocess.PIPE, text=True)
        while proc.poll() is None:
            self.progress.append(proc.stdout.readline())

    def download(self) -> None:
        self.status = VMConverterStatus.DOWNLOADING
        metdata = self.client.head_object(
            Bucket=bucket, Key=compressed_key.format(self.vm)
        )
        size = int(metdata.get("ContentLength", 0))
        download_progress = 0

        start_time = time.time()

        def progress(chunk):
            nonlocal download_progress

            download_progress += chunk
            fmt_progress = round((download_progress / size) * 100, 2)
            speed = (download_progress / 1000000) / (time.time() - start_time)

            self.progress = (
                f"Download: {fmt_progress}% of {size / 1000000000} @ {speed}Mb/S"
            )

        self.client.download_file(
            bucket,
            compressed_key.format(self.vm),
            compressed_key.format(self.vm),
            Callback=progress,
        )

    def extract(self) -> None:
        self.status = VMConverterStatus.EXTRACTING
        self.exec(["7z", "x", s3_out_path.format(self.vm)])

    def upload(self) -> None:
        self.status = VMConverterStatus.UPLOADING
        self.exec(
            ["aws", "s3", "cp", raw_path.format(self.vm), s3_upl_path.format(self.vm)]
        )
        self.status = VMConverterStatus.DONE
        self.is_finished = True

    def done(self) -> bool:
        return self.is_finished

    def __str__(self) -> str:
        prog = None
        match self.status:
            case VMConverterStatus.INITIALIZING:
                prog = "Initializing"
            case VMConverterStatus.DOWNLOADING:
                prog = self.progress
            case VMConverterStatus.EXTRACTING:
                prog = "Extracting..."
            case VMConverterStatus.UPLOADING:
                prog = self.progress[-1]
            case _:
                prog = f"Unknown State...: {self.status}"

        return f"{self.status} {self.vm}:{prog}"


def import_image(client, vm, vm_path):
    res = client.import_image(
        Description=f"CPTC VM Impor {vm}",
        DiskContainers=[
            {
                "Description": "CPTC VM Import {vm}",
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
        l = []
        s3_client = boto3.client("s3")
        for vm in vms:
            conv = VMConverter(vm, s3_client)
            l.append(conv)
            conv.start()

        while any(l):
            os.system("clear")
            for c in l:
                if c.done():
                    l.remove(c)
                print(c)
            time.sleep(0.1)

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
