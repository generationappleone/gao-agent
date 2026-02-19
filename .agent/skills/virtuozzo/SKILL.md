---
name: Virtuozzo Hybrid Infrastructure
description: Skill for Virtuozzo Hybrid Infrastructure — OpenStack-based hyperconverged cloud platform for IaaS, KVM compute, software-defined storage (block/S3/NFS), VXLAN networking, Kubernetes-as-a-Service, and billing integration (WHMCS/HostBill).
---

# Virtuozzo Hybrid Infrastructure

## Overview
Virtuozzo Hybrid Infrastructure (VHI) is a turnkey, OpenStack-based hyperconverged cloud platform for service providers, ISVs, and enterprises to build, manage, and sell public, private, or hybrid cloud Infrastructure-as-a-Service (IaaS). It integrates KVM compute, software-defined storage, networking, and Kubernetes orchestration into a single deployable solution.

## Architecture
```
┌──────────────────────────────────────────────────────────┐
│               Virtuozzo Hybrid Infrastructure            │
├──────────────┬──────────────┬──────────────┬────────────┤
│   Compute    │   Storage    │  Networking  │  Services  │
│  (KVM/QEMU)  │ (SDS/S3/NFS)│(VXLAN/SDN)   │(K8s/LBaaS)│
├──────────────┴──────────────┴──────────────┴────────────┤
│              OpenStack-Compatible API Layer              │
├──────────────┬──────────────┬──────────────┬────────────┤
│    Nova      │   Cinder     │   Neutron    │   Heat     │
│  (Compute)   │  (Block Stg) │ (Networking) │  (Orch)    │
├──────────────┴──────────────┴──────────────┴────────────┤
│    Self-Service Portal  │  Monitoring (Prometheus/Grafana)│
│    Billing Integration  │  WHMCS / HostBill / CloudBlue  │
└──────────────────────────────────────────────────────────┘
```

## Key Features
| Feature | Description |
|---------|-------------|
| **KVM Compute** | High-performance VMs with GPU/vGPU passthrough, live resize (vCPU, RAM, disk) without downtime |
| **Block Storage** | Software-defined block storage for VMs and hot data with replication |
| **S3 Object Storage** | S3-compatible object storage for unstructured data at scale |
| **NFS File Storage** | File storage with erasure coding for cold data and archive |
| **VXLAN Networking** | Isolated tenant networks, distributed virtual routers, floating IPs, security groups |
| **Kubernetes-as-a-Service** | Built-in managed Kubernetes cluster provisioning and lifecycle management |
| **Load Balancer-as-a-Service** | L4/L7 load balancing for VMs and Kubernetes workloads |
| **Backup-as-a-Service** | Integrated backup for VMs and volumes |
| **High Availability** | Automatic VM failover on host failure, no single point of failure |
| **White-Label Portal** | Customizable self-service portal for end users |

## Compute API (OpenStack Nova Compatible)

### Authentication (Keystone)
```python
import requests

# Authenticate via Keystone
auth_url = "https://vhi-cluster:5000/v3/auth/tokens"
auth_data = {
    "auth": {
        "identity": {
            "methods": ["password"],
            "password": {
                "user": {
                    "name": "admin",
                    "domain": {"name": "Default"},
                    "password": "your-password"
                }
            }
        },
        "scope": {
            "project": {
                "name": "your-project",
                "domain": {"name": "Default"}
            }
        }
    }
}

response = requests.post(auth_url, json=auth_data)
token = response.headers["X-Subject-Token"]
headers = {"X-Auth-Token": token}
```

