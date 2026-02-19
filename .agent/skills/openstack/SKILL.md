---
name: OpenStack
description: Skill for OpenStack — open-source cloud platform with Nova (compute), Neutron (networking), Cinder (storage), and Keystone (identity) APIs.
---

# OpenStack — Cloud Platform

## Overview
OpenStack is an open-source cloud infrastructure platform providing compute (Nova), networking (Neutron), block storage (Cinder), object storage (Swift), and identity (Keystone).

## API Examples
```python
from openstack import connect
conn = connect(cloud='mycloud')

# List servers (Nova)
for server in conn.compute.servers():
    print(f"{server.name}: {server.status}")

# Create server
server = conn.compute.create_server(
    name="web-01", image_id="IMG_ID", flavor_id="m1.small",
    networks=[{"uuid": "NET_ID"}]
)

# List networks (Neutron)
for network in conn.network.networks():
    print(f"{network.name}: {network.id}")

# Create volume (Cinder)
volume = conn.block_storage.create_volume(name="data-vol", size=100)
```

## Best Practices
- Use **openstacksdk** for unified Python API
- Configure **Heat** for orchestration templates
- Enable **Ceilometer** for usage metering
