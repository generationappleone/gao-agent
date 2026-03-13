<#
.SYNOPSIS
    Find Test Polluter — Identifies which test pollutes shared state and makes other tests fail.

.DESCRIPTION
    Uses binary search to find which test, when run before a failing test,
    causes it to fail. Essential for finding order-dependent test failures.

.PARAMETER TestCommand
    The command to run tests (e.g., "npm test", "pytest", "dotnet test")

.PARAMETER FailingTest
    The specific test that fails when run after certain other tests

.PARAMETER AllTests
    Path to a file listing all test names/files, one per line

.EXAMPLE
    .\find-polluter.ps1 -TestCommand "npm test" -FailingTest "auth.test.ts" -AllTests "test-list.txt"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TestCommand,

    [Parameter(Mandatory = $true)]
    [string]$FailingTest,

    [Parameter(Mandatory = $true)]
    [string]$AllTests
)

$ErrorActionPreference = "Continue"

# Read all tests
$tests = Get-Content $AllTests | Where-Object { $_ -ne $FailingTest -and $_.Trim() -ne "" }
Write-Host "Total tests to check: $($tests.Count)" -ForegroundColor Cyan

function Test-WithSubset {
    param([string[]]$Subset)

    $testList = ($Subset + $FailingTest) -join " "
    Write-Host "  Running: $TestCommand $testList" -ForegroundColor DarkGray

    $result = Invoke-Expression "$TestCommand $testList" 2>&1
    $exitCode = $LASTEXITCODE

    return $exitCode -ne 0  # Returns $true if test FAILS (polluted)
}

# Phase 1: Verify the failing test fails with all tests
Write-Host "`n[Phase 1] Verify failing test fails with all tests..." -ForegroundColor Yellow
$failsWithAll = Test-WithSubset -Subset $tests
if (-not $failsWithAll) {
    Write-Host "ERROR: Failing test passes even with all tests. Not a pollution issue." -ForegroundColor Red
    exit 1
}

# Phase 2: Verify the failing test passes alone
Write-Host "`n[Phase 2] Verify failing test passes alone..." -ForegroundColor Yellow
$passesAlone = -not (Test-WithSubset -Subset @())
if (-not $passesAlone) {
    Write-Host "ERROR: Failing test also fails when run alone. Not a pollution issue." -ForegroundColor Red
    exit 1
}

# Phase 3: Binary search for polluter
Write-Host "`n[Phase 3] Binary search for polluter..." -ForegroundColor Yellow

$low = 0
$high = $tests.Count - 1
$iterations = 0
$maxIterations = [math]::Ceiling([math]::Log($tests.Count, 2)) + 2

while ($low -lt $high -and $iterations -lt $maxIterations) {
    $iterations++
    $mid = [math]::Floor(($low + $high) / 2)

    Write-Host "`n  Iteration $iterations`: Testing range [$low..$mid] (of [$low..$high])" -ForegroundColor Cyan

    $subset = $tests[$low..$mid]
    $fails = Test-WithSubset -Subset $subset

    if ($fails) {
        Write-Host "  -> Polluter is in range [$low..$mid]" -ForegroundColor Yellow
        $high = $mid
    }
    else {
        Write-Host "  -> Polluter is in range [$($mid+1)..$high]" -ForegroundColor Yellow
        $low = $mid + 1
    }
}

# Result
$polluter = $tests[$low]
Write-Host "`n================================" -ForegroundColor Green
Write-Host "POLLUTER FOUND: $polluter" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "`nThis test, when run before '$FailingTest', causes it to fail."
Write-Host "Searched $($tests.Count) tests in $iterations iterations.`n"

# Verification
Write-Host "[Verification] Confirming polluter..." -ForegroundColor Yellow
$confirmed = Test-WithSubset -Subset @($polluter)
if ($confirmed) {
    Write-Host "CONFIRMED: Running '$polluter' then '$FailingTest' causes failure." -ForegroundColor Green
}
else {
    Write-Host "WARNING: Could not confirm. The pollution may require multiple tests." -ForegroundColor Yellow
}
