---
name: Ansible
description: Skill for Ansible — IT automation with playbooks, roles, Tower/AWX REST API, and configuration management for infrastructure automation.
---

# Ansible Skill

## Overview
Ansible is an agentless IT automation tool for configuration management, application deployment, and orchestration. It uses YAML playbooks, inventory files, roles, and modules to automate infrastructure. Ansible connects via SSH and requires no agents on managed nodes.

**References**:
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)

---

## Playbook

```yaml
# deploy.yml
---
- name: Deploy MyApp
  hosts: webservers
  become: yes
  vars:
    app_name: myapp
    app_dir: /opt/myapp
    node_version: 20

  tasks:
    - name: Install Node.js
      shell: curl -fsSL https://deb.nodesource.com/setup_{{ node_version }}.x | bash -
      args: { creates: /usr/bin/node }

    - name: Install Node.js package
      apt: name=nodejs state=present

    - name: Clone repository
      git:
        repo: "https://github.com/myorg/{{ app_name }}.git"
        dest: "{{ app_dir }}"
        version: main
        force: yes

    - name: Install dependencies
      npm: path={{ app_dir }} state=present
      notify: Restart app

    - name: Build application
      command: npm run build
      args: { chdir: "{{ app_dir }}" }
      notify: Restart app

    - name: Copy environment file
      template: src=templates/.env.j2 dest={{ app_dir }}/.env mode=0600
      notify: Restart app

    - name: Setup systemd service
      template: src=templates/myapp.service.j2 dest=/etc/systemd/system/{{ app_name }}.service
      notify: [Reload systemd, Restart app]

    - name: Enable and start service
      systemd: name={{ app_name }} enabled=yes state=started

  handlers:
    - name: Reload systemd
      systemd: daemon_reload=yes

    - name: Restart app
      systemd: name={{ app_name }} state=restarted
```

---

## Inventory

```ini
# inventory/production
[webservers]
web1.myapp.com ansible_user=deploy
web2.myapp.com ansible_user=deploy

[dbservers]
db1.myapp.com ansible_user=deploy

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

---

## Commands

```bash
ansible-playbook -i inventory/production deploy.yml
ansible-playbook deploy.yml --check --diff     # Dry run
ansible all -m ping -i inventory/production   # Test connectivity
ansible-galaxy install geerlingguy.nginx      # Install role
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Playbooks** | YAML-based declarative automation |
| **Roles** | Reusable, modular automation units |
| **Handlers** | Triggered on change for restarts/reloads |
| **Templates** | Jinja2 templates for config files |
| **Vault** | Encrypt secrets with ansible-vault |
| **Idempotent** | Tasks produce same result on re-run |
| **Check mode** | `--check --diff` for dry runs |
| **Inventory** | Group hosts by function |
| **Variables** | Group vars, host vars, defaults |
| **Galaxy** | Use community roles from Ansible Galaxy |

---

## Rules Integration
- **Playbooks**: YAML tasks for deployment automation
- **Handlers**: Restart services on config changes
- **Templates**: Jinja2 for dynamic configuration
- **Inventory**: Host groups for environments
