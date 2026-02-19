---
name: VMware vSphere
description: Skill for VMware vSphere — virtualization platform API for VM management, vCenter, ESXi, vCloud Director, and migration (Replication, HCX).
---

# VMware vSphere — Virtualization Platform

## Overview
VMware vSphere is the enterprise virtualization platform including ESXi hypervisor, vCenter management, and APIs for VM lifecycle management, networking, and storage.

## vSphere API (pyVmomi)
```python
from pyVim.connect import SmartConnect
from pyVmomi import vim

si = SmartConnect(host='vcenter.example.com', user='admin', pwd='pass')
content = si.RetrieveContent()

# List VMs
container = content.viewManager.CreateContainerView(content.rootFolder, [vim.VirtualMachine], True)
for vm in container.view:
    print(f"{vm.name}: {vm.runtime.powerState}")

# Power on VM
task = vm.PowerOnVM_Task()
```

## vCloud Director API
```python
# Create vApp
requests.post(f"{vcd_url}/api/vdc/{vdc_id}/action/composeVApp",
    headers={"Authorization": f"Bearer {token}"},
    data=vapp_xml)
```

## Best Practices
- Use **vSphere REST API** for modern integrations
- Implement **DRS** for automatic load balancing
- Configure **HA** for host failover protection
