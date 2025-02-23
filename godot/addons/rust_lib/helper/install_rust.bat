@echo off
setlocal

:: Download and install Rustup (which installs Rust)
curl --silent --show-error --location --output rustup-init.exe https://win.rustup.rs
if %ERRORLEVEL% neq 0 (
    echo Failed to download rustup installer.
    exit /b 1
)

:: Run the Rustup installer
rustup-init.exe -y
if %ERRORLEVEL% neq 0 (
    echo Rust installation failed.
    exit /b 1
)

:: Clean up installer
del rustup-init.exe

exit /b 0

endlocal