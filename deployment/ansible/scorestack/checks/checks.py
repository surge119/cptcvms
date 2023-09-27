import json


CHECK_TYPES = {"icmp": "ping"}


class Check:
    def __init__(self) -> None:
        pass

    def network(self, network: str):
        self.network = network
        return self

    def name(self, name: str):
        self.name = name
        return self

    def type(self, type: str):
        self.type = type
        return self

    def score_weight(self, score_weight: int):
        self.score_weight = score_weight
        return self

    def definition(self, definition: dict):
        self.definition = definition
        return self

    def attributes(self, attributes: dict):
        self.attributes = attributes
        return self

    def build(self) -> dict:
        return {
            "name": f"admin",
            "type": self.type,
            "score_weight": self.score_weight,
            "definition": self.definition,
            "attributes": self.attributes,
        }


class ICMPCheck(Check):
    def __init__(self) -> None:
        super().__init__()

    def host(self, host: str):
        self.host = host
        return self

    def serialize(self) -> dict:
        return (
            self.definition(
                {
                    "host": "{{.Host}}",
                }
            )
            .attributes({f"{self.name}": {"Host": f"{self.host}"}})
            .build()
        )


icmp_check = {
    "name": "Corporate Payment Web ICMP",
    "type": "icmp",
    "score_weight": 1,
    "definition": {"host": "{{.Host}}"},
    "attributes": {"adcs": {"Host": "10.0.0.6"}},
}


targets = {
    "corp": [
        {"name": "adcs", "ip": "10.0.0.6"},
        {"name": "dc01", "ip": "10.0.0.5"},
        {"name": "doapi", "ip": "10.0.0.7"},
        {"name": "hms", "ip": "10.0.0.11"},
        {"name": "ldap", "ip": "10.0.0.100"},
        {"name": "lps", "ip": "10.0.0.12"},
        {"name": "media", "ip": "10.0.0.20"},
        {"name": "payment-db", "ip": "10.0.0.210"},
        {"name": "payment-web", "ip": "10.0.0.200"},
        {"name": "profiler", "ip": "10.0.0.102"},
        {"name": "workstation01", "ip": "10.0.0.51"},
        {"name": "workstation02", "ip": "10.0.0.52"},
    ],
    "guest": [
        {"name": "kiosk01", "ip": "10.0.200.101"},
        {"name": "kiosk02", "ip": "10.0.200.102"},
        {"name": "kiosk03", "ip": "10.0.200.103"},
        {"name": "kiosk04", "ip": "10.0.200.104"},
    ],
}


def create_checks():
    for net in targets:
        for target in targets[net]:
            # print(target)
            check = (
                ICMPCheck()
                .network(net)
                .name(target["name"])
                .type("icmp")
                .score_weight(1)
                .host(target["ip"])
                .serialize()
            )
            with open(f"{net}-{target['name']}-icmp.json", "w") as f:
                json.dump(check, f, indent=4)


if __name__ == "__main__":
    create_checks()
