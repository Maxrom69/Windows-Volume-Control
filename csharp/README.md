# Windows Volume Control - Comprehensive Source Code Collection

A complete collection of source code for controlling Windows audio volume across multiple programming languages and approaches. This repository provides various methods to programmatically control system audio volume, mute state, and volume stepping functionality.

## 🎵 Features

- **Volume Control**: Set volume to any percentage (0-100%)
- **Mute/Unmute**: Control audio mute state with toggle functionality
- **Volume Stepping**: Step volume up/down using system increments
- **Cross-Platform**: Multiple language implementations (C++, C#, PowerShell, Python, Batch)
- **Modern APIs**: Uses Windows Core Audio API (WASAPI) for reliable control
- **Legacy Support**: Alternative SendKeys methods for older systems
- **Comprehensive**: Complete examples and documentation

## 📁 Directory Structure

```
WindowsVolumeControl/
├── cpp/                    # C++ implementation using Core Audio API
├── csharp/                 # C# .NET implementation
├── powershell/             # PowerShell module and scripts
├── python/                 # Python implementation with pywin32
├── batch/                  # Batch file and command-line solutions
├── docs/                   # Additional documentation
└── README.md              # This file
```

## 🚀 Quick Start

### Choose Your Language

Select the implementation that best fits your needs:

| Language | Best For | Dependencies | Difficulty |
|----------|----------|--------------|------------|
| **C++** | Native applications, maximum performance | Visual Studio, Windows SDK | Advanced |
| **C#** | .NET applications, enterprise solutions | .NET 6.0+, Windows | Intermediate |
| **PowerShell** | System administration, automation | Windows PowerShell | Beginner |
| **Python** | Scripting, automation, cross-platform | pywin32 | Intermediate |
| **Batch** | Simple scripts, legacy systems | Windows CMD | Beginner |

### Basic Usage Examples

#### C++
```bash
# Build with CMake
mkdir build && cd build
cmake ..
cmake --build .

# Run
VolumeController.exe set 75
VolumeController.exe get
VolumeController.exe mute
```

#### C#
```bash
# Build and run
dotnet run --project csharp
# Or build executable
dotnet publish -c Release -r win-x64

# Usage
AudioVolumeController.exe set 50
AudioVolumeController.exe toggle
```

#### PowerShell
```powershell
# Import and use
Import-Module .\AudioController.ps1
Set-AudioVolume 75
Set-AudioMute $true
Show-AudioStatus

# Or run demo
.\AudioControlDemo.ps1
```

#### Python
```bash
# Install dependencies
pip install -r requirements.txt

# Run CLI
python audio_controller.py set 75
python audio_controller.py get

# Run examples
python example.py
```

#### Batch
```batch
# Simple volume control
volume.bat set 50
volume.bat up
volume.bat mute

# Advanced control
volumecontrol.bat status
volumecontrol.bat set 75
```

## 🔧 Implementation Details

### Core Audio API (WASAPI)

Most implementations use the **Windows Core Audio API** (Windows Audio Session API), which provides:

- **Precision**: Exact volume control (0.0 to 1.0 scalar values)
- **Stability**: Direct interface to Windows audio subsystem
- **Features**: Volume range, step info, hardware support queries
- **Compatibility**: Windows Vista and later

### SendKeys Method (Legacy)

Alternative approach using Windows Script Host:

- **Compatibility**: Works on older Windows versions
- **Simplicity**: No complex API calls
- **Limitations**: Approximate volume control (2% increments)
- **Dependency**: Requires active desktop/session

## 📚 Detailed Implementation Guides

### C++ Implementation
- **File**: `cpp/VolumeController.cpp`
- **API**: Core Audio API COM interfaces
- **Build**: CMake configuration included
- **Features**: Complete API coverage including volume range info

### C# Implementation
- **Files**: `csharp/AudioVolumeController.cs`, `csharp/Program.cs`
- **API**: COM interop with Core Audio API
- **Build**: .NET 6.0 project file included
- **Features**: Exception handling, verbose output

### PowerShell Implementation
- **Files**: `powershell/AudioController.ps1`, `powershell/AudioControlDemo.ps1`
- **API**: COM interop with Core Audio API + SendKeys fallback
- **Features**: Module design, pipeline support, visual indicators

### Python Implementation
- **Files**: `python/audio_controller.py`, `python/example.py`
- **API**: pywin32 COM interface
- **Features**: Object-oriented design, comprehensive CLI, examples

### Batch Implementation
- **Files**: `batch/volumecontrol.bat`, `batch/setvolume.bat`, `batch/volume.bat`
- **API**: PowerShell + SendKeys hybrid
- **Features**: Simple syntax, legacy compatibility

## 🛠️ Installation & Setup

### Prerequisites

- **Windows OS**: Vista or later (Core Audio API requirement)
- **Administrator Rights**: May be required for some operations
- **Audio Drivers**: Properly installed and functional

### Language-Specific Setup

#### C++
```bash
# Required
- Visual Studio 2019+ or MinGW-w64
- Windows SDK
- CMake 3.10+

# Build
cd cpp
mkdir build && cd build
cmake ..
cmake --build .
```

#### C#
```bash
# Required
- .NET 6.0 SDK or later
- Windows OS

# Build and Run
dotnet run --project csharp
```

#### PowerShell
```bash
# Required (built-in)
- Windows PowerShell 5.1+ or PowerShell 7+

# No additional setup needed
Import-Module .\AudioController.ps1
```

#### Python
```bash
# Required
- Python 3.7+
- pywin32 package

# Install
pip install pywin32
# or
pip install -r requirements.txt
```

#### Batch
```bash
# Required (built-in)
- Windows Command Prompt
- Windows Script Host

# No additional setup needed
```

## 📖 API Reference

### Common Operations

| Operation | C++ | C# | PowerShell | Python | Batch |
|-----------|-----|----|------------|--------|-------|
| **Get Volume** | `GetMasterVolume()` | `Volume` property | `Get-AudioVolume` | `controller.volume` | `volumecontrol get` |
| **Set Volume** | `SetMasterVolume(v)` | `Volume = v` | `Set-AudioVolume v` | `controller.volume = v` | `volumecontrol set v` |
| **Get Mute** | `GetMute()` | `IsMuted` property | `Get-AudioMute` | `controller.is_muted` | (Visual feedback) |
| **Set Mute** | `SetMute(b)` | `IsMuted = b` | `Set-AudioMute b` | `controller.is_muted = b` | `volumecontrol mute` |
| **Volume Up** | `VolumeStepUp()` | `VolumeUp()` | `Step-AudioVolumeUp` | `controller.volume_up()` | `volumecontrol up` |
| **Volume Down** | `VolumeStepDown()` | `VolumeDown()` | `Step-AudioVolumeDown` | `controller.volume_down()` | `volumecontrol down` |
| **Toggle Mute** | (Custom logic) | `ToggleMute()` | `Toggle-AudioMute` | `controller.toggle_mute()` | `volumecontrol toggle` |

### Advanced Features

| Feature | C++ | C# | PowerShell | Python |
|---------|-----|----|------------|--------|
| **Volume Range Info** | `GetVolumeRange()` | `GetVolumeRange()` | (Custom) | `get_volume_range()` |
| **Volume Step Info** | `GetVolumeStepInfo()` | `GetVolumeStepInfo()` | (Custom) | `get_volume_step_info()` |
| **Hardware Support** | `QueryHardwareSupport()` | (Not implemented) | (Not implemented) | (Not implemented) |

## 🔍 Troubleshooting

### Common Issues

#### COM Initialization Errors
```
Error: Failed to initialize COM
```
**Solution**: Run as administrator or ensure proper Windows audio service status

#### Audio Device Not Found
```
Error: Failed to get default audio endpoint
```
**Solution**: Check audio device connections and Windows audio settings

#### Permission Denied
```
Access denied when setting volume
```
**Solution**: Run with administrator privileges

#### pywin32 Import Errors
```
ModuleNotFoundError: No module named 'win32com'
```
**Solution**: Install pywin32: `pip install pywin32`

#### SendKeys Not Working
```
Volume control appears to have no effect
```
**Solution**: Ensure desktop session is active and windows is not locked

### Debug Mode

Enable verbose output in most implementations:

- **PowerShell**: `-Verbose` parameter
- **C++**: Debug build with console output
- **C#`: Debug configuration
- **Python**: Exception stack traces enabled

## 🧪 Testing

### Automated Testing
```bash
# Python
python -m pytest python/tests/

# PowerShell
Invoke-Pester powershell/tests/

# C#
dotnet test csharp/
```

### Manual Testing Checklist
- [ ] Volume set to 0%, 25%, 50%, 75%, 100%
- [ ] Mute/unmute toggle
- [ ] Volume step up/down
- [ ] Error handling for invalid inputs
- [ ] Multiple rapid operations
- [ ] System audio service restart resilience

## 📄 License

This project is provided as educational and example code. Feel free to use, modify, and distribute according to your needs.

## 🤝 Contributing

Contributions welcome! Please ensure:
- Code follows language-specific conventions
- Include error handling
- Add documentation for new features
- Test across Windows versions

## 📞 Support

For issues and questions:
1. Check the troubleshooting section
2. Verify system requirements
3. Test with minimal examples
4. Review implementation-specific documentation

---

**Note**: Some advanced features may require specific Windows versions or audio hardware support. Test thoroughly in your target environment.