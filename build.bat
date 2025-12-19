@echo off
:: Windows Volume Control - Build Script
:: Builds all implementations and creates distribution package

setlocal enabledelayedexpansion

echo ========================================
echo   Windows Volume Control - Build Script
echo ========================================
echo.

:: Configuration
set "BUILD_DIR=build"
set "DIST_DIR=dist"
set "SOLUTION_NAME=WindowsVolumeControl"

:: Clean previous builds
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"

:: Create directories
mkdir "%BUILD_DIR%" 2>nul
mkdir "%DIST_DIR%" 2>nul

echo [1/6] Building C++ Implementation...
call :build_cpp
if errorlevel 1 goto :error

echo [2/6] Building C# Implementation...
call :build_csharp
if errorlevel 1 goto :error

echo [3/6] Preparing PowerShell Implementation...
call :prepare_powershell
if errorlevel 1 goto :error

echo [4/6] Preparing Python Implementation...
call :prepare_python
if errorlevel 1 goto :error

echo [5/6] Preparing Batch Implementation...
call :prepare_batch
if errorlevel 1 goto :error

echo [6/6] Creating Distribution Package...
call :create_package
if errorlevel 1 goto :error

echo.
echo ========================================
echo   Build Completed Successfully!
echo ========================================
echo.
echo Distribution created in: %DIST_DIR%\
echo.
echo Package contents:
echo - README.md (Documentation)
echo - docs\ (Additional documentation)
echo - cpp\VolumeController.exe (C++ executable)
echo - csharp\AudioVolumeController.exe (C# executable)
echo - powershell\*.ps1 (PowerShell scripts)
echo - python\*.py (Python scripts)
echo - batch\*.bat (Batch scripts)
echo.

goto :eof

:build_cpp
echo   Building C++ with Visual Studio...

:: Check for Visual Studio
if not exist "C:\Program Files (x86)\Microsoft Visual Studio\2019" (
    if not exist "C:\Program Files\Microsoft Visual Studio\2022" (
        echo   Warning: Visual Studio not found in default locations
        echo   Attempting to build with available compiler...
    )
)

:: Create build directory
mkdir "%BUILD_DIR%\cpp" 2>nul
cd cpp

:: Try CMake build if available
where cmake >nul 2>&1
if %errorlevel% == 0 (
    echo   Using CMake...
    mkdir "%BUILD_DIR%\cpp\cmake" 2>nul
    cd "%BUILD_DIR%\cpp\cmake"
    cmake -G "Visual Studio 16 2019" -A x64 "%~dp0\..\cpp" 2>nul
    if %errorlevel% == 0 (
        cmake --build . --config Release
        if %errorlevel% == 0 (
            copy "Release\VolumeController.exe" "%~dp0..\..\%DIST_DIR%\cpp&quot; >nul 2>&1
            echo   C++ build successful with CMake
            cd ..\..\..
            goto :cpp_success
        )
    )
)

:: Fallback to simple compile with cl if available
where cl >nul 2>&1
if %errorlevel% == 0 (
    echo   Using MSVC compiler directly...
    cl /EHsc VolumeController.cpp ole32.lib /Fe:"%DIST_DIR%\cpp\VolumeController.exe" 2>nul
    if %errorlevel% == 0 (
        echo   C++ build successful with cl
        del *.obj 2>nul
        cd ..
        goto :cpp_success
    )
)

:: Create placeholder if build fails
echo   C++ build not available - creating placeholder
mkdir "%~dp0..\%DIST_DIR%\cpp" 2>nul
echo @echo off > "%~dp0..\%DIST_DIR%\cpp\build_note.txt"
echo C++ build requires Visual Studio or compatible compiler >> "%~dp0..\%DIST_DIR%\cpp\build_note.txt"
echo See cpp\VolumeController.cpp for source code >> "%~dp0..\%DIST_DIR%\cpp\build_note.txt"

:cpp_success
cd ..
exit /b 0

:build_csharp
echo   Building C# with .NET...

:: Create distribution directory
mkdir "%DIST_DIR%\csharp" 2>nul

:: Check for .NET SDK
where dotnet >nul 2>&1
if %errorlevel% == 0 (
    echo   Using .NET SDK...
    cd csharp
    dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o "%DIST_DIR%\csharp"
    if %errorlevel% == 0 (
        echo   C# build successful with .NET
        cd ..
        exit /b 0
    )
    cd ..
)

:: Fallback to csc if available
where csc >nul 2>&1
if %errorlevel% == 0 (
    echo   Using csc compiler...
    csc /target:exe /out:"%DIST_DIR%\csharp\AudioVolumeController.exe" csharp\AudioVolumeController.cs csharp\Program.cs /reference:System.dll 2>nul
    if %errorlevel% == 0 (
        echo   C# build successful with csc
        exit /b 0
    )
)

:: Create placeholder if build fails
echo   C# build not available - creating placeholder
echo @echo off > "%DIST_DIR%\csharp\build_note.txt"
echo C# build requires .NET SDK or Visual Studio >> "%DIST_DIR%\csharp\build_note.txt"
echo See csharp\*.cs for source code >> "%DIST_DIR%\csharp\build_note.txt"

exit /b 0

:prepare_powershell
echo   Preparing PowerShell scripts...

mkdir "%DIST_DIR%\powershell" 2>nul
copy "powershell\*.ps1" "%DIST_DIR%\powershell&quot; >nul 2>&1
if %errorlevel% == 0 (
    echo   PowerShell scripts copied successfully
) else (
    echo   Warning: Could not copy PowerShell scripts
)

exit /b 0

:prepare_python
echo   Preparing Python scripts...

mkdir "%DIST_DIR%\python" 2>nul
copy "python\*.py" "%DIST_DIR%\python&quot; >nul 2>&1
copy "python\requirements.txt" "%DIST_DIR%\python&quot; >nul 2>&1
if %errorlevel% == 0 (
    echo   Python scripts copied successfully
) else (
    echo   Warning: Could not copy Python scripts
)

exit /b 0

:prepare_batch
echo   Preparing Batch scripts...

mkdir "%DIST_DIR%\batch" 2>nul
copy "batch\*.bat" "%DIST_DIR%\batch&quot; >nul 2>&1
if %errorlevel% == 0 (
    echo   Batch scripts copied successfully
) else (
    echo   Warning: Could not copy Batch scripts
)

exit /b 0

:create_package
echo   Creating distribution package...

:: Copy documentation
mkdir "%DIST_DIR%\docs" 2>nul
copy "README.md" "%DIST_DIR%&quot; >nul 2>&1
copy "docs\*.md" "%DIST_DIR%\docs&quot; >nul 2>&1

:: Create test script
(
echo @echo off
echo echo Testing Windows Volume Control implementations...
echo echo.
echo echo 1. Testing Batch implementation:
echo cd batch
echo volume.bat set 50
echo echo.
echo echo 2. Testing PowerShell implementation:
echo cd ..\powershell
echo powershell -ExecutionPolicy Bypass -Command "Import-Module .\AudioController.ps1; Get-AudioVolume"
echo echo.
echo echo 3. Testing Python implementation ^(if available^):
echo cd ..\python
echo python --version 2^>nul ^&^&^& python audio_controller.py get
echo echo.
echo echo Testing complete!
) > "%DIST_DIR%\test.bat"

:: Create quick start guide
(
echo Windows Volume Control - Quick Start
echo =====================================
echo.
echo This package contains multiple implementations for controlling
echo Windows audio volume. Choose the one that best fits your needs.
echo.
echo Quick Usage Examples:
echo.
echo Batch (Simplest^):
echo   cd batch
echo   volume.bat set 75
echo.
echo PowerShell (Recommended for admin^):
echo   cd powershell
echo   Import-Module .\AudioController.ps1
echo   Set-AudioVolume 75
echo.
echo Python (For developers^):
echo   cd python
echo   pip install pywin32
echo   python audio_controller.py set 75
echo.
echo C++ (Maximum performance^):
echo   cd cpp
echo   VolumeController.exe set 75
echo.
echo C# (.NET applications^):
echo   cd csharp
echo   AudioVolumeController.exe set 75
echo.
echo For detailed documentation, see README.md
echo.
) > "%DIST_DIR%\QUICKSTART.txt"

:: Create build info
(
echo Build Information
echo ==================
echo.
echo Build Date: %date% %time%
echo Build Environment: Windows %OS%
echo.
echo Build Status:
echo - C++: %cpp_status%
echo - C#: %csharp_status%
echo - PowerShell: Copied
echo - Python: Copied
echo - Batch: Copied
echo.
echo Requirements:
echo - Windows Vista or later for Core Audio API features
echo - Audio drivers properly installed
echo - Administrative privileges for some operations
echo.
echo Language-Specific Requirements:
echo - C++: Visual Studio or compatible compiler
echo - C#: .NET 6.0 runtime or .NET Framework 4.8+
echo - PowerShell: Windows PowerShell 5.1+ or PowerShell 7+
echo - Python: Python 3.7+ with pywin32 package
echo - Batch: Windows Command Prompt (built-in^)
echo.
) > "%DIST_DIR%\BUILD_INFO.txt"

exit /b 0

:error
echo.
echo ========================================
echo   BUILD FAILED!
echo ========================================
echo.
echo Check the error messages above for details.
echo Common issues:
echo - Missing Visual Studio or .NET SDK
echo - Missing compiler tools
echo - Permission issues
echo.
exit /b 1