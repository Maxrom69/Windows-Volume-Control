@echo off
echo Testing Windows Volume Control implementations...
echo.
echo 1. Testing Batch implementation:
cd batch
volume.bat set 50
echo.
echo 2. Testing PowerShell implementation:
cd ..\powershell
powershell -ExecutionPolicy Bypass -Command "Import-Module .\AudioController.ps1; Get-AudioVolume"
echo.
echo 3. Testing Python implementation (if available):
cd ..\python
python --version 2>nul &&& python audio_controller.py get
echo.
echo Testing complete