### VM Management (Nova)
```python
compute_url = "https://vhi-cluster:8774/v2.1"

# List servers (VMs)
servers = requests.get(f"{compute_url}/servers/detail", headers=headers)
for server in servers.json()["servers"]:
    print(f"{server['name']}: {server['status']} ({server['flavor']['original_name']})")

# Create VM
new_vm = requests.post(f"{compute_url}/servers", headers=headers, json={
    "server": {
        "name": "web-server-01",
        "imageRef": "IMAGE_UUID",
        "flavorRef": "FLAVOR_UUID",
        "networks": [{"uuid": "NETWORK_UUID"}],
        "key_name": "my-keypair",
        "security_groups": [{"name": "web-sg"}],
        "metadata": {"environment": "production"}
    }
})

# Resize VM (live, tanpa downtime)
requests.post(f"{compute_url}/servers/{server_id}/action", headers=headers, json={
    "resize": {"flavorRef": "NEW_FLAVOR_UUID"}
})

# Create snapshot
requests.post(f"{compute_url}/servers/{server_id}/action", headers=headers, json={
    "createImage": {"name": "backup-snapshot-2024", "metadata": {"type": "backup"}}
})

# GPU/vGPU passthrough
gpu_vm = requests.post(f"{compute_url}/servers", headers=headers, json={
    "server": {
        "name": "ml-training-gpu",
        "imageRef": "CUDA_IMAGE_UUID",
        "flavorRef": "GPU_FLAVOR_UUID",
        "networks": [{"uuid": "NETWORK_UUID"}]
    }
})
```

### Flavors (VM Sizes)
```python
# List available flavors
flavors = requests.get(f"{compute_url}/flavors/detail", headers=headers)
for flavor in flavors.json()["flavors"]:
    print(f"{flavor['name']}: {flavor['vcpus']} vCPU, {flavor['ram']}MB RAM, {flavor['disk']}GB disk")

# Create custom flavor
requests.post(f"{compute_url}/flavors", headers=headers, json={
    "flavor": {
        "name": "custom.4vcpu.8gb",
        "vcpus": 4,
        "ram": 8192,
        "disk": 80
    }
})
```

## Block Storage API (Cinder)
```python
storage_url = "https://vhi-cluster:8776/v3"

# Create volume
volume = requests.post(f"{storage_url}/volumes", headers=headers, json={
    "volume": {
        "name": "data-vol-01",
        "size": 100,
        "volume_type": "replicated",
        "description": "Database storage"
    }
})

# Attach volume to VM
requests.post(f"{compute_url}/servers/{server_id}/os-volume_attachments", headers=headers, json={
    "volumeAttachment": {"volumeId": volume_id}
})

# Create snapshot
requests.post(f"{storage_url}/snapshots", headers=headers, json={
    "snapshot": {"name": "daily-backup", "volume_id": volume_id, "force": True}
})
```

## S3 Object Storage API
```python
import boto3

# Connect to VHI S3-compatible storage
s3 = boto3.client('s3',
    endpoint_url='https://s3.vhi-cluster.example.com',
    aws_access_key_id='YOUR_S3_ACCESS_KEY',
    aws_secret_access_key='YOUR_S3_SECRET_KEY'
)

# Create bucket
s3.create_bucket(Bucket='my-media-bucket')

# Upload file
s3.upload_file('video.mp4', 'my-media-bucket', 'uploads/video.mp4')

# List objects
objects = s3.list_objects_v2(Bucket='my-media-bucket', Prefix='uploads/')
for obj in objects.get('Contents', []):
    print(f"{obj['Key']}: {obj['Size']} bytes")

# Generate presigned URL
url = s3.generate_presigned_url('get_object',
    Params={'Bucket': 'my-media-bucket', 'Key': 'uploads/video.mp4'},
    ExpiresIn=3600)
```

## Networking API (Neutron)
```python
network_url = "https://vhi-cluster:9696/v2.0"

# Create VXLAN network
network = requests.post(f"{network_url}/networks", headers=headers, json={
    "network": {"name": "app-network", "admin_state_up": True}
})

# Create subnet
subnet = requests.post(f"{network_url}/subnets", headers=headers, json={
    "subnet": {
        "network_id": network_id,
        "name": "app-subnet",
        "cidr": "10.0.1.0/24",
        "ip_version": 4,
        "gateway_ip": "10.0.1.1",
        "dns_nameservers": ["8.8.8.8", "8.8.4.4"]
    }
})

# Create router with external gateway
router = requests.post(f"{network_url}/routers", headers=headers, json={
    "router": {
        "name": "app-router",
        "external_gateway_info": {"network_id": "EXTERNAL_NET_UUID"}
    }
})

# Assign floating IP
floating_ip = requests.post(f"{network_url}/floatingips", headers=headers, json={
    "floatingip": {
        "floating_network_id": "EXTERNAL_NET_UUID",
        "port_id": "PORT_UUID"
    }
})

# Security group rules
requests.post(f"{network_url}/security-group-rules", headers=headers, json={
    "security_group_rule": {
        "security_group_id": sg_id,
        "direction": "ingress",
        "protocol": "tcp",
        "port_range_min": 443,
        "port_range_max": 443,
        "remote_ip_prefix": "0.0.0.0/0"
    }
})
```

