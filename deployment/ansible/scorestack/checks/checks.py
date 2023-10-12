import json


CHECK_TYPES = {"icmp": "ping", "ssh": "ssh", "winrm": "winrm", "http": "http"}


class Check:
    def __init__(self) -> None:
        pass

    def network(self, network: str):
        self.network = network
        return self

    def name(self, name: str):
        self.name = name
        return self

    def host(self, host: str):
        self.host = host
        return self

    def score_weight(self, score_weight: int):
        self.score_weight = score_weight
        return self

    def type(self, type: str):
        self.type = type
        return self

    def definition(self, definition: dict):
        self.definition = definition
        return self

    def attributes(self, attributes: dict):
        self.attributes = attributes
        return self

    def build(self) -> dict:
        return {
            "name": f"{self.network} {self.name} {CHECK_TYPES[self.type]}",
            "type": self.type,
            "score_weight": self.score_weight,
            "definition": self.definition,
            "attributes": self.attributes,
        }


class ICMPCheck(Check):
    def __init__(self) -> None:
        super().__init__()

    def serialize(self) -> dict:
        return (
            self.definition(
                {
                    "Host": "{{.Host}}",
                }
            )
            .attributes({"admin": {"Host": self.host}})
            .build()
        )


class RemoteCheck(Check):
    def __init__(self) -> None:
        super().__init__()
        self.os_type = {"linux": "ssh", "windows": "winrm"}

    def type(self, os: str):
        super().type(self.os_type[os])
        return self

    def username(self, username: str):
        self.username = username
        return self

    def password(self, password: str):
        self.password = password
        return self

    def command(self, command: str):
        self.command = command
        return self

    def regex(self, regex: str):
        self.regex = regex
        return self

    def serialize(self) -> dict:
        if self.type == "ssh":
            defs = {
                "Host": "{{.Host}}",
                "Username": "{{.Username}}",
                "Password": "{{.Password}}",
                "Cmd": "whoami",
                "MatchContent": "true",
                "ContentRegex": "{{.Regex}}",
            }
        elif self.type == "winrm":
            defs = {
                "Host": "{{.Host}}",
                "Username": "{{.Username}}",
                "Password": "{{.Password}}",
                "Cmd": "whoami",
                "Encrypted": "false",
                "Port": "5985",
                "MatchContent": "true",
                "ContentRegex": "{{.Regex}}",
            }

        return (
            self.definition(defs)
            .attributes(
                {
                    "admin": {
                        "Host": self.host,
                        "Username": self.username,
                        "Regex": self.regex,
                    },
                    "user": {
                        "Password": self.password,
                    },
                }
            )
            .build()
        )


class HTTPCheck(Check):
    def __init__(self) -> None:
        super().__init__()

    def requests(self, requests: dict[str:str]):
        self.requests = requests
        return self

    def serialize(self) -> dict:
        requests = [
            request | {"host": "{{.Host}}", "matchcontent": True}
            for request in self.requests
        ]

        return (
            self.definition(
                {
                    "requests": requests,
                }
            )
            .attributes({"admin": {"Host": self.host}})
            .build()
        )


ip_map = {
    "adcs": "10.0.0.6",
    "dc01": "10.0.0.5",
    "doapi": "10.0.0.7",
    "hms": "10.0.0.11",
    "ldap": "10.0.0.100",
    "lps": "10.0.0.12",
    "media": "10.0.0.20",
    "payment-db": "10.0.0.210",
    "payment-web": "10.0.0.200",
    "profiler": "10.0.0.102",
    "workstation01": "10.0.0.51",
    "workstation02": "10.0.0.52",
}


targets = {
    "corp": [
        {"name": "adcs", "ip": "10.0.0.6", "os": "windows"},
        {"name": "dc01", "ip": "10.0.0.5", "os": "windows"},
        {"name": "doapi", "ip": "10.0.0.7", "os": "linux"},
        {"name": "hms", "ip": "10.0.0.11", "os": "windows"},
        {"name": "ldap", "ip": "10.0.0.100", "os": "linux"},
        {"name": "lps", "ip": "10.0.0.12", "os": "linux"},
        {"name": "media", "ip": "10.0.0.20", "os": "linux"},
        {"name": "payment-db", "ip": "10.0.0.210", "os": "linux"},
        {"name": "payment-web", "ip": "10.0.0.200", "os": "linux"},
        {"name": "profiler", "ip": "10.0.0.102", "os": "linux"},
        {"name": "workstation01", "ip": "10.0.0.51", "os": "windows"},
        {"name": "workstation02", "ip": "10.0.0.52", "os": "windows"},
    ],
    "guest": [
        {"name": "kiosk01", "ip": "10.0.200.101", "os": "windows"},
        {"name": "kiosk02", "ip": "10.0.200.102", "os": "windows"},
        {"name": "kiosk03", "ip": "10.0.200.103", "os": "windows"},
        {"name": "kiosk04", "ip": "10.0.200.104", "os": "windows"},
    ],
}

http_targets = {
    "corp": [
        {
            "name": "doapi",
            "requests": [
                {
                    "path": "/ping",
                    "contentregex": "{'status':200,'data':'pong'}",
                    "https": True,
                    "port": 3000,
                }
            ],
        },
        {
            "name": "hms",
            "requests": [
                {
                    "path": "/the_cozy_croissant",
                    "contentregex": "<title>The Cozy Croissant &#8211; Your stay will be buttery &amp; flaky.</title>",
                }
            ],
        },
        {
            "name": "lps",
            "requests": [
                {
                    "path": "/",
                    "contentregex": "<title>Rewards</title>",
                    "https": True,
                    "port": 443,
                }
            ],
        },
        {"name": "media", "requests": [{"path": "/web", "contentregex": "jellyfin"}]},
        {
            "name": "payment-web",
            "requests": [
                {
                    "path": "/#/",
                    "contentregex": "<title>frontend</title>",
                    "https": True,
                    "port": 443,
                }
            ],
        },
        {
            "name": "profiler",
            "requests": [
                {"path": "/", "contentregex": "<title>Login - SB Admin Pro</title>"}
            ],
        },
    ]
}


def create_checks():
    for net in targets:
        for target in targets[net]:
            icmp_check = (
                ICMPCheck()
                .network(net)
                .name(target["name"])
                .host(target["ip"])
                .score_weight(1)
                .type("icmp")
                .serialize()
            )
            with open(f"{net}-{target['name']}-icmp.json", "w") as f:
                json.dump(icmp_check, f, indent=4)

            remote_check = (
                RemoteCheck()
                .network(net)
                .name(target["name"])
                .host(target["ip"])
                .score_weight(1)
                .type(target["os"])
                .username("infra")
                .password("cptcInfra12!")
                .command("id")
                .regex("infra")
                .serialize()
            )
            with open(f"{net}-{target['name']}-remote.json", "w") as f:
                json.dump(remote_check, f, indent=4)

    for net in http_targets:
        for target in http_targets[net]:
            http_check = (
                HTTPCheck()
                .network(net)
                .name(target["name"])
                .host(ip_map[target["name"]])
                .score_weight(1)
                .type("http")
                .requests(target["requests"])
                .serialize()
            )
            with open(f"{net}-{target['name']}-http.json", "w") as f:
                json.dump(http_check, f, indent=4)


if __name__ == "__main__":
    create_checks()
