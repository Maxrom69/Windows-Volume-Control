#!/usr/bin/env powershell
<#
.SYNOPSIS
    Audio Volume Control Demo Script

.DESCRIPTION
    Demonstrates various audio volume control operations using the AudioController module.

.NOTES
    Author: Marco Roussel
    Version: 1.0.0

.EXAMPLE
    .\AudioControlDemo.ps1
    # Runs the audio control demonstration
#>

# Import the audio controller module
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Join-Path $scriptPath "AudioController.ps1"

if (Test-Path $modulePath) {
    . $modulePath
} else {
    Write-Error "AudioController.ps1 not found at: $modulePath"
    exit 1
}

function Show-Menu {
    Clear-Host
    Write-Host "=== Windows Audio Volume Control Demo ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Current Audio Status:" -ForegroundColor Yellow
    Show-AudioStatus
    Write-Host ""
    Write-Host "Select an option:" -ForegroundColor Green
    Write-Host "1. Set Volume (0-100)"
    Write-Host "2. Volume Up (Step)"
    Write-Host "3. Volume Down (Step)"
    Write-Host "4. Mute Audio"
    Write-Host "5. Unmute Audio"
    Write-Host "6. Toggle Mute"
    Write-Host "7. Show Audio Status"
    Write-Host "8. Set Volume to 50%"
    Write-Host "9. Set Volume to 25%"
    Write-Host "10. Set Volume to 75%"
    Write-Host "11. Test Volume Range"
    Write-Host "Q. Quit"
    Write-Host ""
}

function Test-VolumeRange {
    Write-Host "`nTesting volume range..." -ForegroundColor Yellow
    
    $testVolumes = @(0, 10, 25, 50, 75, 90, 100)
    
    foreach ($volume in $testVolumes) {
        Write-Host "Setting volume to $volume%..." -NoNewline
        Set-AudioVolume -Volume $volume -Force
        Start-Sleep -Milliseconds 500
        $actualVolume = Get-AudioVolume
        Write-Host " Actual: $actualVolume%" -ForegroundColor $(if ($actualVolume -eq $volume) { 'Green' } else { 'Red' })
        Start-Sleep -Milliseconds 500
    }
    
    # Reset to 50%
    Set-AudioVolume -Volume 50 -Force
    Write-Host "Volume reset to 50%" -ForegroundColor Green
    Read-Host "Press Enter to continue"
}

function Set-VolumeWithConfirmation {
    param([int]$TargetVolume)
    
    Write-Host "`nSetting volume to $TargetVolume%..." -ForegroundColor Yellow
    Set-AudioVolume -Volume $TargetVolume -Force
    $newVolume = Get-AudioVolume
    Write-Host "Volume set to $newVolume%" -ForegroundColor $(
        if ([math]::Abs($newVolume - $TargetVolume) -le 2) { 'Green' } else { 'Yellow' }
    )
    Start-Sleep -Milliseconds 1000
}

# Main program loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    
    switch ($choice.ToUpper()) {
        "1" {
            try {
                $volume = Read-Host "Enter volume percentage (0-100)"
                $volumeNum = [int]$volume
                if ($volumeNum -ge 0 -and $volumeNum -le 100) {
                    Set-AudioVolume -Volume $volumeNum -Force
                    Write-Host "Volume set to $volumeNum%" -ForegroundColor Green
                } else {
                    Write-Host "Invalid volume. Please enter a number between 0 and 100." -ForegroundColor Red
                }
            } catch {
                Write-Host "Invalid input. Please enter a valid number." -ForegroundColor Red
            }
            Read-Host "Press Enter to continue"
        }
        
        "2" {
            Step-AudioVolumeUp -Force
            $newVolume = Get-AudioVolume
            Write-Host "Volume stepped up to $newVolume%" -ForegroundColor Green
            Read-Host "Press Enter to continue"
        }
        
        "3" {
            Step-AudioVolumeDown -Force
            $newVolume = Get-AudioVolume
            Write-Host "Volume stepped down to $newVolume%" -ForegroundColor Green
            Read-Host "Press Enter to continue"
        }
        
        "4" {
            Set-AudioMute -Mute $true -Force
            Write-Host "Audio muted" -ForegroundColor Green
            Read-Host "Press Enter to continue"
        }
        
        "5" {
            Set-AudioMute -Mute $false -Force
            Write-Host "Audio unmuted" -ForegroundColor Green
            Read-Host "Press Enter to continue"
        }
        
        "6" {
            Toggle-AudioMute -Force
            $muted = Get-AudioMute
            Write-Host "Audio muted: $muted" -ForegroundColor Green
            Read-Host "Press Enter to continue"
        }
        
        "7" {
            Show-AudioStatus
            Read-Host "Press Enter to continue"
        }
        
        "8" { Set-VolumeWithConfirmation -TargetVolume 50; Read-Host "Press Enter to continue" }
        "9" { Set-VolumeWithConfirmation -TargetVolume 25; Read-Host "Press Enter to continue" }
        "10" { Set-VolumeWithConfirmation -TargetVolume 75; Read-Host "Press Enter to continue" }
        "11" { Test-VolumeRange }
        
        "Q" {
            Write-Host "Goodbye!" -ForegroundColor Cyan
            break
        }
        
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($choice.ToUpper() -ne "Q")

# Cleanup
if ($script:AudioController) {
    Write-Verbose "Cleaning up audio controller..."
    # No explicit cleanup needed for PowerShell module
}