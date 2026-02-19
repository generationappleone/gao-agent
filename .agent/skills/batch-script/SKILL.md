---
name: Batch Script (BAT/CMD)
description: Skill for writing Windows batch scripts — covering CMD syntax, variables, control flow (IF/FOR/GOTO), error handling, file operations, registry, services, networking commands, and common automation patterns (build scripts, deployment, backup, scheduled tasks).
---

# Batch Script (BAT/CMD) Skill

## Overview
Batch files (.bat/.cmd) are Windows command-line scripts for automation, deployment, system administration, and build tasks. This skill covers the Windows CMD interpreter syntax following Microsoft's global standards.

**Reference**: [Microsoft CMD Documentation](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)

## Standard Template
```batch
@echo off
setlocal EnableDelayedExpansion
REM ============================================================
REM  Script Name: script-name.bat
REM  Description: Brief description
REM  Author:      Your Name
REM  Version:     1.0.0
REM ============================================================

set "APP_NAME=MyApp"
set "LOG_FILE=%~dp0logs\%APP_NAME%.log"

call :Main
exit /b %ERRORLEVEL%

:Main
    echo [INFO] Starting %APP_NAME%...
    call :ValidatePrerequisites || goto :ErrorHandler
    call :RunProcess || goto :ErrorHandler
    echo [INFO] Completed successfully.
    exit /b 0

:ValidatePrerequisites
    where node >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Node.js is not installed.
        exit /b 1
    )
    exit /b 0

:RunProcess
    echo [INFO] Running main process...
    exit /b 0

:ErrorHandler
    echo [ERROR] Script failed. Check logs.
    exit /b 1
```

## Core Syntax

### Echo & Output
```batch
@echo off                    REM Suppress command echoing
echo Hello, World!           REM Print text
echo.                        REM Print blank line
echo %DATE% %TIME%           REM Print date and time
echo Log entry >> "%LOG_FILE%"    REM Append to file
echo Overwrite > "%LOG_FILE%"     REM Overwrite file
command > "%LOG_FILE%" 2>&1       REM Redirect stdout+stderr
command >nul 2>&1                 REM Suppress all output
```

### Comments
```batch
REM This is a comment (Remark)
:: This is also a comment (avoid in IF/FOR blocks)
```

### Variables
```batch
set "VARIABLE=value"                  REM Always quote assignment
set /a "COUNTER=10+5"                 REM Arithmetic
set /p "USER_INPUT=Enter value: "     REM User prompt

REM Reading variables
echo %VARIABLE%                       REM Normal expansion
echo !VARIABLE!                       REM Delayed expansion (in loops)

REM Special variables
echo %CD%          REM Current directory
echo %DATE%        REM Current date
echo %TIME%        REM Current time
echo %RANDOM%      REM Random (0-32767)
echo %ERRORLEVEL%  REM Last exit code
echo %USERNAME%    REM Current user
echo %USERPROFILE% REM User profile path
echo %TEMP%        REM Temp directory
echo %~dp0         REM Script directory

REM String operations
set "STR=Hello World"
echo %STR:World=Universe%    REM Replace
echo %STR:~0,5%              REM Substring: Hello
echo %STR:~6%                REM From pos: World
```

### Parameters (Arguments)
```batch
REM %0=Script, %1=First arg, %*=All args
echo %~1       REM Remove quotes
echo %~f1      REM Full path
echo %~n1      REM File name only
echo %~x1      REM Extension only
echo %~dp0     REM Script directory

if "%~1"=="" (
    echo Usage: %~n0 ^<input^> ^<output^>
    exit /b 1
)
```

## Control Flow

### IF Statements
```batch
if "%VAR%"=="value" echo Match
if /i "%VAR%"=="Value" echo Case-insensitive match
if %NUM% equ 10 echo Equal
if %NUM% neq 10 echo Not equal
if %NUM% lss 10 echo Less than
if %NUM% gtr 10 echo Greater than
if exist "%FILE%" echo File exists
if defined MY_VAR echo Variable set

if %ERRORLEVEL% equ 0 (
    echo Success
) else (
    echo Failed: %ERRORLEVEL%
)

REM AND logic
if "%A%"=="1" if "%B%"=="2" echo Both match
```

