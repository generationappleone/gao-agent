---
name: ServiceNow
description: Skill for ServiceNow platform development — covering Table API, Scripted REST APIs, GlideRecord, Business Rules, Client Scripts, Flow Designer, Service Catalog, CMDB, ITSM modules, and integration patterns.
---

# ServiceNow Skill

## Overview
ServiceNow is an enterprise cloud platform for IT Service Management (ITSM), IT Operations Management (ITOM), and IT Business Management (ITBM). This skill covers core development patterns, REST API integration, scripting, and best practices.

**References:**
- [ServiceNow Developer Portal](https://developer.servicenow.com/)
- [ServiceNow REST API Documentation](https://docs.servicenow.com/bundle/latest/page/integrate/inbound-rest/concept/c_RESTAPI.html)
- [ServiceNow API Reference](https://developer.servicenow.com/dev.do#!/reference)

## Table API (Out-of-the-Box)

### GET — Query Records
```javascript
// GET /api/now/table/{tableName}
// Fetch incidents with filters
const response = await fetch(
  `${INSTANCE_URL}/api/now/table/incident?sysparm_query=active=true^priority=1&sysparm_limit=10&sysparm_offset=0&sysparm_fields=number,short_description,state,priority,assigned_to`,
  {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  }
);

const data = await response.json();
// Response: { result: [ { number: 'INC0010001', short_description: '...', ... } ] }
```

### POST — Create Record
```javascript
// POST /api/now/table/{tableName}
const response = await fetch(
  `${INSTANCE_URL}/api/now/table/incident`,
  {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      short_description: 'Server disk space critical',
      description: 'Disk usage on web-server-01 exceeds 95%',
      category: 'Hardware',
      subcategory: 'Disk',
      impact: '2',
      urgency: '1',
      assignment_group: 'Infrastructure',
      caller_id: 'admin',
    }),
  }
);

const created = await response.json();
// Response: { result: { sys_id: '...', number: 'INC0010042', ... } }
```

### PUT — Update Record
```javascript
// PUT /api/now/table/{tableName}/{sys_id}
const response = await fetch(
  `${INSTANCE_URL}/api/now/table/incident/${sysId}`,
  {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      state: '6', // Resolved
      close_code: 'Solved (Permanently)',
      close_notes: 'Disk cleanup and monitoring alert threshold adjusted.',
    }),
  }
);
```

### DELETE — Delete Record
```javascript
// DELETE /api/now/table/{tableName}/{sys_id}
const response = await fetch(
  `${INSTANCE_URL}/api/now/table/incident/${sysId}`,
  {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Accept': 'application/json',
    },
  }
);
// Response: 204 No Content
```

## Authentication

### OAuth 2.0 (Recommended)
```javascript
// 1. Register OAuth Application in ServiceNow
//    System OAuth > Application Registry > Create OAuth API endpoint
//
// 2. Request Token
const tokenResponse = await fetch(
  `${INSTANCE_URL}/oauth_token.do`,
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'password',
      client_id: process.env.SNOW_CLIENT_ID,
      client_secret: process.env.SNOW_CLIENT_SECRET,
      username: process.env.SNOW_USERNAME,
      password: process.env.SNOW_PASSWORD,
    }),
  }
);

const { access_token, refresh_token, expires_in } = await tokenResponse.json();
```

### Basic Authentication
```javascript
// ⚠️ Use only for development / internal scripts
const headers = {
  'Authorization': 'Basic ' + Buffer.from(`${username}:${password}`).toString('base64'),
  'Accept': 'application/json',
  'Content-Type': 'application/json',
};
```

## Scripted REST APIs

### Create Custom API Endpoint
```javascript
// In ServiceNow Studio or Navigator:
// System Web Services > Scripted REST APIs > New

// API Resource Script (server-side JavaScript)
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {

  var queryParams = request.queryParams;
  var body = request.body.data;
  var pathParams = request.pathParams;

  // Validate input
  if (!body.name || !body.email) {
    response.setStatus(400);
    response.setBody({
      error: {
        message: 'Missing required fields: name, email',
        detail: 'Both name and email are required',
      },
    });
    return;
  }

  // Query the database
  var gr = new GlideRecord('sys_user');
  gr.addQuery('email', body.email);
  gr.query();

  if (gr.next()) {
    response.setStatus(200);
    response.setBody({
      result: {
        sys_id: gr.getValue('sys_id'),
        name: gr.getValue('name'),
        email: gr.getValue('email'),
        active: gr.getValue('active'),
      },
    });
  } else {
    response.setStatus(404);
    response.setBody({
      error: {
        message: 'User not found',
        detail: 'No user found with email: ' + body.email,
      },
    });
  }

})(request, response);
```

## GlideRecord — Server-Side Scripting

### Query Patterns
```javascript
// Basic query
var gr = new GlideRecord('incident');
gr.addQuery('active', true);
gr.addQuery('priority', '1');
gr.orderByDesc('sys_created_on');
gr.setLimit(50);
gr.query();

while (gr.next()) {
  var number = gr.getValue('number');
  var desc = gr.getValue('short_description');
  var state = gr.getValue('state');
  gs.info('Incident: ' + number + ' — ' + desc);
}

// Encoded query (complex filters)
var gr = new GlideRecord('incident');
gr.addEncodedQuery('active=true^priority=1^stateIN1,2,3^assigned_toISNOTEMPTY');
gr.query();

// Aggregate (counts, sums — more efficient than looping)
var ga = new GlideAggregate('incident');
ga.addQuery('active', true);
ga.addAggregate('COUNT');
ga.groupBy('priority');
ga.query();

while (ga.next()) {
  var priority = ga.getValue('priority');
  var count = ga.getAggregate('COUNT');
  gs.info('Priority ' + priority + ': ' + count + ' incidents');
}
```

### Insert / Update
```javascript
// Insert new record
var gr = new GlideRecord('incident');
gr.initialize();
gr.setValue('short_description', 'New incident from script');
gr.setValue('category', 'Software');
gr.setValue('impact', '2');
gr.setValue('urgency', '2');
var sysId = gr.insert();

// Update existing record
var gr = new GlideRecord('incident');
if (gr.get('number', 'INC0010001')) {
  gr.setValue('state', '6'); // Resolved
  gr.setValue('close_notes', 'Issue resolved via automated script');
  gr.update();
}
```

## Business Rules

### Before Insert / Update
```javascript
// Business Rule: Validate Priority Consistency
// Table: incident
// When: before insert, before update
// Condition: current.impact.changes() || current.urgency.changes()

(function executeRule(current, previous) {
  // Auto-calculate priority from impact + urgency matrix
  var impact = parseInt(current.getValue('impact'));
  var urgency = parseInt(current.getValue('urgency'));

  // Priority matrix (ServiceNow standard)
  var priorityMatrix = {
    '1-1': '1', '1-2': '2', '1-3': '3',
    '2-1': '2', '2-2': '3', '2-3': '4',
    '3-1': '3', '3-2': '4', '3-3': '5',
  };

  var key = impact + '-' + urgency;
  var calculatedPriority = priorityMatrix[key] || '4';
  current.setValue('priority', calculatedPriority);

})(current, previous);
```

### Async Business Rule
```javascript
// Business Rule: Send Notification on P1 Incident
// Table: incident
// When: after insert
// Condition: current.priority == '1'
// Advanced: checked, Order: 200

(function executeRule(current, previous) {
  // Trigger event for notification
  gs.eventQueue('incident.p1.created', current, current.getValue('number'),
    current.getValue('short_description'));

  // Log for audit
  gs.info('P1 Incident created: ' + current.getValue('number'));

})(current, previous);
```

## Client Scripts

### onChange Script
```javascript
// Client Script: Auto-fill Category
// Type: onChange
// Field: subcategory

function onChange(control, oldValue, newValue, isLoading) {
  if (isLoading || newValue === '') return;

  // Map subcategory to category
  var categoryMap = {
    'Email': 'Software',
    'VPN': 'Network',
    'Disk': 'Hardware',
    'Memory': 'Hardware',
    'Firewall': 'Network',
  };

  var category = categoryMap[newValue];
  if (category) {
    g_form.setValue('category', category);
  }
}
```

### onSubmit Validation
```javascript
// Client Script: Validate Required Fields
// Type: onSubmit

function onSubmit() {
  var shortDesc = g_form.getValue('short_description');
  var category = g_form.getValue('category');

  if (!shortDesc || shortDesc.trim() === '') {
    g_form.showFieldMsg('short_description', 'Short description is required', 'error');
    return false; // Prevent form submission
  }

  if (!category) {
    g_form.showFieldMsg('category', 'Please select a category', 'error');
    return false;
  }

  return true; // Allow submission
}
```

## Flow Designer

### Trigger → Action → Subflow Pattern
```yaml
# Flow: Auto-Assign P1 Incidents
Trigger: Record Created (incident)
Condition: Priority = 1

Actions:
  1. Look Up Records:
     Table: sys_user_group
     Filter: name = "Critical Incident Team"

  2. Update Record:
     Table: incident
     Record: Trigger.Record
     Fields:
       assignment_group: Step 1.sys_id
       state: 2 (In Progress)

  3. Send Notification:
     To: Critical Incident Team members
     Subject: "[P1] {{Trigger.Record.number}} — {{Trigger.Record.short_description}}"
     Template: P1 Incident Alert

  4. Create Task:
     Table: sn_hr_core_task
     Fields:
       short_description: "Follow up on P1: {{Trigger.Record.number}}"
       assigned_to: On-Call Manager
```

## Integration Patterns

### Outbound REST (ServiceNow → External)
```javascript
// REST Message: Call External API from ServiceNow
var restMessage = new sn_ws.RESTMessageV2('External_Alert_API', 'POST');
restMessage.setRequestHeader('Content-Type', 'application/json');
restMessage.setRequestHeader('Authorization', 'Bearer ' + gs.getProperty('external.api.token'));

restMessage.setRequestBody(JSON.stringify({
  incident_number: current.getValue('number'),
  severity: current.getValue('priority'),
  description: current.getValue('short_description'),
  timestamp: new GlideDateTime().toString(),
}));

var response = restMessage.execute();
var statusCode = response.getStatusCode();
var responseBody = response.getBody();

if (statusCode !== 200) {
  gs.error('External API call failed: ' + statusCode + ' — ' + responseBody);
}
```

### Node.js Integration Client
```typescript
// servicenow-client.ts
import axios, { AxiosInstance } from 'axios';

interface ServiceNowConfig {
  instanceUrl: string;
  username: string;
  password: string;
}

interface Incident {
  sys_id?: string;
  number?: string;
  short_description: string;
  description?: string;
  category?: string;
  impact?: string;
  urgency?: string;
  state?: string;
  assigned_to?: string;
  assignment_group?: string;
}

class ServiceNowClient {
  private client: AxiosInstance;

  constructor(config: ServiceNowConfig) {
    this.client = axios.create({
      baseURL: `${config.instanceUrl}/api/now`,
      auth: {
        username: config.username,
        password: config.password,
      },
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    });
  }

  async getIncidents(query: string, limit = 20, offset = 0): Promise<Incident[]> {
    const response = await this.client.get('/table/incident', {
      params: {
        sysparm_query: query,
        sysparm_limit: limit,
        sysparm_offset: offset,
        sysparm_fields: 'sys_id,number,short_description,state,priority,assigned_to',
      },
    });
    return response.data.result;
  }

  async createIncident(incident: Incident): Promise<Incident> {
    const response = await this.client.post('/table/incident', incident);
    return response.data.result;
  }

  async updateIncident(sysId: string, fields: Partial<Incident>): Promise<Incident> {
    const response = await this.client.put(`/table/incident/${sysId}`, fields);
    return response.data.result;
  }

  async deleteIncident(sysId: string): Promise<void> {
    await this.client.delete(`/table/incident/${sysId}`);
  }
}

// Usage
const snow = new ServiceNowClient({
  instanceUrl: process.env.SNOW_INSTANCE_URL!,
  username: process.env.SNOW_USERNAME!,
  password: process.env.SNOW_PASSWORD!,
});

const p1Incidents = await snow.getIncidents('active=true^priority=1');
```

## CMDB (Configuration Management Database)

### CI Relationships
```javascript
// Query CMDB CIs
var gr = new GlideRecord('cmdb_ci_server');
gr.addQuery('operational_status', '1'); // Operational
gr.addQuery('os', 'CONTAINS', 'Linux');
gr.query();

while (gr.next()) {
  gs.info('Server: ' + gr.getValue('name') +
    ' | IP: ' + gr.getValue('ip_address') +
    ' | Class: ' + gr.getValue('sys_class_name'));
}

// Create CI Relationship
var rel = new GlideRecord('cmdb_rel_ci');
rel.initialize();
rel.setValue('parent', parentSysId);   // e.g., Application
rel.setValue('child', childSysId);     // e.g., Server
rel.setValue('type', relTypeSysId);    // e.g., "Runs on::Runs"
rel.insert();
```

## Query Parameters Reference

| Parameter | Description | Example |
|-----------|-------------|---------|
| `sysparm_query` | Encoded query filter | `active=true^priority=1` |
| `sysparm_fields` | Comma-separated field list | `number,state,priority` |
| `sysparm_limit` | Max records returned | `50` |
| `sysparm_offset` | Pagination offset | `100` |
| `sysparm_display_value` | Return display values | `true`, `false`, `all` |
| `sysparm_exclude_reference_link` | Omit reference links | `true` |
| `sysparm_suppress_pagination_header` | Remove pagination header | `true` |
| `sysparm_view` | UI view for field selection | `mobile` |

## Query Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equals | `priority=1` |
| `!=` | Not equals | `state!=7` |
| `STARTSWITH` | Starts with | `short_descriptionSTARTSWITHServer` |
| `ENDSWITH` | Ends with | `nameLIKE.com` |
| `CONTAINS` | Contains (slow on large tables) | `descriptionCONTAINSerror` |
| `IN` | In list | `stateIN1,2,3` |
| `NOTIN` | Not in list | `stateNOTIN6,7` |
| `ISEMPTY` | Is empty | `assigned_toISEMPTY` |
| `ISNOTEMPTY` | Is not empty | `assigned_toISNOTEMPTY` |
| `BETWEEN` | Between dates | `sys_created_onBETWEENjavascript:gs.beginningOfLastMonth()@javascript:gs.endOfLastMonth()` |
| `^` | AND | `active=true^priority=1` |
| `^OR` | OR | `priority=1^ORpriority=2` |

## Best Practices

| Practice | Description |
|----------|-------------|
| **Use Table API first** | Prefer out-of-the-box Table API over Scripted REST for standard CRUD |
| **Always paginate** | Use `sysparm_limit` + `sysparm_offset` for all list queries |
| **Minimize fields** | Always specify `sysparm_fields` to reduce payload size |
| **Use GlideAggregate** | For counts/sums, never loop GlideRecord just to count |
| **Index query fields** | Create indexes on fields used in `addQuery()` filters |
| **Avoid CONTAINS** | Use `STARTSWITH` or `=` on indexed fields for performance |
| **OAuth 2.0** | Always use OAuth 2.0 in production, never Basic Auth |
| **ACL protection** | Enable "Requires Authentication" on all custom REST APIs |
| **Error handling** | Return proper HTTP status codes and structured error bodies |
| **Versioning** | Version your Scripted REST APIs (`/api/x_custom/v1/...`) |
| **Scoped apps** | Develop in scoped applications for upgrade safety |
| **Update sets** | Track changes in update sets, never modify production directly |
| **Performance** | Use `gr.setLimit()` and avoid querying entire tables |
| **Testing** | Use Personal Developer Instance (PDI) for development/testing |

## ITSM Module Reference

| Module | Table | Key Fields |
|--------|-------|------------|
| Incident | `incident` | number, state, impact, urgency, priority |
| Problem | `problem` | number, state, category, root_cause |
| Change Request | `change_request` | number, type, risk, state, cab_required |
| Service Request | `sc_request` | number, stage, requested_for |
| Knowledge | `kb_knowledge` | number, topic, text, workflow_state |
| CMDB CI | `cmdb_ci` | name, sys_class_name, operational_status |
| User | `sys_user` | user_name, email, name, active |
| Group | `sys_user_group` | name, manager, active |
| Task | `task` | number, state, assigned_to, short_description |

## Environment Variables
```bash
# ServiceNow connection
SNOW_INSTANCE_URL=https://your-instance.service-now.com
SNOW_USERNAME=admin
SNOW_PASSWORD=secret
SNOW_CLIENT_ID=your_oauth_client_id
SNOW_CLIENT_SECRET=your_oauth_client_secret

# Optional
SNOW_API_VERSION=v1
SNOW_DEFAULT_LIMIT=50
```
