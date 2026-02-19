---
name: MISP Threat Sharing
description: Skill for MISP — open-source threat intelligence platform for sharing, storing, and correlating Indicators of Compromise (IOCs).
---

# MISP — Threat Intelligence Platform

## Overview
MISP (Malware Information Sharing Platform) is an open-source threat intelligence platform for sharing, storing, and correlating IOCs and cyber threat intelligence.

## API
```python
from pymisp import PyMISP

misp = PyMISP('https://misp.example.com', 'YOUR_API_KEY', ssl=False)

# Search for IOCs
results = misp.search(type_attribute='ip-dst', value='1.2.3.4')

# Create event
event = misp.new_event(
    distribution=0, threat_level_id=2,
    analysis=1, info="Phishing Campaign 2024"
)

# Add attributes (IOCs)
misp.add_attribute(event, type='ip-dst', value='1.2.3.4')
misp.add_attribute(event, type='domain', value='malicious.example.com')
misp.add_attribute(event, type='md5', value='abc123...')
```

## Best Practices
- Use **MISP taxonomies** and **galaxies** for standardized tagging
- Enable **sync** with other MISP instances for community sharing
- Implement **warninglists** to filter false positives
