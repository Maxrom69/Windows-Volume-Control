<#
.SYNOPSIS
    Windows Audio Volume Controller PowerShell Module

.DESCRIPTION
    Provides comprehensive control over Windows audio volume using Core Audio API.
    Supports volume control, mute/unmute, and volume stepping functionality.

.NOTES
    Author: Windows Volume Controller
    Version: 1.0.0
    Requires: Windows Vista or later (Core Audio API)

.EXAMPLE
    Import-Module .\AudioController.ps1
    Set-AudioVolume 50
    Get-AudioVolume
    Set-AudioMute $true
#>

# Audio Controller Module Definition
$script:AudioController = $null

function Initialize-AudioController {
    <#
    .SYNOPSIS
        Initializes the audio controller using Core Audio API COM interfaces
    
    .DESCRIPTION
        Creates COM objects and interfaces required for audio volume control.
        This function must be called before using other audio controller functions.
    
    .EXAMPLE
        Initialize-AudioController
    #>
    
    try {
        # Add the COM interface definitions
        $comCode = @"
using System.Runtime.InteropServices;

[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume
{
    int f(); int g(); int h(); int i();
    int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
    int j();
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int k(); int l(); int m(); int n();
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
    int GetMute(out bool pbMute);
    int VolumeStepUp(System.Guid pguidEventContext);
    int VolumeStepDown(System.Guid pguidEventContext);
}

[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice
{
    int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}

[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator
{
    int f();
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}

[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject {}

public class Audio
{
    static IAudioEndpointVolume Vol()
    {
        var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
        IMMDevice dev = null;
        Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
        IAudioEndpointVolume epv = null;
        var epvid = typeof(IAudioEndpointVolume).GUID;
        Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
        return epv;
    }
    
    public static float Volume
    {
        get { float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty)); }
    }
    
    public static bool Mute
    {
        get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
    }
    
    public static void VolumeUp() { Marshal.ThrowExceptionForHR(Vol().VolumeStepUp(System.Guid.Empty)); }
    public static void VolumeDown() { Marshal.ThrowExceptionForHR(Vol().VolumeStepDown(System.Guid.Empty)); }
}
"@
        
        Add-Type -TypeDefinition $comCode -ReferencedAssemblies System.Runtime.InteropServices
        $script:AudioController = [Audio]
        Write-Verbose "Audio controller initialized successfully"
        
    } catch {
        Write-Error "Failed to initialize audio controller: $($_.Exception.Message)"
        throw
    }
}

function Get-AudioVolume {
    <#
    .SYNOPSIS
        Gets the current master audio volume level
    
    .DESCRIPTION
        Returns the current volume level as a percentage (0-100)
    
    .EXAMPLE
        Get-AudioVolume
        # Returns current volume as percentage
    
    .OUTPUTS
        System.Int32 - Current volume percentage
    #>
    
    if (-not $script:AudioController) {
        Initialize-AudioController
    }
    
    try {
        $volume = $script:AudioController::Volume
        return [int]($volume * 100)
    } catch {
        Write-Error "Failed to get audio volume: $($_.Exception.Message)"
        throw
    }
}

function Set-AudioVolume {
    <#
    .SYNOPSIS
        Sets the master audio volume level
    
    .DESCRIPTION
        Sets the volume to the specified percentage (0-100)
    
    .PARAMETER Volume
        Volume percentage to set (0-100)
    
    .PARAMETER Force
        Suppress confirmation prompts
    
    .EXAMPLE
        Set-AudioVolume 50
        # Sets volume to 50%
    
    .EXAMPLE
        Set-AudioVolume -Volume 75 -Force
        # Sets volume to 75% without confirmation
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateRange(0,100)]
        [int]$Volume,
        
        [switch]$Force
    )
    
    if (-not $script:AudioController) {
        Initialize-AudioController
    }
    
    $currentVolume = Get-AudioVolume
    
    if ($Force -or $PSCmdlet.ShouldProcess("Audio volume", "change from $currentVolume% to $Volume%")) {
        try {
            $volumeScalar = $Volume / 100.0
            $script:AudioController::Volume = $volumeScalar
            Write-Verbose "Volume set to $Volume%"
            return $true
        } catch {
            Write-Error "Failed to set audio volume: $($_.Exception.Message)"
            throw
        }
    }
}

