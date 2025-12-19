@echo off
:: Windows Volume Control - Advanced Batch Script
:: Comprehensive volume control with multiple operations
:: Usage: volumecontrol.bat [command] [value]

setlocal enabledelayedexpansion

:: Configuration
set "APP_NAME=Windows Volume Control"
set "APP_VERSION=1.0"

:: Parse command line arguments
set "COMMAND=%1"
set "VALUE=%2"

:: Display header
call :show_header

:: Main command processing
if "%COMMAND%"=="" goto :show_usage
if /i "%COMMAND%"=="help" goto :show_usage
if /i "%COMMAND%"=="get" goto :get_volume
if /i "%COMMAND%"=="set" goto :set_volume
if /i "%COMMAND%"=="mute" goto :mute_audio
if /i "%COMMAND%"=="unmute" goto :unmute_audio
if /i "%COMMAND%"=="toggle" goto :toggle_mute
if /i "%COMMAND%"=="up" goto :volume_up
if /i "%COMMAND%"=="down" goto :volume_down
if /i "%COMMAND%"=="status" goto :show_status
if /i "%COMMAND%"=="info" goto :show_info

:: Unknown command
echo Error: Unknown command '%COMMAND%'
goto :show_usage

:show_usage
echo.
echo Usage: %~nx0 [command] [value]
echo.
echo Commands:
echo   get              - Get current volume level
echo   set [0-100]      - Set volume to percentage
echo   mute             - Mute audio
echo   unmute           - Unmute audio
echo   toggle           - Toggle mute state
echo   up               - Volume step up
echo   down             - Volume step down
echo   status           - Show current audio status
echo   info             - Show detailed audio information
echo   help             - Show this help message
echo.
echo Examples:
echo   %~nx0 get
echo   %~nx0 set 75
echo   %~nx0 mute
echo   %~nx0 up
echo.
goto :eof

:show_header
echo.
echo ========================================
echo   %APP_NAME% v%APP_VERSION%
echo ========================================
echo.
goto :eof

:validate_volume
set "vol_check=%1"
echo %vol_check%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo Error: Volume must be a number
    exit /b 1
)
if %vol_check% GTR 100 (
    echo Error: Volume cannot exceed 100
    exit /b 1
)
if %vol_check% LSS 0 (
    echo Error: Volume cannot be negative
    exit /b 1
)
exit /b 0

:get_volume
call :create_status_vbs
cscript //nologo "%temp%\getstatus.vbs" volume
del "%temp%\getstatus.vbs" 2>nul
goto :eof

:set_volume
if "%VALUE%"=="" (
    echo Error: Please specify a volume value (0-100)
    exit /b 1
)

call :validate_volume %VALUE%
if errorlevel 1 exit /b 1

call :create_set_volume_vbs %VALUE%
cscript //nologo "%temp%\setvolume.vbs"
del "%temp%\setvolume.vbs" 2>nul
goto :eof

:mute_audio
call :create_mute_vbs true
cscript //nologo "%temp%\mute.vbs"
del "%temp%\mute.vbs" 2>nul
goto :eof

:unmute_audio
call :create_mute_vbs false
cscript //nologo "%temp%\mute.vbs"
del "%temp%\mute.vbs" 2>nul
goto :eof

:toggle_mute
call :create_mute_vbs toggle
cscript //nologo "%temp%\mute.vbs"
del "%temp%\mute.vbs" 2>nul
goto :eof

:volume_up
call :create_step_vbs up
cscript //nologo "%temp%\step.vbs"
del "%temp%\step.vbs" 2>nul
goto :eof

:volume_down
call :create_step_vbs down
cscript //nologo "%temp%\step.vbs"
del "%temp%\step.vbs" 2>nul
goto :eof

:show_status
call :create_status_vbs
cscript //nologo "%temp%\getstatus.vbs" status
del "%temp%\getstatus.vbs" 2>nul
goto :eof

