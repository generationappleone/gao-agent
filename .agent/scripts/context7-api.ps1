<#
.SYNOPSIS
    GAO Agent — Context7 API Client
    Search libraries and fetch up-to-date documentation from Context7.

.DESCRIPTION
    This script is used internally by GAO Agent to query the Context7 REST API
    for real-time library documentation. It eliminates hallucination by fetching
    current, version-specific docs before generating code.

.PARAMETER Action
    "search" — Search for a library and get its Context7 ID
    "docs"   — Fetch documentation for a specific library

.PARAMETER LibraryName
    Library name to search for (used with -Action search)

.PARAMETER LibraryId
    Context7-compatible library ID, e.g. "/vercel/next.js" (used with -Action docs)

.PARAMETER Query
    Natural language query to rank results or fetch relevant docs

.PARAMETER ApiKey
    Context7 API key. If not provided, reads from CONTEXT7_API_KEY env var.

.EXAMPLE
    # Search for a library
    .\context7-api.ps1 -Action search -LibraryName "next.js" -Query "server actions"

    # Fetch documentation
    .\context7-api.ps1 -Action docs -LibraryId "/vercel/next.js" -Query "middleware authentication"
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("search", "docs")]
    [string]$Action,

    [string]$LibraryName,
    [string]$LibraryId,
    [string]$Query = "",
    [string]$ApiKey = ""
)

# Resolve API key
if (-not $ApiKey) {
    $ApiKey = $env:CONTEXT7_API_KEY
}

if (-not $ApiKey) {
    # Try reading from .env file
    $envFile = Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent | Split-Path -Parent) ".env"
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile | Where-Object { $_ -match "^CONTEXT7_API_KEY=" }
        if ($envContent) {
            $ApiKey = ($envContent -split "=", 2)[1].Trim().Trim('"').Trim("'")
        }
    }
}

if (-not $ApiKey) {
    Write-Host "ERROR: CONTEXT7_API_KEY not found." -ForegroundColor Red
    Write-Host "Set it via:" -ForegroundColor Yellow
    Write-Host "  1. Environment variable: `$env:CONTEXT7_API_KEY = 'your_key'" -ForegroundColor Gray
    Write-Host "  2. .env file: CONTEXT7_API_KEY=your_key" -ForegroundColor Gray
    Write-Host "  3. Parameter: -ApiKey 'your_key'" -ForegroundColor Gray
    Write-Host "  Get a free key at: https://context7.com/dashboard" -ForegroundColor Cyan
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Accept"        = "application/json"
}

$baseUrl = "https://context7.com/api/v2"

try {
    switch ($Action) {
        "search" {
            if (-not $LibraryName) {
                Write-Host "ERROR: -LibraryName is required for search action." -ForegroundColor Red
                exit 1
            }

            $url = "$baseUrl/libs/search?libraryName=$([uri]::EscapeDataString($LibraryName))"
            if ($Query) {
                $url += "&query=$([uri]::EscapeDataString($Query))"
            }

            Write-Host "Searching Context7 for: $LibraryName ..." -ForegroundColor Cyan
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop

            if ($response.results -and $response.results.Count -gt 0) {
                Write-Host "`n=== Context7 Search Results ===" -ForegroundColor Green
                $response.results | ForEach-Object {
                    Write-Host "`n  ID:          $($_.id)" -ForegroundColor White
                    Write-Host "  Title:       $($_.title)" -ForegroundColor White
                    Write-Host "  Description: $($_.description)" -ForegroundColor Gray
                    Write-Host "  Stars:       $($_.stars)" -ForegroundColor Yellow
                    Write-Host "  Trust Score: $($_.trustScore)" -ForegroundColor Yellow
                    if ($_.versions) {
                        Write-Host "  Versions:    $($_.versions -join ', ')" -ForegroundColor Gray
                    }
                }

                # Output the first result ID for piping
                Write-Output $response.results[0].id
            }
            else {
                Write-Host "No results found for '$LibraryName'." -ForegroundColor Yellow
            }
        }

        "docs" {
            if (-not $LibraryId) {
                Write-Host "ERROR: -LibraryId is required for docs action." -ForegroundColor Red
                Write-Host "Use -Action search first to find the library ID." -ForegroundColor Gray
                exit 1
            }
            if (-not $Query) {
                Write-Host "ERROR: -Query is required for docs action." -ForegroundColor Red
                exit 1
            }

            $url = "$baseUrl/context?libraryId=$([uri]::EscapeDataString($LibraryId))&query=$([uri]::EscapeDataString($Query))&type=json"

            Write-Host "Fetching docs from Context7 for: $LibraryId ..." -ForegroundColor Cyan
            Write-Host "Query: $Query" -ForegroundColor Gray
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop

            Write-Host "`n=== Context7 Documentation ===" -ForegroundColor Green

            # Code Snippets
            if ($response.codeSnippets -and $response.codeSnippets.Count -gt 0) {
                Write-Host "`n--- Code Snippets ---" -ForegroundColor Cyan
                $response.codeSnippets | ForEach-Object {
                    Write-Host "`n  Title:    $($_.codeTitle)" -ForegroundColor White
                    Write-Host "  Language: $($_.codeLanguage)" -ForegroundColor Gray
                    Write-Host "  Source:   $($_.pageTitle)" -ForegroundColor Gray
                    if ($_.codeList) {
                        $_.codeList | ForEach-Object {
                            Write-Host "`n$($_.code)" -ForegroundColor White
                        }
                    }
                }
            }

            # Info Snippets
            if ($response.infoSnippets -and $response.infoSnippets.Count -gt 0) {
                Write-Host "`n--- Documentation ---" -ForegroundColor Cyan
                $response.infoSnippets | ForEach-Object {
                    Write-Host "`n  Path:    $($_.breadcrumb)" -ForegroundColor Gray
                    Write-Host "  Content: $($_.content)" -ForegroundColor White
                }
            }

            # Output raw JSON for piping
            $response | ConvertTo-Json -Depth 10
        }
    }
}
catch {
    Write-Host "ERROR: Failed to call Context7 API." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Yellow

    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        switch ($statusCode) {
            401 { Write-Host "Invalid API key. Get a new one at https://context7.com/dashboard" -ForegroundColor Yellow }
            429 { Write-Host "Rate limit exceeded. Wait a moment and try again, or upgrade your key." -ForegroundColor Yellow }
            default { Write-Host "HTTP Status: $statusCode" -ForegroundColor Yellow }
        }
    }
    exit 1
}
