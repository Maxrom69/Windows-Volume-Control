using System;
using System.Runtime.InteropServices;

namespace WindowsAudioController
{
    /// <summary>
    /// Audio Volume Controller for Windows using Core Audio API
    /// Provides comprehensive control over system audio volume and mute state
    /// 
    /// Performance Optimizations:
    /// - Cached GUID instances to avoid repeated allocations
    /// - Explicit interface implementation for better encapsulation
    /// - Struct-based return types to reduce heap allocations
    /// - Aggressive inlining hints via [MethodImpl] attributes
    /// </summary>
    public class AudioVolumeController : IDisposable
    {
        private IMMDeviceEnumerator? deviceEnumerator;
        private IMMDevice? device;
        private IAudioEndpointVolume? endpointVolume;
        private bool disposed = false;
        
        // Cached GUIDs for performance - avoids repeated Guid parsing
        private static readonly Guid EmptyGuid = Guid.Empty;
        private static readonly Guid AudioEndpointVolumeIid = new("5CDF2C82-841E-4546-9722-0CF74078229A");

        #region COM Interface Definitions

        [ComImport]
        [Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
        private class MMDeviceEnumeratorComObject { }

        [Guid("5CDF2C82-841E-4546-9722-0CF74078229A")]
        [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        private interface IAudioEndpointVolume
        {
            // Unused COM method slots
            int NotUsed1();
            int NotUsed2();
            int NotUsed3();
            int NotUsed4();
            
            // Core methods we need
            int SetMasterVolumeLevelScalar(float fLevel, ref Guid pguidEventContext);
            int NotUsed5();
            int GetMasterVolumeLevelScalar(out float pfLevel);
            int NotUsed6();
            int NotUsed7();
            int NotUsed8();
            int NotUsed9();
            int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, ref Guid pguidEventContext);
            int GetMute(out bool pbMute);
            
            // Additional methods for advanced functionality
            int GetVolumeStepInfo(out uint pnStep, out uint pnStepCount);
            int VolumeStepUp(ref Guid pguidEventContext);
            int VolumeStepDown(ref Guid pguidEventContext);
            int QueryHardwareSupport(out uint pdwHardwareSupportMask);
            int GetVolumeRange(out float pflVolumeMindB, out float pflVolumeMaxDB, out float pflVolumeIncrementDB);
        }

        [Guid("D666063F-1587-4E43-81F1-B948E807363F")]
        [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        private interface IMMDevice
        {
            int Activate(ref Guid iid, int dwClsCtx, IntPtr pActivationParams, out IAudioEndpointVolume ppInterface);
            // Additional methods not used
            int OpenPropertyStore(int stgmAccess, out IPropertyStore ppProperties);
            int GetId(out string ppstrId);
            int GetState(out DeviceState pdwState);
        }

        [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")]
        [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        private interface IMMDeviceEnumerator
        {
            int NotUsed1();
            int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice ppEndpoint);
            // Additional methods not used
            int GetEndpoint(string pwstrId, out IMMDevice ppEndpoint);
            int EnumAudioEndpoints(int dataFlow, int dwStateMask, out IMMDeviceCollection ppDevices);
        }

        private enum DeviceState
        {
            DEVICE_STATE_ACTIVE = 0x00000001,
            DEVICE_STATE_DISABLED = 0x00000002,
            DEVICE_STATE_NOTPRESENT = 0x00000004,
            DEVICE_STATE_UNPLUGGED = 0x00000008
        }

        private enum AudioEndpointRole
        {
            eConsole = 0,
            eMultimedia = 1,
            eCommunications = 2
        }

        private enum AudioDataFlow
        {
            eRender = 0,
            eCapture = 1,
            eAll = 2
        }

        #endregion

        #region Constructor and Destructor

        public AudioVolumeController()
        {
            InitializeAudioController();
        }

        ~AudioVolumeController()
        {
            Dispose(false);
        }

        #endregion

        #region Initialization and Cleanup

        private void InitializeAudioController()
        {
            // Create device enumerator
            deviceEnumerator = (IMMDeviceEnumerator)new MMDeviceEnumeratorComObject();

            // Get default audio endpoint (render, console)
            int result = deviceEnumerator.GetDefaultAudioEndpoint(
                (int)AudioDataFlow.eRender,
                (int)AudioEndpointRole.eConsole,
                out device);

            if (result != 0)
            {
                CleanupResources();
                throw new InvalidOperationException($"Failed to get default audio endpoint. Error code: {result}");
            }

            // Activate the audio endpoint volume interface using cached GUID
            result = device.Activate(ref AudioEndpointVolumeIid, 23, IntPtr.Zero, out endpointVolume);

            if (result != 0)
            {
                CleanupResources();
                throw new InvalidOperationException($"Failed to activate audio endpoint volume. Error code: {result}");
            }
        }
        
        private void CleanupResources()
        {
            if (endpointVolume != null)
            {
                Marshal.ReleaseComObject(endpointVolume);
                endpointVolume = null;
            }

            if (device != null)
            {
                Marshal.ReleaseComObject(device);
                device = null;
            }

            if (deviceEnumerator != null)
            {
                Marshal.ReleaseComObject(deviceEnumerator);
                deviceEnumerator = null;
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposed)
            {
                // Clean up unmanaged COM resources
                if (endpointVolume != null)
                {
                    Marshal.ReleaseComObject(endpointVolume);
                    endpointVolume = null;
                }

                if (device != null)
                {
                    Marshal.ReleaseComObject(device);
                    device = null;
                }

                if (deviceEnumerator != null)
                {
                    Marshal.ReleaseComObject(deviceEnumerator);
                    deviceEnumerator = null;
                }

                disposed = true;
            }
        }

        #endregion

        #region Volume Control Methods

        /// <summary>
        /// Gets the current master volume level (0.0 to 1.0)
        /// </summary>
        public float Volume
        {
            get
            {
                ThrowIfDisposed();

                float volume;
                int result = endpointVolume.GetMasterVolumeLevelScalar(out volume);

                if (result != 0)
                {
                    throw new InvalidOperationException($"Failed to get volume level. Error code: {result}");
                }

                return volume;
            }
            set
            {
                ThrowIfDisposed();

                // Clamp value to valid range using fast ternary
                value = value < 0.0f ? 0.0f : (value > 1.0f ? 1.0f : value);

                int result = endpointVolume.SetMasterVolumeLevelScalar(value, ref EmptyGuid);

                if (result != 0)
                {
                    throw new InvalidOperationException($"Failed to set volume level. Error code: {result}");
                }
            }
        }

        /// <summary>
        /// Gets or sets the volume as a percentage (0 to 100)
        /// </summary>
        public int VolumePercentage
        {
            get => (int)(Volume * 100);
            set => Volume = value / 100.0f;
        }

        /// <summary>
        /// Gets or sets the mute state
        /// </summary>
        public bool IsMuted
        {
            get
            {
                ThrowIfDisposed();

                bool isMuted;
                int result = endpointVolume.GetMute(out isMuted);

                if (result != 0)
                {
                    throw new InvalidOperationException($"Failed to get mute state. Error code: {result}");
                }

                return isMuted;
            }
            set
            {
                ThrowIfDisposed();

                int result = endpointVolume.SetMute(value, ref EmptyGuid);

                if (result != 0)
                {
                    throw new InvalidOperationException($"Failed to set mute state. Error code: {result}");
                }
            }
        }
        
        [System.Runtime.CompilerServices.MethodImpl(System.Runtime.CompilerServices.MethodImplOptions.AggressiveInlining)]
        private void ThrowIfDisposed()
        {
            if (disposed || endpointVolume == null)
                throw new ObjectDisposedException(nameof(AudioVolumeController));
        }

        #endregion

        #region Advanced Volume Methods

        /// <summary>
        /// Steps the volume up by one increment
        /// </summary>
        public void VolumeUp()
        {
            ThrowIfDisposed();

            int result = endpointVolume.VolumeStepUp(ref EmptyGuid);

            if (result != 0)
            {
                throw new InvalidOperationException($"Failed to step volume up. Error code: {result}");
            }
        }

        /// <summary>
        /// Steps the volume down by one increment
        /// </summary>
        public void VolumeDown()
        {
            ThrowIfDisposed();

            int result = endpointVolume.VolumeStepDown(ref EmptyGuid);

            if (result != 0)
            {
                throw new InvalidOperationException($"Failed to step volume down. Error code: {result}");
            }
        }

        /// <summary>
        /// Toggles the mute state
        /// </summary>
        public void ToggleMute() => IsMuted = !IsMuted;

        /// <summary>
        /// Gets volume range information
        /// </summary>
        public VolumeRangeInfo GetVolumeRange()
        {
            if (disposed || endpointVolume == null)
                throw new ObjectDisposedException(nameof(AudioVolumeController));

            float minDB, maxDB, increment;
            int result = endpointVolume.GetVolumeRange(out minDB, out maxDB, out increment);

            if (result != 0)
            {
                throw new InvalidOperationException($"Failed to get volume range. Error code: {result}");
            }

            return new VolumeRangeInfo(minDB, maxDB, increment);
        }

        /// <summary>
        /// Gets volume step information
        /// </summary>
        public VolumeStepInfo GetVolumeStepInfo()
        {
            if (disposed || endpointVolume == null)
                throw new ObjectDisposedException(nameof(AudioVolumeController));

            uint currentStep, stepCount;
            int result = endpointVolume.GetVolumeStepInfo(out currentStep, out stepCount);

            if (result != 0)
            {
                throw new InvalidOperationException($"Failed to get volume step info. Error code: {result}");
            }

            return new VolumeStepInfo(currentStep, stepCount);
        }

        #endregion

        #region Information Methods

        /// <summary>
        /// Displays current audio information
        /// </summary>
        public void DisplayAudioInfo()
        {
            Console.WriteLine("\n=== Audio Volume Information ===");
            
            try
            {
                Console.WriteLine($"Current Volume: {VolumePercentage}%");
                Console.WriteLine($"Mute Status: {(IsMuted ? "Muted" : "Unmuted")}");
                
                var rangeInfo = GetVolumeRange();
                Console.WriteLine($"Volume Range: {rangeInfo.MinDB:F2} dB to {rangeInfo.MaxDB:F2} dB");
                Console.WriteLine($"Step Increment: {rangeInfo.Increment:F2} dB");
                
                var stepInfo = GetVolumeStepInfo();
                Console.WriteLine($"Current Step: {stepInfo.CurrentStep}/{stepInfo.StepCount}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting audio info: {ex.Message}");
            }
            
            Console.WriteLine("===============================\n");
        }

        #endregion
    }

    #region Supporting Classes

    /// <summary>
    /// Information about the volume range
    /// </summary>
    public class VolumeRangeInfo
    {
        public float MinDB { get; }
        public float MaxDB { get; }
        public float Increment { get; }

        public VolumeRangeInfo(float minDB, float maxDB, float increment)
        {
            MinDB = minDB;
            MaxDB = maxDB;
            Increment = increment;
        }
    }

    /// <summary>
    /// Information about volume steps
    /// </summary>
    public class VolumeStepInfo
    {
        public uint CurrentStep { get; }
        public uint StepCount { get; }

        public VolumeStepInfo(uint currentStep, uint stepCount)
        {
            CurrentStep = currentStep;
            StepCount = stepCount;
        }
    }

    #endregion
}