function Get-AudioMute {
    <#
    .SYNOPSIS
        Gets the current audio mute state
    
    .DESCRIPTION
        Returns whether the audio is currently muted
    
    .EXAMPLE
        Get-AudioMute
        # Returns $true if muted, $false if not muted
    
    .OUTPUTS
        System.Boolean - Current mute state
    #>
    
    if (-not $script:AudioController) {
        Initialize-AudioController
    }
    
    try {
        return $script:AudioController::Mute
    } catch {
        Write-Error "Failed to get audio mute state: $($_.Exception.Message)"
        throw
    }
}

function Set-AudioMute {
    <#
    .SYNOPSIS
        Sets the audio mute state
    
    .DESCRIPTION
        Mutes or unmutes the audio output
    
    .PARAMETER Mute
        $true to mute, $false to unmute
    
    .PARAMETER Force
        Suppress confirmation prompts
    
    .EXAMPLE
        Set-AudioMute $true
        # Mutes audio
    
    .EXAMPLE
        Set-AudioMute -Mute $false -Force
        # Unmutes audio without confirmation
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [bool]$Mute,
        
        [switch]$Force
    )
    
    if (-not $script:AudioController) {
        Initialize-AudioController
    }
    
    $currentMute = Get-AudioMute
    $action = if ($Mute) { "mute" } else { "unmute" }
    
    if ($Force -or $PSCmdlet.ShouldProcess("Audio", "$action ($($currentMute.ToString() -> $($Mute.ToString())))")) {
        try {
            $script:AudioController::Mute = $Mute
            Write-Verbose "Audio muted: $Mute"
            return $true
        } catch {
            Write-Error "Failed to set audio mute state: $($_.Exception.Message)"
            throw
        }
    }
}

function Toggle-AudioMute {
    <#
    .SYNOPSIS
        Toggles the audio mute state
    
    .DESCRIPTION
        Switches between muted and unmuted states
    
    .EXAMPLE
        Toggle-AudioMute
        # Toggles mute state
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if (-not $script:AudioController) {
        Initialize-AudioController
    }
    
    $currentMute = Get-AudioMute
    $newState = -not $currentMute
    
    if ($PSCmdlet.ShouldProcess("Audio", "toggle mute ($($currentMute.ToString() -> $($newState.ToString())))")) {
        try {
            $script:AudioController::Mute = $newState
            Write-Verbose "Audio mute toggled to: $newState"
            return $newState
        } catch {
            Write-Error "Failed to toggle audio mute state: $($_.Exception.Message)"
            throw
        }
    }
}

function Step-AudioVolumeUp {
    <#
    .SYNOPSIS
        Increases the volume by one step
    
    .DESCRIPTION
        Steps the volume up using the system volume increment
    
    .EXAMPLE
        Step-AudioVolumeUp
        # Increases volume by one step
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if (-not $script:AudioController) {
        Initialize-AudioController
    }
    
    if ($PSCmdlet.ShouldProcess("Audio volume", "step up")) {
        try {
            $script:AudioController::VolumeUp()
            $newVolume = Get-AudioVolume
            Write-Verbose "Volume stepped up to $newVolume%"
            return $newVolume
        } catch {
            Write-Error "Failed to step volume up: $($_.Exception.Message)"
            throw
        }
    }
}

function Step-AudioVolumeDown {
    <#
    .SYNOPSIS
        Decreases the volume by one step
    
    .DESCRIPTION
        Steps the volume down using the system volume increment
    
    .EXAMPLE
        Step-AudioVolumeDown
        # Decreases volume by one step
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    if (-not $script:AudioController) {
        Initialize-AudioController
    }
    
    if ($PSCmdlet.ShouldProcess("Audio volume", "step down")) {
        try {
            $script:AudioController::VolumeDown()
            $newVolume = Get-AudioVolume
            Write-Verbose "Volume stepped down to $newVolume%"
            return $newVolume
        } catch {
            Write-Error "Failed to step volume down: $($_.Exception.Message)"
            throw
        }
    }
}

