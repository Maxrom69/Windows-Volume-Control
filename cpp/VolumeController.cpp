/*
 * Windows Volume Controller using Core Audio API
 * 
 * This C++ application demonstrates how to control Windows audio volume
 * using the Windows Core Audio API (WASAPI).
 * 
 * Features:
 * - Get/Set master volume level (0.0 to 1.0)
 * - Mute/Unmute audio
 * - Get volume range information
 * - Volume step up/down
 * 
 * Compile with:
 * cl /EHsc VolumeController.cpp ole32.lib 
 */

#include <windows.h>
#include <iostream>
#include <iomanip>
#include <mmdeviceapi.h>
#include <endpointvolume.h>
#include <audioclient.h>

class AudioVolumeController {
private:
    IMMDeviceEnumerator* pEnumerator = nullptr;
    IMMDevice* pDevice = nullptr;
    IAudioEndpointVolume* pEndpointVolume = nullptr;

    HRESULT InitializeAudioEndpoints() {
        HRESULT hr;

        // Initialize COM
        hr = CoInitialize(nullptr);
        if (FAILED(hr)) {
            std::cerr << "Failed to initialize COM. Error: 0x" << std::hex << hr << std::endl;
            return hr;
        }

        // Create device enumerator
        hr = CoCreateInstance(
            __uuidof(MMDeviceEnumerator), nullptr,
            CLSCTX_ALL, __uuidof(IMMDeviceEnumerator),
            (void**)&pEnumerator
        );

        if (FAILED(hr)) {
            std::cerr << "Failed to create device enumerator. Error: 0x" << std::hex << hr << std::endl;
            Cleanup();
            return hr;
        }

        // Get default audio endpoint
        hr = pEnumerator->GetDefaultAudioEndpoint(
            eRender, eConsole, &pDevice
        );

        if (FAILED(hr)) {
            std::cerr << "Failed to get default audio endpoint. Error: 0x" << std::hex << hr << std::endl;
            Cleanup();
            return hr;
        }

        // Get endpoint volume interface
        hr = pDevice->Activate(
            __uuidof(IAudioEndpointVolume),
            CLSCTX_ALL, nullptr,
            (void**)&pEndpointVolume
        );

        if (FAILED(hr)) {
            std::cerr << "Failed to get endpoint volume interface. Error: 0x" << std::hex << hr << std::endl;
            Cleanup();
            return hr;
        }

        return S_OK;
    }

    void Cleanup() {
        if (pEndpointVolume) {
            pEndpointVolume->Release();
            pEndpointVolume = nullptr;
        }
        if (pDevice) {
            pDevice->Release();
            pDevice = nullptr;
        }
        if (pEnumerator) {
            pEnumerator->Release();
            pEnumerator = nullptr;
        }
        CoUninitialize();
    }

public:
    AudioVolumeController() {
        if (FAILED(InitializeAudioEndpoints())) {
            throw std::runtime_error("Failed to initialize audio controller");
        }
    }

    ~AudioVolumeController() {
        Cleanup();
    }

    // Get current master volume level (0.0 to 1.0)
    float GetMasterVolume() {
        if (!pEndpointVolume) return -1.0f;

        float currentVolume = 0.0f;
        HRESULT hr = pEndpointVolume->GetMasterVolumeLevelScalar(&currentVolume);
        
        if (FAILED(hr)) {
            std::cerr << "Failed to get master volume. Error: 0x" << std::hex << hr << std::endl;
            return -1.0f;
        }

        return currentVolume;
    }

    // Set master volume level (0.0 to 1.0)
    bool SetMasterVolume(float volume) {
        if (!pEndpointVolume) return false;

        // Clamp volume to valid range
        if (volume < 0.0f) volume = 0.0f;
        if (volume > 1.0f) volume = 1.0f;

        HRESULT hr = pEndpointVolume->SetMasterVolumeLevelScalar(volume, nullptr);
        
        if (FAILED(hr)) {
            std::cerr << "Failed to set master volume. Error: 0x" << std::hex << hr << std::endl;
            return false;
        }

        return true;
    }

    // Get mute state
    bool GetMute() {
        if (!pEndpointVolume) return false;

        BOOL isMuted = FALSE;
        HRESULT hr = pEndpointVolume->GetMute(&isMuted);
        
        if (FAILED(hr)) {
            std::cerr << "Failed to get mute state. Error: 0x" << std::hex << hr << std::endl;
            return false;
        }

        return isMuted == TRUE;
    }

    // Set mute state
    bool SetMute(bool mute) {
        if (!pEndpointVolume) return false;

        HRESULT hr = pEndpointVolume->SetMute(mute, nullptr);
        
        if (FAILED(hr)) {
            std::cerr << "Failed to set mute state. Error: 0x" << std::hex << hr << std::endl;
            return false;
        }

        return true;
    }

    // Step volume up
    bool StepUp() {
        if (!pEndpointVolume) return false;

        HRESULT hr = pEndpointVolume->VolumeStepUp(nullptr);
        
        if (FAILED(hr)) {
            std::cerr << "Failed to step volume up. Error: 0x" << std::hex << hr << std::endl;
            return false;
        }

        return true;
    }