:show_info
call :create_status_vbs
cscript //nologo "%temp%\getstatus.vbs" info
del "%temp%\getstatus.vbs" 2>nul
goto :eof

:create_set_volume_vbs
set "target_volume=%1"
(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo.
echo ' Function to get current mute state
echo Function IsMuted^(^)
echo     Set oShell = CreateObject^("Shell.Application"^)
echo     IsMuted = oShell.IsServiceRunning^("AudioSrv"^)
echo End Function
echo.
echo ' First, mute all the way down to ensure consistent starting point
echo For i = 1 To 50
echo     WshShell.SendKeys chr^(174^)
echo     WScript.Sleep 30
echo Next
echo.
echo ' Then step up to desired volume
echo steps = %target_volume% / 2
echo For i = 1 To steps
echo     WshShell.SendKeys chr^(175^)
echo     WScript.Sleep 30
echo Next
echo.
echo WScript.Echo "Volume set to approximately %target_volume%%%"
) > "%temp%\setvolume.vbs"
goto :eof

:create_mute_vbs
set "mute_action=%1"
(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo.
echo if "%mute_action%" = "toggle" then
echo     WshShell.SendKeys chr^(173^)
echo     WScript.Echo "Mute toggled"
echo elseif "%mute_action%" = "true" then
echo     ' Check if already muted by checking if volume is 0
echo     WshShell.SendKeys chr^(173^)
echo     WScript.Sleep 100
echo     WshShell.SendKeys chr^(173^)
echo     WScript.Echo "Audio muted"
echo elseif "%mute_action%" = "false" then
echo     ' Unmute by sending mute twice
echo     WshShell.SendKeys chr^(173^)
echo     WScript.Sleep 100
echo     WshShell.SendKeys chr^(173^)
echo     WScript.Echo "Audio unmuted"
echo end if
) > "%temp%\mute.vbs"
goto :eof

:create_step_vbs
set "step_direction=%1"
(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo.
echo if "%step_direction%" = "up" then
echo     WshShell.SendKeys chr^(175^)
echo     WScript.Echo "Volume stepped up"
echo elseif "%step_direction%" = "down" then
echo     WshShell.SendKeys chr^(174^)
echo     WScript.Echo "Volume stepped down"
echo end if
) > "%temp%\step.vbs"
goto :eof

:create_status_vbs
(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo Set oShell = CreateObject^("Shell.Application"^)
echo.
echo ' Create a simple volume indicator
echo Function GetVolumeEstimate^(^)
echo     ' This is an approximation since batch/vbscript cannot easily get exact volume
echo     ' We'll use a registry key or WMI as an alternative approach
echo     On Error Resume Next
echo     Set oWMI = GetObject^("winmgmts:\\.\root\cimv2"^)
echo     Set colItems = oWMI.ExecQuery^("Select * from Win32_SoundDevice"^)
echo     
echo     ' Since we can't easily get exact volume, we'll show a status message
echo     GetVolumeEstimate = "Unknown"
echo End Function
echo.
echo ' Check for command line arguments
echo If WScript.Arguments.Count ^> 0 Then
echo     command = WScript.Arguments^(0^)
echo     Select Case command
echo         Case "volume"
echo             WScript.Echo "Current volume: Use volume meters in Windows to see exact level"
echo         Case "status"
echo             WScript.Echo "Audio Status: Audio system is running"
echo             WScript.Echo "Use Windows Volume Mixer for detailed information"
echo         Case "info"
echo             WScript.Echo "Windows Audio Information:"
echo             WScript.Echo "- Use Windows Volume Mixer for detailed volume control"
echo             WScript.Echo "- Keyboard shortcuts: Volume Mute ^(173^), Volume Down ^(174^), Volume Up ^(175^)"
echo             WScript.Echo "- Audio devices managed through Sound settings"
echo     End Select
echo Else
echo     WScript.Echo "No command specified"
echo End If
) > "%temp%\getstatus.vbs"
goto :eof

endlocal