function Show-AudioStatus {
    <#
    .SYNOPSIS
        Displays current audio status information
    
    .DESCRIPTION
        Shows current volume level, mute state, and other audio information
    
    .EXAMPLE
        Show-AudioStatus
        # Displays current audio status
    #>
    
    [CmdletBinding()]
    param()
    
    if (-not $script:AudioController) {
        Initialize-AudioController
    }
    
    try {
        $volume = Get-AudioVolume
        $muted = Get-AudioMute
        
        Write-Host "`n=== Audio Status ===" -ForegroundColor Cyan
        Write-Host "Volume: $volume%" -ForegroundColor Green
        Write-Host "Muted: $(if ($muted) { 'Yes' } else { 'No' })" -ForegroundColor $(if ($muted) { 'Red' } else { 'Green' })
        
        # Visual volume bar
        $barLength = 20
        $filledLength = [int]($volume / 100.0 * $barLength)
        $emptyLength = $barLength - $filledLength
        $bar = "[" + ("█" * $filledLength) + ("░" * $emptyLength) + "]"
        Write-Host "Volume Bar: $bar" -ForegroundColor Yellow
        
        Write-Host "==================" -ForegroundColor Cyan
    } catch {
        Write-Error "Failed to get audio status: $($_.Exception.Message)"
        throw
    }
}

# Alternative SendKeys-based approach for older systems or when COM fails
function Set-AudioVolumeSendKeys {
    <#
    .SYNOPSIS
        Sets audio volume using SendKeys method (alternative approach)
    
    .DESCRIPTION
        Uses Windows Script Host SendKeys method to simulate volume key presses.
        Useful as a fallback when COM interfaces are not available.
    
    .PARAMETER Volume
        Target volume percentage (0-100)
    
    .EXAMPLE
        Set-AudioVolumeSendKeys 75
        # Sets volume to approximately 75% using SendKeys
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateRange(0,100)]
        [int]$Volume
    )
    
    try {
        $wshShell = New-Object -ComObject WScript.Shell
        
        # First, mute all the way down
        1..50 | ForEach-Object { $wshShell.SendKeys([char]174) }
        
        # Then step up to desired volume (each step is approximately 2%)
        $steps = [math]::Round($Volume / 2.0)
        1..$steps | ForEach-Object { $wshShell.SendKeys([char]175) }
        
        Write-Verbose "Volume set to approximately $Volume% using SendKeys"
        
    } catch {
        Write-Error "Failed to set volume using SendKeys: $($_.Exception.Message)"
        throw
    }
}

function Set-AudioMuteSendKeys {
    <#
    .SYNOPSIS
        Toggles mute using SendKeys method
    
    .DESCRIPTION
        Uses Windows Script Host SendKeys to simulate mute key press
    
    .EXAMPLE
        Set-AudioMuteSendKeys
        # Toggles mute state
    #>
    
    [CmdletBinding()]
    param()
    
    try {
        $wshShell = New-Object -ComObject WScript.Shell
        $wshShell.SendKeys([char]173)
        Write-Verbose "Mute toggled using SendKeys"
        
    } catch {
        Write-Error "Failed to toggle mute using SendKeys: $($_.Exception.Message)"
        throw
    }
}

# Export module functions
Export-ModuleMember -Function @(
    'Initialize-AudioController',
    'Get-AudioVolume',
    'Set-AudioVolume',
    'Get-AudioMute',
    'Set-AudioMute',
    'Toggle-AudioMute',
    'Step-AudioVolumeUp',
    'Step-AudioVolumeDown',
    'Show-AudioStatus',
    'Set-AudioVolumeSendKeys',
    'Set-AudioMuteSendKeys'
)