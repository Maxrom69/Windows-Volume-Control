@echo off
:: Windows Volume Control - Batch Script
:: Sets system volume to specified percentage
:: Usage: setvolume.bat [0-100]

setlocal enabledelayedexpansion

:: Parse command line arguments
if "%1"=="" (
    echo Usage: %~nx0 [0-100]
    echo Examples:
    echo   %~nx0 0     ^(Mute^)
    echo   %~nx0 25    ^(25%% volume^)
    echo   %~nx0 50    ^(50%% volume^)
    echo   %~nx0 75    ^(75%% volume^)
    echo   %~nx0 100   ^(100%% volume^)
    goto :eof
)

:: Validate input
set "volume=%1"
echo %volume%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo Error: Volume must be a number between 0 and 100
    goto :eof
)

if %volume% GTR 100 (
    echo Error: Volume cannot exceed 100
    goto :eof
)

:: Create temporary VBScript for volume control
set "vbsfile=%temp%\setvolume.vbs"

(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo Set oShell = CreateObject^("Shell.Application"^)
echo.
echo ' First, mute all the way down
echo For i = 1 To 50
echo     WshShell.SendKeys chr^(174^)
echo     WScript.Sleep 50
echo Next
echo.
echo ' Then step up to desired volume
echo steps = %volume% / 2
echo For i = 1 To steps
echo     WshShell.SendKeys chr^(175^)
echo     WScript.Sleep 50
echo Next
echo.
echo WScript.Echo "Volume set to approximately %volume%%%"
) > "%vbsfile%"

:: Execute the VBScript
cscript //nologo "%vbsfile%"

:: Clean up
del "%vbsfile%" 2>nul

endlocal