@echo off
:: Simple Volume Control Script
:: Quick volume control using SendKeys

setlocal enabledelayedexpansion

:: Parse arguments
set "action=%1"
set "value=%2"

if "%action%"=="up" goto :volume_up
if "%action%"=="down" goto :volume_down
if "%action%"=="mute" goto :mute_toggle
if "%action%"=="set" goto :set_volume

echo Usage: %~nx0 [up^|down^|mute^|set] [value]
echo Examples:
echo   %~nx0 up       - Volume up
echo   %~nx0 down     - Volume down
echo   %~nx0 mute     - Toggle mute
echo   %~nx0 set 50   - Set volume to 50%%
goto :eof

:volume_up
powershell -Command "& {$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys([char]175)}"
goto :eof

:volume_down
powershell -Command "& {$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys([char]174)}"
goto :eof

:mute_toggle
powershell -Command "& {$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys([char]173)}"
goto :eof

:set_volume
if "%value%"=="" (
    echo Error: Please specify a volume value (0-100)
    goto :eof
)

:: Validate input
echo %value%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo Error: Volume must be a number
    goto :eof
)

if %value% GTR 100 (
    echo Error: Volume cannot exceed 100
    goto :eof
)

:: Set volume using PowerShell
powershell -Command "& {$wsh = New-Object -ComObject WScript.Shell; 1..50 | %% {$wsh.SendKeys([char]174)}; 1..[math]::Round(%value%/2) | %% {$wsh.SendKeys([char]175)}; Write-Host 'Volume set to approximately %value%%%'}"

endlocal