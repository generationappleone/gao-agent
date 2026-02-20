---
name: Nmap
description: Skill for network scanning and security auditing with Nmap, covering port scanning, service detection, vulnerability scripts, SSL auditing, and output formats.
---

# Nmap Skill

## Overview
Nmap (Network Mapper) is the de-facto standard for network discovery and security auditing. It discovers hosts, services, operating systems, and vulnerabilities across networks. The NSE (Nmap Scripting Engine) extends Nmap with vulnerability detection, brute force, and enumeration capabilities.

**References**:
- [Nmap Documentation](https://nmap.org/book/)
- [NSE Script Library](https://nmap.org/nsedoc/)
- [Nmap Cheat Sheet](https://www.stationx.net/nmap-cheat-sheet/)

---

## Installation

```bash
# Ubuntu/Debian
sudo apt install nmap

# macOS
brew install nmap

# Windows
# Download from https://nmap.org/download.html

# Verify
nmap --version
```

---

## Host Discovery

```bash
# ── Ping scan (discover live hosts, no port scan) ──
nmap -sn 192.168.1.0/24

# ── TCP SYN ping ──
nmap -PS22,80,443 192.168.1.0/24

# ── No ping (treat all hosts as online) ──
nmap -Pn myapp.com

# ── ARP scan (local network only) ──
nmap -PR 192.168.1.0/24

# ── DNS resolution ──
nmap -sL 192.168.1.0/24     # List scan with DNS
nmap -n 192.168.1.1          # No DNS resolution (faster)
```

---

## Port Scanning

```bash
# ── Quick scan (top 100 ports) ──
nmap -F myapp.com

# ── Default scan (top 1000 ports) ──
nmap myapp.com

# ── All ports (1-65535) ──
nmap -p- myapp.com

# ── Specific ports ──
nmap -p 22,80,443,3306,5432,6379,8080 myapp.com

# ── Port range ──
nmap -p 1-1024 myapp.com

# ── Top N ports ──
nmap --top-ports 200 myapp.com

# ── Scan types ──
nmap -sS myapp.com     # TCP SYN scan (stealth, default with root)
nmap -sT myapp.com     # TCP Connect scan (no root needed)
nmap -sU myapp.com     # UDP scan (slow)
nmap -sV myapp.com     # Service version detection
nmap -sA myapp.com     # ACK scan (firewall detection)

# ── Combined TCP + UDP ──
nmap -sS -sU -p T:80,443,8080,U:53,161 myapp.com
```

---

## Service & OS Detection

```bash
# ── Service version detection ──
nmap -sV myapp.com
nmap -sV --version-intensity 5 myapp.com    # More aggressive

# ── OS detection ──
nmap -O myapp.com
nmap -O --osscan-guess myapp.com            # Aggressive guessing

# ── Comprehensive scan ──
nmap -A myapp.com    # = -sV -O -sC --traceroute

# ── Aggressive scan (all info) ──
nmap -A -T4 -p- myapp.com
```

---

## NSE Scripts (Vulnerability Detection)

```bash
# ── Default scripts ──
nmap -sC myapp.com         # = --script=default

# ── Specific vulnerability scripts ──
# SSL/TLS
nmap --script ssl-cert,ssl-enum-ciphers -p 443 myapp.com
nmap --script ssl-heartbleed -p 443 myapp.com
nmap --script ssl-poodle -p 443 myapp.com

# HTTP
nmap --script http-headers -p 80,443 myapp.com
nmap --script http-security-headers -p 443 myapp.com
nmap --script http-enum -p 80,443 myapp.com
nmap --script http-methods -p 80,443 myapp.com
nmap --script http-title -p 80,443 myapp.com
nmap --script http-robots.txt -p 80,443 myapp.com
nmap --script http-shellshock -p 80,443 myapp.com

# SQL
nmap --script mysql-info -p 3306 myapp.com
nmap --script mysql-enum -p 3306 myapp.com
nmap --script pgsql-brute -p 5432 myapp.com

# SSH
nmap --script ssh2-enum-algos -p 22 myapp.com
nmap --script ssh-brute -p 22 myapp.com

# SMB
nmap --script smb-vuln-* -p 445 myapp.com
nmap --script smb-enum-shares -p 445 myapp.com

# ── Vulnerability category ──
nmap --script vuln myapp.com
nmap --script "vuln and safe" myapp.com

# ── Script categories ──
# auth, broadcast, brute, default, discovery, dos,
# exploit, external, fuzzer, intrusive, malware, safe, vuln, version
nmap --script "safe and discovery" myapp.com

# ── Script with arguments ──
nmap --script http-brute --script-args 'userdb=users.txt,passdb=passwords.txt' -p 80 myapp.com
```

---

## Timing & Performance

```bash
# ── Timing templates ──
# T0 = Paranoid (IDS evasion)
# T1 = Sneaky
# T2 = Polite
# T3 = Normal (default)
# T4 = Aggressive
# T5 = Insane

nmap -T4 myapp.com          # Faster
nmap -T1 myapp.com          # Slower, stealthy

# ── Custom timing ──
nmap --min-rate 1000 myapp.com              # Min 1000 packets/sec
nmap --max-retries 2 myapp.com              # Max probe retries
nmap --host-timeout 300s myapp.com          # Max time per host
nmap --scan-delay 1s myapp.com              # Delay between probes

# ── Parallel hosts ──
nmap --min-hostgroup 64 192.168.1.0/24
```

---

## Output Formats

```bash
# ── Normal output ──
nmap -oN scan_results.txt myapp.com

# ── XML output ──
nmap -oX scan_results.xml myapp.com

# ── Grepable output ──
nmap -oG scan_results.gnmap myapp.com

# ── All formats ──
nmap -oA scan_results myapp.com    # Creates .nmap, .xml, .gnmap

# ── Append to file ──
nmap --append-output -oN scan_results.txt myapp.com

# ── Verbose/debug ──
nmap -v myapp.com        # Verbose
nmap -vv myapp.com       # Very verbose
nmap -d myapp.com        # Debug
```

---

## Common Scan Profiles

```bash
# ── Quick security audit ──
nmap -sV -sC --top-ports 1000 -T4 -oA quick_audit myapp.com

# ── Full port scan with service detection ──
nmap -sV -sC -p- -T4 -oA full_scan myapp.com

# ── Web server assessment ──
nmap -sV -p 80,443,8080,8443 \
  --script "http-* and safe" \
  --script ssl-cert,ssl-enum-ciphers \
  -oA web_assessment myapp.com

# ── SSL/TLS audit ──
nmap -sV -p 443 \
  --script ssl-cert,ssl-enum-ciphers,ssl-heartbleed,ssl-poodle \
  -oA ssl_audit myapp.com

# ── Internal network discovery ──
nmap -sn -PR 10.0.0.0/24 -oG hosts.gnmap
grep "Up" hosts.gnmap | awk '{print $2}' > live_hosts.txt
nmap -sV -sC -iL live_hosts.txt -oA internal_scan

# ── Firewall detection ──
nmap -sA -p 80,443 myapp.com
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Authorization** | Always have written permission before scanning |
| **Scope** | Define exact targets and excluded hosts/ports |
| **Start small** | Quick scan first, then comprehensive |
| **Rate limit** | Use `-T2` or `--scan-delay` for production |
| **Save output** | Always use `-oA` for all output formats |
| **Version detection** | `-sV` reveals outdated/vulnerable services |
| **NSE scripts** | Use `safe` category for non-intrusive testing |
| **SSL audit** | Test cipher suites, certificate validity |
| **Combine tools** | Nmap discovery → Nikto/ZAP for web vuln testing |
| **Regular scans** | Weekly/monthly scans for new exposure |

---

## Rules Integration
- **Discovery**: Host discovery (ping scan), port scanning (SYN/Connect)
- **Detection**: Service version, OS fingerprinting, banner grabbing
- **NSE**: Vulnerability scripts (SSL, HTTP, SMB, SQL, SSH)
- **Timing**: T0-T5 templates, rate limiting, parallelism
- **Output**: Normal, XML, grepable formats for automation
