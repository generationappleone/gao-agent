---
name: Ansible
description: Skill for Ansible — IT automation with playbooks, roles, Tower/AWX REST API, and configuration management for infrastructure automation.
---

# Ansible — IT Automation

## Overview
Ansible is an agentless IT automation platform for configuration management, application deployment, and orchestration using YAML playbooks.

## Playbook Example
```yaml
- name: Configure web servers
  hosts: webservers
  become: yes
  vars:
    http_port: 80
  tasks:
    - name: Install nginx
      apt: name=nginx state=present
    - name: Start nginx
      service: name=nginx state=started enabled=yes
    - name: Deploy config
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf
      notify: restart nginx
  handlers:
    - name: restart nginx
      service: name=nginx state=restarted
```

## Tower/AWX REST API
```python
import requests
headers = {"Authorization": f"Bearer {token}"}

# Launch job template
requests.post("https://tower/api/v2/job_templates/1/launch/",
    headers=headers, json={"extra_vars": {"env": "production"}})

# Get job status
job = requests.get("https://tower/api/v2/jobs/42/", headers=headers)
```

## Best Practices
- Use **Roles** for reusable automation components
- Implement **Ansible Vault** for secrets in playbooks
- Use **AWX/Tower** for scheduling, RBAC, and audit trails