    // Step volume down
    bool StepDown() {
        if (!pEndpointVolume) return false;

        HRESULT hr = pEndpointVolume->VolumeStepDown(nullptr);
        
        if (FAILED(hr)) {
            std::cerr << "Failed to step volume down. Error: 0x" << std::hex << hr << std::endl;
            return false;
        }

        return true;
    }

    // Get volume range information
    void GetVolumeRange(float* minLevel, float* maxLevel, float* step) {
        if (!pEndpointVolume) return;

        HRESULT hr = pEndpointVolume->GetVolumeRange(minLevel, maxLevel, step);
        
        if (FAILED(hr)) {
            std::cerr << "Failed to get volume range. Error: 0x" << std::hex << hr << std::endl;
        }
    }

    // Display current volume information
    void DisplayVolumeInfo() {
        std::cout << "\n=== Audio Volume Information ===" << std::endl;
        
        float currentVolume = GetMasterVolume();
        if (currentVolume >= 0) {
            std::cout << "Current Volume: " << std::fixed << std::setprecision(0) 
                      << (currentVolume * 100) << "%" << std::endl;
        }

        bool isMuted = GetMute();
        std::cout << "Mute Status: " << (isMuted ? "Muted" : "Unmuted") << std::endl;

        float minLevel, maxLevel, step;
        GetVolumeRange(&minLevel, &maxLevel, &step);
        std::cout << "Volume Range: " << std::fixed << std::setprecision(2)
                  << minLevel << " dB to " << maxLevel << " dB" << std::endl;
        std::cout << "Step Size: " << step << " dB" << std::endl;
        std::cout << "===============================\n" << std::endl;
    }
};

void ShowUsage() {
    std::cout << "\nWindows Volume Controller" << std::endl;
    std::cout << "Usage:" << std::endl;
    std::cout << "  VolumeController.exe                    - Show current volume info" << std::endl;
    std::cout << "  VolumeController.exe get                 - Get current volume" << std::endl;
    std::cout << "  VolumeController.exe set <0-100>         - Set volume to percentage" << std::endl;
    std::cout << "  VolumeController.exe mute               - Mute audio" << std::endl;
    std::cout << "  VolumeController.exe unmute             - Unmute audio" << std::endl;
    std::cout << "  VolumeController.exe up                 - Volume step up" << std::endl;
    std::cout << "  VolumeController.exe down               - Volume step down" << std::endl;
    std::cout << "  VolumeController.exe toggle             - Toggle mute state" << std::endl;
}

int main(int argc, char* argv[]) {
    try {
        AudioVolumeController controller;

        if (argc == 1) {
            // No arguments - show current volume info
            controller.DisplayVolumeInfo();
            return 0;
        }

        std::string command = argv[1];

        if (command == "get") {
            float volume = controller.GetMasterVolume();
            if (volume >= 0) {
                std::cout << "Current Volume: " << std::fixed << std::setprecision(0) 
                          << (volume * 100) << "%" << std::endl;
            }
        }
        else if (command == "set" && argc >= 3) {
            try {
                int percentage = std::stoi(argv[2]);
                if (percentage < 0 || percentage > 100) {
                    std::cerr << "Error: Volume must be between 0 and 100" << std::endl;
                    return 1;
                }
                
                float volume = static_cast<float>(percentage) / 100.0f;
                if (controller.SetMasterVolume(volume)) {
                    std::cout << "Volume set to " << percentage << "%" << std::endl;
                } else {
                    std::cerr << "Failed to set volume" << std::endl;
                    return 1;
                }
            }
            catch (const std::exception& e) {
                std::cerr << "Error: Invalid volume value" << std::endl;
                return 1;
            }
        }
        else if (command == "mute") {
            if (controller.SetMute(true)) {
                std::cout << "Audio muted" << std::endl;
            } else {
                std::cerr << "Failed to mute audio" << std::endl;
                return 1;
            }
        }
        else if (command == "unmute") {
            if (controller.SetMute(false)) {
                std::cout << "Audio unmuted" << std::endl;
            } else {
                std::cerr << "Failed to unmute audio" << std::endl;
                return 1;
            }
        }
        else if (command == "toggle") {
            bool currentlyMuted = controller.GetMute();
            if (controller.SetMute(!currentlyMuted)) {
                std::cout << "Audio " << (currentlyMuted ? "unmuted" : "muted") << std::endl;
            } else {
                std::cerr << "Failed to toggle mute state" << std::endl;
                return 1;
            }
        }
        else if (command == "up") {
            if (controller.StepUp()) {
                std::cout << "Volume stepped up" << std::endl;
            } else {
                std::cerr << "Failed to step volume up" << std::endl;
                return 1;
            }
        }
        else if (command == "down") {
            if (controller.StepDown()) {
                std::cout << "Volume stepped down" << std::endl;
            } else {
                std::cerr << "Failed to step volume down" << std::endl;
                return 1;
            }
        }
        else {
            ShowUsage();
            return 1;
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}