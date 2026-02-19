---
name: PowerShell
description: Skill for Windows automation with PowerShell — covering cmdlets, pipelines, objects, functions, modules, error handling, file operations, remoting, and task automation.
---

# PowerShell Skill

## Overview
PowerShell is a cross-platform task automation and configuration management framework with an object-oriented pipeline. This skill covers PowerShell 7+ (Core).

**Reference**: [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)

## Script Template
```powershell
#Requires -Version 7.0

<#
.SYNOPSIS
    Brief description of the script.
.DESCRIPTION
    Detailed description.
.PARAMETER InputPath
    Path to input file.
.EXAMPLE
    .\script.ps1 -InputPath "C:\data\input.csv"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string]$InputPath,

    [Parameter()]
    [ValidateSet("Development", "Staging", "Production")]
    [string]$Environment = "Development",

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Main {
    Write-Host "[INFO] Starting process..." -ForegroundColor Cyan
    Test-Prerequisites
    Invoke-Process -Path $InputPath
    Write-Host "[INFO] Completed successfully!" -ForegroundColor Green
}

function Test-Prerequisites {
    if (-not (Get-Command "node" -ErrorAction SilentlyContinue)) {
        throw "Node.js is not installed."
    }
}

function Invoke-Process {
    param([string]$Path)
    $data = Import-Csv -Path $Path
    $data | ForEach-Object { Write-Host "Processing: $($_.Name)" }
}

try { Main }
catch {
    Write-Error "[ERROR] $($_.Exception.Message)"
    exit 1
}
```

## Core Concepts
```powershell
# Variables
$name = "John"
$count = 42
$items = @("apple", "banana", "cherry")     # Array
$config = @{ Host = "localhost"; Port = 5432 } # Hashtable

# Pipeline (object-based)
Get-Process | Where-Object { $_.CPU -gt 100 } | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU

# String interpolation
"Hello, $name! You have $($items.Count) items."

# Here-string
$json = @"
{
  "name": "$name",
  "count": $count
}
"@

# Splatting (clean parameter passing)
$params = @{
    Path        = "C:\data"
    Filter      = "*.log"
    Recurse     = $true
    ErrorAction = "SilentlyContinue"
}
Get-ChildItem @params
```

## File Operations
```powershell
# Read/Write
$content = Get-Content -Path "file.txt" -Raw
$content | Set-Content -Path "output.txt" -Encoding UTF8
"Log entry" | Add-Content -Path "app.log"

# CSV
$data = Import-Csv -Path "data.csv"
$data | Export-Csv -Path "output.csv" -NoTypeInformation

# JSON
$obj = Get-Content "config.json" | ConvertFrom-Json
$obj | ConvertTo-Json -Depth 10 | Set-Content "output.json"

# File management
New-Item -ItemType Directory -Path "newdir" -Force
Copy-Item -Path "src\*" -Destination "dst\" -Recurse
Remove-Item -Path "temp\*" -Recurse -Force
Test-Path "file.txt"  # Returns $true/$false
```

## Functions
```powershell
function Get-UserInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Username,

        [ValidateRange(1, 150)]
        [int]$MaxResults = 10
    )

    process {
        # Pipeline input handled here
        Write-Verbose "Looking up: $Username"
        [PSCustomObject]@{
            Name     = $Username
            Exists   = Test-Path "C:\Users\$Username"
            DateTime = Get-Date
        }
    }
}

# Usage
"admin", "guest" | Get-UserInfo -Verbose
```

## Error Handling
```powershell
try {
    $result = Invoke-RestMethod -Uri "https://api.example.com/data" -Method Get
}
catch [System.Net.WebException] {
    Write-Warning "Network error: $($_.Exception.Message)"
}
catch {
    Write-Error "Unexpected: $($_.Exception.Message)"
    throw
}
finally {
    Write-Host "Cleanup complete."
}
```

## REST API Calls
```powershell
# GET
$response = Invoke-RestMethod -Uri "https://api.example.com/users" -Method Get -Headers @{ Authorization = "Bearer $token" }

# POST
$body = @{ name = "John"; email = "john@example.com" } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.example.com/users" -Method Post -Body $body -ContentType "application/json"
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **`Set-StrictMode`** | Catch common coding errors |
| **`$ErrorActionPreference`** | Set to `"Stop"` for try/catch to work |
| **`[CmdletBinding()]`** | Enable advanced function features |
| **Verb-Noun naming** | Follow PowerShell naming convention |
| **`ValidateSet/Range`** | Validate parameters at declaration |
| **Pipeline support** | Use `process {}` block for pipeline input |
| **Splatting** | Use `@params` for clean parameter passing |
| **`-WhatIf` / `-Confirm`** | Support for destructive operations |
| **PSScriptAnalyzer** | Lint scripts with `Invoke-ScriptAnalyzer` |
| **`#Requires`** | Declare version and module dependencies |
