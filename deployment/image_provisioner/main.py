import argparse
import enum
import json
import os
import subprocess
import time
import threading

import boto3


bucket = "s3://cptc-vms/"
base_path = "cptc-{}"
raw_ext = ".raw"
comp_ext = f"{raw_ext}.7z"

s3_ini_path = f"{bucket}{base_path}{comp_ext}"
s3_out_path = f"./{base_path}{comp_ext}"

raw_key = f"{base_path}{raw_ext}"
raw_path = f"./{raw_key}"
s3_upl_path = f"{bucket}{raw_key}"

vms = [
    # "adcs",
    "dc01",
    "doapi",
    # "hms",
    # "kiosk01",
    # "kiosk02",
    # "kiosk03",
    # "kiosk04",
    # "ldap",
    # "lps",
    # "media",
    # "payment-db",
    # "payment-web",
    # "profiler",
    # "workstation01",
    # "workstation02",
]


class VMConverterStatus(enum.Enum):
    INITIALIZING = "Initializing"
    DOWNLOADING = "Downloading"
    EXTRACTING = "Extracting"
    UPLOADING = "Uploading"
    DONE = "Done"


class VMConverter(threading.Thread):
    def __init__(self, vm: str) -> None:
        super(VMConverter, self).__init__()
        self.vm = vm
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
            # print("Read:", proc.stdout.readline())

    def download(self) -> None:
        self.status = VMConverterStatus.DOWNLOADING
        self.exec(
            [
                "aws",
                "s3",
                "cp",
                s3_ini_path.format(self.vm),
                s3_out_path.format(self.vm),
            ]
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
                prog = self.progress[-1]
            case VMConverterStatus.EXTRACTING:
                prog = "Extracting..."
            case VMConverterStatus.UPLOADING:
                prog = self.progress[-1]
            case _:
                prog = "TEST"

        return f"Converting: {self.vm}\n\tStatus: {self.status}\n\tProgress:\n{prog}"


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
                    {"Key": "Name", "Value": f"CPTC Vm {vm}"},
                ],
            },
        ],
    )

    return res["ImportTaskId"]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="Image Povisioner Helper")
    parser.add_argument("-c", "--convert", action="store_true")
    parser.add_argument("-i", "--import-image", action="store_true")
    parser.add_argument("-s", "--status", action="store_true")

    args = parser.parse_args()

    if args.convert:
        l = []
        for vm in vms:
            conv = VMConverter(vm)
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
        status = {}
