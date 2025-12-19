"""
Windows Audio Volume Controller - Python Implementation

This module provides comprehensive control over Windows audio volume using the
Core Audio API through pywin32. It supports volume control, mute/unmute, and
volume stepping functionality.

Requirements:
    - pywin32 (pip install pywin32)
    - Windows Vista or later (Core Audio API support)

Author: Windows Volume Controller
Version: 1.0.0
"""

import ctypes
import comtypes.client
from comtypes import GUID
import time
from typing import Optional, Tuple


class AudioVolumeController:
    """
    Controller for Windows audio volume using Core Audio API.
    
    This class provides methods to control the master audio volume and mute state.
    """
    
    def __init__(self):
        """Initialize the audio controller and connect to default audio endpoint."""
        self._device_enumerator = None
        self._device = None
        self._endpoint_volume = None
        
        try:
            self._initialize_audio_controller()
        except Exception as e:
            raise RuntimeError(f"Failed to initialize audio controller: {e}")
    
    def _initialize_audio_controller(self):
        """Initialize COM interfaces for audio control."""
        # Create device enumerator
        device_enumerator = comtypes.client.CreateObject(
            "{BCDE0395-E52F-467C-8E3D-C4579291692E}"
        )
        
        # Get default audio endpoint (render, console)
        self._device = device_enumerator.GetDefaultAudioEndpoint(0, 1)  # eRender, eConsole
        
        # Get endpoint volume interface
        self._endpoint_volume = self._device.Activate(
            GUID("{5CDF2C82-841E-4546-9722-0CF74078229A}"),
            comtypes.CLSCTX_ALL,
            None
        )
        
        self._device_enumerator = device_enumerator
    
    @property
    def volume(self) -> float:
        """
        Get the current master volume level (0.0 to 1.0).
        
        Returns:
            float: Current volume level between 0.0 and 1.0
        """
        volume = ctypes.c_float()
        self._endpoint_volume.GetMasterVolumeLevelScalar(ctypes.byref(volume))
        return volume.value
    
    @volume.setter
    def volume(self, value: float):
        """
        Set the master volume level (0.0 to 1.0).
        
        Args:
            value (float): Volume level between 0.0 and 1.0
        """
        # Clamp value to valid range
        value = max(0.0, min(1.0, value))
        
        empty_guid = GUID()
        self._endpoint_volume.SetMasterVolumeLevelScalar(value, empty_guid)
    
    @property
    def volume_percentage(self) -> int:
        """
        Get the current volume as a percentage (0 to 100).
        
        Returns:
            int: Current volume percentage
        """
        return int(self.volume * 100)
    
    @volume_percentage.setter
    def volume_percentage(self, value: int):
        """
        Set the volume as a percentage (0 to 100).
        
        Args:
            value (int): Volume percentage (0-100)
        """
        if not 0 <= value <= 100:
            raise ValueError("Volume percentage must be between 0 and 100")
        
        self.volume = value / 100.0
    
    @property
    def is_muted(self) -> bool:
        """
        Get the current mute state.
        
        Returns:
            bool: True if muted, False otherwise
        """
        muted = ctypes.c_bool()
        self._endpoint_volume.GetMute(ctypes.byref(muted))
        return muted.value
    
    @is_muted.setter
    def is_muted(self, value: bool):
        """
        Set the mute state.
        
        Args:
            value (bool): True to mute, False to unmute
        """
        empty_guid = GUID()
        self._endpoint_volume.SetMute(value, empty_guid)
    
    def volume_up(self):
        """Step the volume up by one increment."""
        empty_guid = GUID()
        self._endpoint_volume.VolumeStepUp(empty_guid)
    
    def volume_down(self):
        """Step the volume down by one increment."""
        empty_guid = GUID()
        self._endpoint_volume.VolumeStepDown(empty_guid)
    
    def toggle_mute(self):
        """Toggle the mute state."""
        self.is_muted = not self.is_muted
    
    def get_volume_range(self) -> Tuple[float, float, float]:
        """
        Get the volume range information.
        
        Returns:
            Tuple[float, float, float]: (min_dB, max_dB, increment_dB)
        """
        min_db = ctypes.c_float()
        max_db = ctypes.c_float()
        increment = ctypes.c_float()
        
        self._endpoint_volume.GetVolumeRange(
            ctypes.byref(min_db),
            ctypes.byref(max_db),
            ctypes.byref(increment)
        )
        
        return (min_db.value, max_db.value, increment.value)
    
    def get_volume_step_info(self) -> Tuple[int, int]:
        """
        Get volume step information.
        
        Returns:
            Tuple[int, int]: (current_step, step_count)
        """
        current_step = ctypes.c_uint()
        step_count = ctypes.c_uint()
        
        self._endpoint_volume.GetVolumeStepInfo(
            ctypes.byref(current_step),
            ctypes.byref(step_count)
        )
        
        return (current_step.value, step_count.value)
    
    def display_audio_info(self):
        """Display comprehensive audio information."""
        print("\n=== Audio Volume Information ===")
        
        try:
            print(f"Current Volume: {self.volume_percentage}%")
            print(f"Mute Status: {'Muted' if self.is_muted else 'Unmuted'}")
            
            min_db, max_db, increment = self.get_volume_range()
            print(f"Volume Range: {min_db:.2f} dB to {max_db:.2f} dB")
            print(f"Step Increment: {increment:.2f} dB")
            
            current_step, step_count = self.get_volume_step_info()
            print(f"Current Step: {current_step}/{step_count}")
            
            # Visual volume bar
            bar_length = 20
            filled_length = int(self.volume * bar_length)
            empty_length = bar_length - filled_length
            bar = "[" + "█" * filled_length + "░" * empty_length + "]"
            print(f"Volume Bar: {bar}")
            
        except Exception as e:
            print(f"Error getting audio info: {e}")
        
        print("===============================\n")
    
    def __del__(self):
        """Cleanup COM objects when object is destroyed."""
        try:
            if self._endpoint_volume:
                comtypes.CoReleaseObject(self._endpoint_volume)
            if self._device:
                comtypes.CoReleaseObject(self._device)
            if self._device_enumerator:
                comtypes.CoReleaseObject(self._device_enumerator)
        except:
            pass