### FOR Loops
```batch
for %%A in (apple banana cherry) do echo %%A
for %%F in (*.txt) do echo %%F
for /r "%DIR%" %%F in (*.log) do echo %%F
for /d %%D in (*) do echo Dir: %%D
for /l %%I in (1,1,10) do echo %%I

for /f "tokens=1,2 delims=," %%A in (data.csv) do (
    echo %%A - %%B
)
for /f "tokens=*" %%A in ('dir /b *.txt') do echo %%A
```

### GOTO & Subroutines
```batch
goto :SectionName
:SectionName
echo In section
goto :eof

call :MyFunction "arg1" "arg2"
goto :eof

:MyFunction
    set "P1=%~1"
    echo Processing %P1%
    exit /b 0
```

## Error Handling
```batch
command && echo Success || echo Failed
command1 && command2 || goto :ErrorHandler

xcopy "%SRC%" "%DST%" /e /y
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)
```

## File Operations
```batch
mkdir "path\to\dir"                   REM Create directory
copy "src.txt" "dst.txt" /y           REM Copy file
xcopy "src\" "dst\" /e /i /y /h       REM Copy tree
robocopy "src" "dst" /e /mir /r:3     REM Robust copy
move "file.txt" "dest\"               REM Move
ren "old.txt" "new.txt"               REM Rename
del "file.txt" /f /q                  REM Delete file
rmdir "dir" /s /q                     REM Delete directory
dir /b /s "*.log"                     REM Recursive list
```

## Build Script Pattern
```batch
@echo off
setlocal
set "PROJECT_DIR=%~dp0"

echo [1/4] Cleaning...
if exist "build" rmdir /s /q "build"

echo [2/4] Installing dependencies...
call npm ci || (echo [ERROR] Install failed & exit /b 1)

echo [3/4] Running tests...
call npm test || (echo [ERROR] Tests failed & exit /b 1)

echo [4/4] Building...
call npm run build || (echo [ERROR] Build failed & exit /b 1)

echo Build completed successfully!
exit /b 0
```

## Service & Admin
```batch
REM Admin check
net session >nul 2>&1 || (
    echo [ERROR] Requires Administrator privileges.
    exit /b 1
)

REM Service management
net start "ServiceName"
net stop "ServiceName"
sc query "ServiceName"

REM Scheduled task
schtasks /create /tn "MyApp\Backup" /tr "%~dp0backup.bat" /sc daily /st 02:00
```

## Networking
```batch
ping -n 4 google.com
tracert google.com
ipconfig /all
netstat -an
curl -o "file.zip" "https://example.com/file.zip"
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **`@echo off`** | Always start scripts with this |
| **`setlocal`** | Avoid polluting global environment |
| **`EnableDelayedExpansion`** | Enable for variables inside loops |
| **Quote paths** | Always: `"%VARIABLE%"` |
| **Quote SET** | Use `set "VAR=value"` |
| **Check ERRORLEVEL** | After every critical operation |
| **Use `call`** | For subroutines and external .bat files |
| **Use `exit /b`** | Not `exit` (avoids closing parent shell) |
| **`%~dp0`** | Script directory for portable paths |
| **Escape chars** | Use `^` to escape: `^|`, `^&`, `^>`, `^<` |

## File Conventions
```
script.bat     # .bat (most common)
script.cmd     # .cmd (Windows NT+, preferred for new scripts)
build.bat      # Build script
deploy.bat     # Deployment
setup.bat      # Environment setup
backup.bat     # Backup automation
```

## Rules Integration
- **Security**: Never hardcode passwords — use environment variables
- **Portability**: Use `%~dp0` for relative paths, avoid hardcoded drives
- **Logging**: Log operations with timestamps for auditing
- **Error Handling**: Check `%ERRORLEVEL%` after critical commands
- **Admin Check**: Verify privileges when operations need elevation
