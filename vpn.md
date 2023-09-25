```shell
sudo apt install -y wireguard

wg genkey | tee privatekey | wg pubkey > publickey

echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

wg set wg0 peer [clientpublickey] allowed-ips [IP]

wg-quick up server
```

Server

```
[Interface]
Address = 10.0.50.1/24
SaveConfig = true
ListenPort = 51820
PrivateKey = server_private_key
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens5 -j MASQUERADE
```

client

```
[Interface]
PrivateKey = client_private_key
Address = 10.0.50.2/24

[Peer]
PublicKey = server_public_key
Endpoint = 54.90.13.247:51820
AllowedIPs = 10.0.0.0/16
```

```sh
ansible-playbook -i inventory.ini playbook.yml
```
