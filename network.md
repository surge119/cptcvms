# Network Overview

This network contains the CPTC8 (2022-2023) vms with additional support machines

### Subnets

| Network   | Subnet        | Description                              | Domain   |
| --------- | ------------- | ---------------------------------------- | -------- |
| Corporate | 10.0.0.0/24   | CPTC8 Corporate Network (Cozy Croissant) | corp.cc  |
| Guest     | 10.0.200.0/24 | CPTC8 Guest Network (Cozy Croissant)     | guest.cc |
| VPN       | 10.0.50.0/24  | VPN Network Used to Connect              | vpn.cc   |
| Blue      | 10.0.100.0/24 | Blue Team Machines                       | blue.cc  |
| Red       | 10.0.150.0/24 | Red Team Machines                        | red.cc   |
| Infra     | 10.0.69.0/24  | Infra Machines                           | infra.cc |

#### Corporate (10.0.0.0/24)

| Machine Name  | IP         | Purpose                              | AWS Instance | Domain                |
| ------------- | ---------- | ------------------------------------ | ------------ | --------------------- |
| adcs          | 10.0.0.6   | Active Directory Certificate Service | t3.medium    | adcs.corp.cc          |
| dc01          | 10.0.0.5   | Active Directory Domain Controller   | t3.medium    | dc01.corp.cc          |
| doapi         | 10.0.0.7   | Do API                               | t3.medium    | doapi.corp.cc         |
| hms           | 10.0.0.11  | Hotel Management System              | t3.medium    | hms.corp.cc           |
| ldap          | 10.0.0.100 | LDAP Authentication for AD           | t3.medium    | ldap.corp.cc          |
| lps           | 10.0.0.12  | Rewards                              | t3.medium    | lps.corp.cc           |
| media         | 10.0.0.20  | Media Server (Jellyfin)              | t3.medium    | media.corp.cc         |
| payment-db    | 10.0.0.210 | Payment Database                     | t3.medium    | payment-db.corp.cc    |
| payment-web   | 10.0.0.200 | Payment Web Portal                   | t3.medium    | payment-web.corp.cc   |
| profiler      | 10.0.0.102 | ?                                    | t3.medium    | profiler.corp.cc      |
| workstation01 | 10.0.0.51  | Workstation 1                        | t3.medium    | workstation01.corp.cc |
| workstation02 | 10.0.0.52  | Workstation 2                        | t3.medium    | workstation02.corp.cc |

#### Guest (10.0.200.0/24)

| Machine Name | IP           | Purpose | AWS Instance | Domain           |
| ------------ | ------------ | ------- | ------------ | ---------------- |
| kiosk01      | 10.0.200.101 | Kiosk 1 | t3.medium    | kiosk01.guest.cc |
| kiosk02      | 10.0.200.102 | Kiosk 2 | t3.medium    | kiosk02.guest.cc |
| kiosk03      | 10.0.200.103 | Kiosk 3 | t3.medium    | kiosk03.guest.cc |
| kiosk04      | 10.0.200.104 | Kiosk 4 | t3.medium    | kiosk04.guest.cc |

#### VPN (10.0.50.0/24)

| Machine Name | IP         | Purpose              | AWS Instance | Domain    |
| ------------ | ---------- | -------------------- | ------------ | --------- |
| wg           | 10.0.50.50 | Wireguard VPN Server | t4g.small    | wg.vpn.cc |

#### Blue (10.0.100.0/24)

| Machine Name | IP           | Purpose              | AWS Instance | Domain        |
| ------------ | ------------ | -------------------- | ------------ | ------------- |
| wazuh        | 10.0.100.100 | Wazuh Logging Server | t4a.medium   | wazuh.blue.cc |

#### Red (10.0.150.0/24)

| Machine Name | IP  | Purpose | AWS Instance | Domain |
| ------------ | --- | ------- | ------------ | ------ |

#### Infra (10.0.69.0/24)

| Machine Name | IP          | Purpose              | AWS Instance | Domain              |
| ------------ | ----------- | -------------------- | ------------ | ------------------- |
| dns          | 10.0.60.2   | DNS Server           | t4g.nano     | dns.infra.cc        |
| scorestack   | 10.0.69.100 | Wireguard VPN Server | t4g.small    | scorestack.infra.cc |
