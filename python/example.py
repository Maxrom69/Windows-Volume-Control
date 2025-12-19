"""
Example usage of the Windows Audio Volume Controller

This script demonstrates various ways to use the AudioVolumeController class
for controlling Windows audio volume programmatically.
"""

import time
from audio_controller import AudioVolumeController


def basic_usage_example():
    """Demonstrate basic volume control operations."""
    print("=== Basic Usage Example ===")
    
    try:
        # Initialize the controller
        controller = AudioVolumeController()
        
        # Show current status
        controller.display_audio_info()
        
        # Set volume to 50%
        print("Setting volume to 50%...")
        controller.volume_percentage = 50
        time.sleep(1)
        print(f"Current volume: {controller.volume_percentage}%")
        
        # Mute audio
        print("Muting audio...")
        controller.is_muted = True
        time.sleep(1)
        print(f"Muted: {controller.is_muted}")
        
        # Unmute audio
        print("Unmuting audio...")
        controller.is_muted = False
        time.sleep(1)
        print(f"Muted: {controller.is_muted}")
        
    except Exception as e:
        print(f"Error in basic usage example: {e}")


def volume_ramp_example():
    """Demonstrate volume ramping."""
    print("\n=== Volume Ramp Example ===")
    
    try:
        controller = AudioVolumeController()
        
        print("Ramping volume from 0% to 100%...")
        for volume in range(0, 101, 10):
            controller.volume_percentage = volume
            print(f"Volume: {volume}%")
            time.sleep(0.5)
        
        print("Ramping volume from 100% to 0%...")
        for volume in range(100, -1, -10):
            controller.volume_percentage = volume
            print(f"Volume: {volume}%")
            time.sleep(0.5)
        
    except Exception as e:
        print(f"Error in volume ramp example: {e}")


def step_control_example():
    """Demonstrate step-based volume control."""
    print("\n=== Step Control Example ===")
    
    try:
        controller = AudioVolumeController()
        
        # Set to a moderate starting volume
        controller.volume_percentage = 50
        print(f"Starting volume: {controller.volume_percentage}%")
        
        print("Stepping up 5 times...")
        for i in range(5):
            controller.volume_up()
            print(f"Step {i+1}: {controller.volume_percentage}%")
            time.sleep(0.5)
        
        print("Stepping down 5 times...")
        for i in range(5):
            controller.volume_down()
            print(f"Step {i+1}: {controller.volume_percentage}%")
            time.sleep(0.5)
        
    except Exception as e:
        print(f"Error in step control example: {e}")


def volume_info_example():
    """Demonstrate getting detailed volume information."""
    print("\n=== Volume Information Example ===")
    
    try:
        controller = AudioVolumeController()
        
        # Basic info
        print(f"Current Volume: {controller.volume_percentage}%")
        print(f"Muted: {controller.is_muted}")
        
        # Range info
        min_db, max_db, increment = controller.get_volume_range()
        print(f"Volume Range: {min_db:.2f} dB to {max_db:.2f} dB")
        print(f"Step Increment: {increment:.2f} dB")
        
        # Step info
        current_step, step_count = controller.get_volume_step_info()
        print(f"Current Step: {current_step}/{step_count}")
        
        if step_count > 0:
            progress = (current_step / step_count) * 100
            print(f"Progress: {progress:.1f}%")
        
    except Exception as e:
        print(f"Error in volume info example: {e}")


def interactive_demo():
    """Interactive demonstration with user input."""
    print("\n=== Interactive Demo ===")
    
    try:
        controller = AudioVolumeController()
        
        while True:
            print("\nCurrent Status:")
            controller.display_audio_info()
            
            print("\nOptions:")
            print("1. Set volume (0-100)")
            print("2. Volume up")
            print("3. Volume down")
            print("4. Mute")
            print("5. Unmute")
            print("6. Toggle mute")
            print("7. Exit")
            
            choice = input("Enter your choice (1-7): ").strip()
            
            if choice == "1":
                try:
                    volume = int(input("Enter volume percentage (0-100): "))
                    if 0 <= volume <= 100:
                        controller.volume_percentage = volume
                        print(f"Volume set to {volume}%")
                    else:
                        print("Volume must be between 0 and 100")
                except ValueError:
                    print("Invalid input. Please enter a number.")
            
            elif choice == "2":
                controller.volume_up()
                print(f"Volume stepped up to {controller.volume_percentage}%")
            
            elif choice == "3":
                controller.volume_down()
                print(f"Volume stepped down to {controller.volume_percentage}%")
            
            elif choice == "4":
                controller.is_muted = True
                print("Audio muted")
            
            elif choice == "5":
                controller.is_muted = False
                print("Audio unmuted")
            
            elif choice == "6":
                controller.toggle_mute()
                print(f"Audio {'muted' if controller.is_muted else 'unmuted'}")
            
            elif choice == "7":
                print("Goodbye!")
                break
            
            else:
                print("Invalid choice. Please try again.")
            
            time.sleep(1)
        
    except Exception as e:
        print(f"Error in interactive demo: {e}")


def volume_monitoring_example():
    """Monitor volume changes over time."""
    print("\n=== Volume Monitoring Example ===")
    print("Monitoring volume for 10 seconds...")
    print("Try changing the volume using your keyboard or mouse!")
    
    try:
        controller = AudioVolumeController()
        
        start_time = time.time()
        last_volume = controller.volume_percentage
        last_mute = controller.is_muted
        
        while time.time() - start_time < 10:
            current_volume = controller.volume_percentage
            current_mute = controller.is_muted
            
            if current_volume != last_volume or current_mute != last_mute:
                print(f"Change detected - Volume: {current_volume}%, Muted: {current_mute}")
                last_volume = current_volume
                last_mute = current_mute
            
            time.sleep(0.1)
        
        print("Monitoring complete.")
        
    except Exception as e:
        print(f"Error in volume monitoring example: {e}")


if __name__ == "__main__":
    print("Windows Audio Volume Controller - Examples")
    print("=" * 50)
    
    examples = [
        ("Basic Usage", basic_usage_example),
        ("Volume Ramp", volume_ramp_example),
        ("Step Control", step_control_example),
        ("Volume Information", volume_info_example),
        ("Interactive Demo", interactive_demo),
        ("Volume Monitoring", volume_monitoring_example)
    ]
    
    print("Available examples:")
    for i, (name, _) in enumerate(examples, 1):
        print(f"{i}. {name}")
    
    try:
        choice = input("\nSelect an example (1-6) or press Enter for all: ").strip()
        
        if choice == "":
            # Run all examples except interactive
            for name, func in examples:
                if name != "Interactive Demo":
                    print(f"\n{'='*50}")
                    print(f"Running: {name}")
                    print('='*50)
                    func()
                    time.sleep(2)
        elif choice.isdigit() and 1 <= int(choice) <= len(examples):
            index = int(choice) - 1
            name, func = examples[index]
            print(f"\n{'='*50}")
            print(f"Running: {name}")
            print('='*50)
            func()
        else:
            print("Invalid choice.")
            
    except KeyboardInterrupt:
        print("\n\nExample interrupted by user.")
    except Exception as e:
        print(f"\nError running examples: {e}")