## Kubernetes-as-a-Service
```python
# Create Kubernetes cluster
k8s_cluster = requests.post(f"{compute_url}/clusters", headers=headers, json={
    "cluster": {
        "name": "production-k8s",
        "cluster_template_id": "K8S_TEMPLATE_UUID",
        "master_count": 3,
        "node_count": 5,
        "keypair": "my-keypair"
    }
})

# Scale cluster nodes
requests.patch(f"{compute_url}/clusters/{cluster_id}", headers=headers, json={
    "node_count": 10
})

# Get kubeconfig
kubeconfig = requests.get(f"{compute_url}/clusters/{cluster_id}/config", headers=headers)
```

## Billing Integration

### WHMCS Integration
```php
// WHMCS provisioning module for VHI
function vhi_CreateAccount($params) {
    $client = new OpenStackClient($params['serverhostname']);
    $client->authenticate($params['serverusername'], $params['serverpassword']);

    // Create project for customer
    $project = $client->createProject($params['clientsdetails']['email']);

    // Create default VM
    $vm = $client->createServer([
        'name' => $params['domain'],
        'flavor' => $params['configoption1'],
        'image' => $params['configoption2'],
        'network' => $params['configoption3']
    ]);

    return 'success';
}
```

### HostBill Integration
```
# HostBill supports VHI via OpenStack module
# Configure in Settings > Apps & Integrations > Virtuozzo
Server Address: https://vhi-cluster:5000/v3
Username: admin
Password: ****
Project: default
```

## Monitoring (Prometheus + Grafana)
```yaml
# VHI includes built-in monitoring
# Access Grafana dashboards at:
# https://vhi-cluster:8443/grafana

# Key metrics available:
# - CPU/RAM/Disk utilization per VM
# - Storage cluster IOPS and latency
# - Network throughput per tenant
# - S3 storage usage and request rates
# - Kubernetes cluster health
```

## CLI Management
```bash
# Using OpenStack CLI
openstack --os-auth-url https://vhi-cluster:5000/v3 \
  --os-project-name myproject \
  --os-username admin \
  --os-password pass \
  server list

# Create VM
openstack server create \
  --image ubuntu-22.04 \
  --flavor m1.large \
  --network app-network \
  --key-name mykey \
  web-server-01

# Volume management
openstack volume create --size 100 data-volume
openstack server add volume web-server-01 data-volume
```

## Best Practices

### Compute
- Use **live resize** for scaling VMs without downtime
- Configure **anti-affinity groups** to spread VMs across hosts
- Enable **GPU passthrough** for AI/ML workloads
- Set up **automatic VM recovery** for high availability

### Storage
- Use **block storage** (replicated) for database and hot data workloads
- Use **S3 object storage** for media, backups, and unstructured data
- Use **NFS with erasure coding** for archive and cold data
- Configure **storage tiering** based on performance requirements

### Networking
- Implement **VXLAN tenant isolation** for multi-tenancy security
- Use **security groups** for micro-segmentation
- Deploy **floating IPs** only for public-facing services
- Configure **load balancers** for application high availability

### Operations
- Monitor cluster health via **integrated Grafana dashboards**
- Schedule **automated backups** for critical VMs and volumes
- Use **Kubernetes-as-a-Service** for containerized workloads
- Integrate with **WHMCS/HostBill** for automated billing and provisioning

## Use Cases
1. **Hosting Provider**: Sell IaaS with white-label self-service portal and WHMCS billing
2. **Enterprise Private Cloud**: On-premise OpenStack cloud with hyperconverged simplicity
3. **AI/ML Platform**: GPU-enabled VMs with Kubernetes for training workloads
4. **Disaster Recovery**: Cross-site replication and backup-as-a-service
5. **Container Platform**: Managed Kubernetes with integrated storage and networking