class AudioControllerCLI:
    """Command-line interface for the audio controller."""
    
    def __init__(self):
        self.controller = None
        
        try:
            self.controller = AudioVolumeController()
        except Exception as e:
            print(f"Error initializing audio controller: {e}")
            print("Make sure pywin32 is installed: pip install pywin32")
            raise
    
    def run(self, args):
        """
        Run the CLI with provided arguments.
        
        Args:
            args (list): Command line arguments
        """
        if not args:
            self.controller.display_audio_info()
            self._show_usage()
            return 0
        
        command = args[0].lower()
        
        try:
            if command == "get":
                return self._get_volume()
            elif command == "set":
                return self._set_volume(args[1:] if len(args) > 1 else [])
            elif command == "mute":
                return self._set_mute(True)
            elif command == "unmute":
                return self._set_mute(False)
            elif command == "toggle":
                return self._toggle_mute()
            elif command == "up":
                return self._volume_step(True)
            elif command == "down":
                return self._volume_step(False)
            elif command == "info":
                self.controller.display_audio_info()
                return 0
            elif command == "range":
                return self._show_volume_range()
            elif command == "steps":
                return self._show_volume_steps()
            else:
                print(f"Unknown command: {command}")
                self._show_usage()
                return 1
                
        except Exception as e:
            print(f"Error: {e}")
            return 1
    
    def _get_volume(self):
        """Get and display current volume."""
        volume = self.controller.volume_percentage
        print(f"Current Volume: {volume}%")
        return 0
    
    def _set_volume(self, args):
        """Set volume to specified percentage."""
        if not args:
            print("Error: Please specify a volume percentage (0-100)")
            return 1
        
        try:
            percentage = int(args[0])
            if not 0 <= percentage <= 100:
                print("Error: Volume must be between 0 and 100")
                return 1
            
            self.controller.volume_percentage = percentage
            print(f"Volume set to {percentage}%")
            return 0
            
        except ValueError:
            print("Error: Invalid volume value. Please enter a number.")
            return 1
    
    def _set_mute(self, mute):
        """Set mute state."""
        self.controller.is_muted = mute
        status = "muted" if mute else "unmuted"
        print(f"Audio {status}")
        return 0
    
    def _toggle_mute(self):
        """Toggle mute state."""
        self.controller.toggle_mute()
        status = "muted" if self.controller.is_muted else "unmuted"
        print(f"Audio {status}")
        return 0
    
    def _volume_step(self, up):
        """Step volume up or down."""
        if up:
            self.controller.volume_up()
            print("Volume stepped up")
        else:
            self.controller.volume_down()
            print("Volume stepped down")
        
        print(f"Current Volume: {self.controller.volume_percentage}%")
        return 0
    
    def _show_volume_range(self):
        """Display volume range information."""
        min_db, max_db, increment = self.controller.get_volume_range()
        print("\n=== Volume Range Information ===")
        print(f"Minimum Level: {min_db:.2f} dB")
        print(f"Maximum Level: {max_db:.2f} dB")
        print(f"Step Increment: {increment:.2f} dB")
        print("===============================")
        return 0
    
    def _show_volume_steps(self):
        """Display volume step information."""
        current_step, step_count = self.controller.get_volume_step_info()
        progress = (current_step / step_count * 100) if step_count > 0 else 0
        print("\n=== Volume Step Information ===")
        print(f"Current Step: {current_step}")
        print(f"Total Steps: {step_count}")
        print(f"Progress: {current_step}/{step_count} ({progress:.1f}%)")
        print("===============================")
        return 0
    
    def _show_usage(self):
        """Display usage information."""
        print("\nWindows Audio Volume Controller (Python)")
        print("Usage:")
        print("  python audio_controller.py                    - Show current volume info")
        print("  python audio_controller.py get                 - Get current volume percentage")
        print("  python audio_controller.py set <0-100>         - Set volume to percentage")
        print("  python audio_controller.py mute               - Mute audio")
        print("  python audio_controller.py unmute             - Unmute audio")
        print("  python audio_controller.py toggle             - Toggle mute state")
        print("  python audio_controller.py up                 - Volume step up")
        print("  python audio_controller.py down               - Volume step down")
        print("  python audio_controller.py info               - Show detailed audio info")
        print("  python audio_controller.py range              - Show volume range info")
        print("  python audio_controller.py steps              - Show volume step info")
        print()
        print("Examples:")
        print("  python audio_controller.py set 75")
        print("  python audio_controller.py mute")
        print("  python audio_controller.py up")


def main():
    """Main entry point for the script."""
    import sys
    
    try:
        cli = AudioControllerCLI()
        return cli.run(sys.argv[1:])
    except Exception as e:
        print(f"Fatal error: {e}")
        return 1


if __name__ == "__main__":
    exit(main())