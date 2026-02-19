---
name: WHMCS
description: Skill for developing with WHMCS billing and automation platform, covering module development, API integration, hooks, themes, and hosting automation.
---

# WHMCS Skill

## Overview
WHMCS is a web hosting billing and automation platform. This skill covers module development, API integration, hooks system, template customization, and addon creation.

## Directory Structure
```
whmcs/
├── modules/
│   ├── servers/           # Provisioning modules
│   │   └── myhosting/
│   │       ├── myhosting.php
│   │       └── lib/
│   ├── registrars/        # Domain registrar modules
│   │   └── myregistrar/
│   ├── gateways/          # Payment gateways
│   │   └── mypayment/
│   ├── addons/            # Admin addon modules
│   │   └── myaddon/
│   │       ├── myaddon.php
│   │       └── hooks.php
│   └── widgets/           # Dashboard widgets
├── templates/             # Client area themes
│   └── mytheme/
│       ├── header.tpl
│       ├── footer.tpl
│       └── clientarea.tpl
├── includes/
│   └── hooks/             # Custom hook files
│       └── custom_hooks.php
└── configuration.php      # DB & app config
```

## Server Provisioning Module
```php
<?php
// modules/servers/myhosting/myhosting.php

function myhosting_MetaData(): array
{
    return [
        'DisplayName' => 'My Hosting Provider',
        'APIVersion' => '1.1',
        'RequiresServer' => true,
    ];
}

function myhosting_ConfigOptions(): array
{
    return [
        'Package' => [
            'Type' => 'dropdown',
            'Options' => 'Basic,Pro,Enterprise',
            'Description' => 'Hosting package type',
        ],
        'Disk Space' => [
            'Type' => 'text',
            'Size' => 10,
            'Default' => '10240',
            'Description' => 'Disk space in MB',
        ],
    ];
}

function myhosting_CreateAccount(array $params): string
{
    try {
        $domain     = $params['domain'];
        $username   = $params['username'];
        $password   = $params['password'];
        $package    = $params['configoption1'];
        $diskSpace  = $params['configoption2'];
        $serverIp   = $params['serverip'];
        $serverUser = $params['serverusername'];
        $serverPass = decrypt($params['serverpassword']);

        // API call to provision server
        $api = new MyHostingAPI($serverIp, $serverUser, $serverPass);
        $result = $api->createAccount([
            'domain'    => $domain,
            'username'  => $username,
            'password'  => $password,
            'package'   => $package,
            'diskspace' => $diskSpace,
        ]);

        if (!$result['success']) {
            throw new \Exception($result['message']);
        }

        return 'success';
    } catch (\Exception $e) {
        logModuleCall('myhosting', __FUNCTION__, $params, $e->getMessage());
        return $e->getMessage();
    }
}

function myhosting_SuspendAccount(array $params): string
{
    // Suspend hosting account
    return 'success';
}

function myhosting_UnsuspendAccount(array $params): string
{
    // Unsuspend hosting account
    return 'success';
}

function myhosting_TerminateAccount(array $params): string
{
    // Delete hosting account
    return 'success';
}

function myhosting_ChangePassword(array $params): string
{
    // Change account password
    return 'success';
}
```

## Hook System
```php
<?php
// includes/hooks/custom_hooks.php

use WHMCS\User\Client;

// After client signs up
add_hook('ClientAdd', 1, function (array $vars) {
    $clientId = $vars['userid'];
    $email    = $vars['email'];

    // Send to CRM, analytics, etc.
    logActivity("New client registered: {$email} (ID: {$clientId})");
});

// After invoice is paid
add_hook('InvoicePaid', 1, function (array $vars) {
    $invoiceId = $vars['invoiceid'];
    // Trigger custom automation
});

// Before product provisioning
add_hook('PreModuleCreate', 1, function (array $vars) {
    // Custom validation before account creation
    return $vars; // Return modified vars or throw exception to abort
});

// After order is accepted
add_hook('AcceptOrder', 1, function (array $vars) {
    $orderId = $vars['orderid'];
    // Send notification to admin
});

// Daily cron job
add_hook('DailyCronJob', 1, function () {
    // Run daily maintenance tasks
});
```

## WHMCS API (Internal)
```php
<?php
// Internal API call (from within WHMCS)
$result = localAPI('GetClients', [
    'limitstart' => 0,
    'limitnum'   => 25,
    'sorting'    => 'id',
    'sortorder'  => 'DESC',
]);

if ($result['result'] === 'success') {
    foreach ($result['clients']['client'] as $client) {
        echo $client['firstname'] . ' ' . $client['lastname'];
    }
}

// Create invoice
localAPI('CreateInvoice', [
    'userid'    => 1,
    'date'      => date('Y-m-d'),
    'duedate'   => date('Y-m-d', strtotime('+30 days')),
    'itemdescription1' => 'Custom Service',
    'itemamount1'      => '99.99',
    'autoapplyredit'   => true,
]);
```

## WHMCS External API
```bash
# External API call
curl -X POST "https://billing.example.com/includes/api.php" \
  -d "action=GetClients" \
  -d "username=api_admin" \
  -d "password=api_password" \
  -d "responsetype=json"
```

```php
<?php
// PHP external API call
$ch = curl_init('https://billing.example.com/includes/api.php');
curl_setopt_array($ch, [
    CURLOPT_POST       => true,
    CURLOPT_POSTFIELDS => http_build_query([
        'action'       => 'GetClients',
        'username'     => $apiUser,
        'password'     => $apiPassword,
        'responsetype' => 'json',
    ]),
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_SSL_VERIFYPEER => true,
]);
$response = json_decode(curl_exec($ch), true);
curl_close($ch);
```

## Addon Module
```php
<?php
// modules/addons/myaddon/myaddon.php

function myaddon_config(): array
{
    return [
        'name'        => 'My Addon',
        'description' => 'Custom addon for WHMCS',
        'version'     => '1.0.0',
        'author'      => 'My Company',
        'fields'      => [
            'api_key' => [
                'FriendlyName' => 'API Key',
                'Type'         => 'password',
                'Size'         => 50,
                'Description'  => 'Enter your API key',
            ],
        ],
    ];
}

function myaddon_activate(): array { return ['status' => 'success']; }
function myaddon_deactivate(): array { return ['status' => 'success']; }

function myaddon_output(array $vars): void
{
    $apiKey = $vars['api_key'];
    echo '<h2>My Addon Dashboard</h2>';
    echo '<p>Addon content here...</p>';
}
```

## Rules Integration
- **Security**: Use `decrypt()` for stored credentials, validate all API inputs, use HTTPS
- **Database**: WHMCS uses MySQL — follow database design rules for custom tables
- **PHP**: Follow PHP 8.3+ skill for module code quality
