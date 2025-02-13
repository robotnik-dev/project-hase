@echo off
setlocal enabledelayedexpansion

:: Set your source and backup directories here
set "SOURCE_DIR=%CD%\..\rust\src"
set "BACKUP_DIR=%CD%\..\backup"
set "CHANGES_DETECTED=0"

:: Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
    echo Created backup directory: %BACKUP_DIR%
    echo.
    set "CHANGES_DETECTED=1"
)

:: First, check for new or modified files
for %%F in ("%SOURCE_DIR%\*.*") do (
    set "FOUND_CHANGES=0"
    set "FILENAME=%%~nxF"

    if exist "%BACKUP_DIR%\!FILENAME!" (
        :: Compare files using FC command
        fc /b "%%F" "%BACKUP_DIR%\!FILENAME!" > nul
        if errorlevel 1 (
            echo Modified file detected: !FILENAME!
            set "FOUND_CHANGES=1"
            set "CHANGES_DETECTED=1"
        )
    ) else (
        echo New file detected: !FILENAME!
        set "FOUND_CHANGES=1"
        set "CHANGES_DETECTED=1"
    )

    :: If changes found, update backup
    if !FOUND_CHANGES! equ 1 (
        copy /y "%%F" "%BACKUP_DIR%\!FILENAME!" > nul
    )
)

:: Check for deleted files
for %%F in ("%BACKUP_DIR%\*.*") do (
    set "FILENAME=%%~nxF"
    if not exist "%SOURCE_DIR%\!FILENAME!" (
        del "%BACKUP_DIR%\!FILENAME!"
        set "CHANGES_DETECTED=1"
    )
)

if %CHANGES_DETECTED% equ 0 (
    echo No changes detected.
)

exit /b %CHANGES_DETECTED%