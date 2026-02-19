---
name: OpenVAS / Greenbone
description: Skill for OpenVAS (Greenbone) — open-source vulnerability scanning with GVM framework, scan targets, custom policies, and API integration.
---

# OpenVAS / Greenbone — Open-Source Vulnerability Scanning

## Overview
OpenVAS (Open Vulnerability Assessment Scanner), now part of the Greenbone Vulnerability Management (GVM) framework, is the most comprehensive open-source vulnerability scanner with 100,000+ NVTs (Network Vulnerability Tests).

## GVM API (GMP Protocol)
```python
from gvm.connections import UnixSocketConnection
from gvm.protocols.gmp import Gmp
from gvm.transforms import EtreeTransform

connection = UnixSocketConnection(path='/run/gvmd/gvmd.sock')
transform = EtreeTransform()

with Gmp(connection, transform=transform) as gmp:
    gmp.authenticate('admin', 'admin')

    # Create target
    target = gmp.create_target(
        name="Internal Network",
        hosts=["192.168.1.0/24"],
        port_list_id="33d0cd82-57c6-11e1-8ed1-406186ea4fc5"
    )

    # Create and start scan task
    task = gmp.create_task(
        name="Weekly Scan",
        config_id="daba56c8-73ec-11df-a475-002264764cea",
        target_id=target.get('id'),
        scanner_id="08b69003-5fc2-4037-a479-93b440211c73"
    )
    gmp.start_task(task.get('id'))

    # Get results
    results = gmp.get_results(
        filter_string="severity>6.0 rows=100"
    )
```

## Best Practices
- Keep **NVT feeds** updated daily
- Use **credentialed scans** with SSH/SMB credentials
- Create **custom scan configs** per environment
- Schedule scans during **maintenance windows**
