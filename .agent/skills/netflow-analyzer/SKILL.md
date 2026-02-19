---
name: NetFlow Analyzer
description: Skill for NetFlow Analyzer — network flow traffic analytics with NetFlow/sFlow/IPFIX collection, bandwidth monitoring, and traffic pattern analysis.
---

# NetFlow Analyzer — Flow Traffic Analytics

## Overview
NetFlow Analyzer collects and analyzes network flow data (NetFlow v5/v9, sFlow, IPFIX, J-Flow) for bandwidth monitoring, traffic pattern analysis, and security forensics.

## Flow Protocols
| Protocol | Vendor | Description |
|----------|--------|-------------|
| NetFlow v5/v9 | Cisco | Flow export from routers/switches |
| IPFIX | IETF | NetFlow v10 standard |
| sFlow | InMon | Sampled flow from any vendor |
| J-Flow | Juniper | Juniper flow export |
| NetStream | Huawei | Huawei flow export |

## Configuration (Cisco Router)
```
! Enable NetFlow on interface
interface GigabitEthernet0/0
  ip flow ingress
  ip flow egress

! Configure flow export
ip flow-export destination 10.0.0.100 9996
ip flow-export version 9
ip flow-export source Loopback0
```

## Use Cases
- Bandwidth usage analysis per application/user
- DDoS attack detection via traffic anomalies
- Network forensics and traffic pattern analysis
- Capacity planning and traffic engineering
