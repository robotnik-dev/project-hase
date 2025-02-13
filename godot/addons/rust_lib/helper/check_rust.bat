@echo off
setlocal

:: Check if rustc (Rust compiler) is available
where rustc >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Rust is NOT installed. 1>&2
    exit /b 1
) else (
    :: Display installed Rust version
    echo Rust is installed.
    echo Current rustc version
    rustc --version
    exit /b 0
)

endlocal
