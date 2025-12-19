using System;
using System.Linq;

namespace WindowsAudioController
{
    /// <summary>
    /// Console application for controlling Windows audio volume
    /// </summary>
    class Program
    {
        static int Main(string[] args)
        {
            try
            {
                using (var controller = new AudioVolumeController())
                {
                    if (args.Length == 0)
                    {
                        // No arguments - show current volume info
                        controller.DisplayAudioInfo();
                        ShowUsage();
                        return 0;
                    }

                    string command = args[0].ToLowerInvariant();

                    switch (command)
                    {
                        case "get":
                            return GetVolume(controller);
                        
                        case "set":
                            return SetVolume(controller, args);
                        
                        case "mute":
                            return SetMute(controller, true);
                        
                        case "unmute":
                            return SetMute(controller, false);
                        
                        case "toggle":
                            return ToggleMute(controller);
                        
                        case "up":
                            return VolumeStep(controller, true);
                        
                        case "down":
                            return VolumeStep(controller, false);
                        
                        case "info":
                            controller.DisplayAudioInfo();
                            return 0;
                        
                        case "range":
                            return ShowVolumeRange(controller);
                        
                        case "steps":
                            return ShowVolumeSteps(controller);
                        
                        default:
                            Console.Error.WriteLine($"Unknown command: {command}");
                            ShowUsage();
                            return 1;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Error: {ex.Message}");
                return 1;
            }
        }

        static void ShowUsage()
        {
            Console.WriteLine("\nWindows Audio Volume Controller");
            Console.WriteLine("Usage:");
            Console.WriteLine("  AudioVolumeController.exe                    - Show current volume info");
            Console.WriteLine("  AudioVolumeController.exe get                 - Get current volume percentage");
            Console.WriteLine("  AudioVolumeController.exe set <0-100>         - Set volume to percentage");
            Console.WriteLine("  AudioVolumeController.exe mute               - Mute audio");
            Console.WriteLine("  AudioVolumeController.exe unmute             - Unmute audio");
            Console.WriteLine("  AudioVolumeController.exe toggle             - Toggle mute state");
            Console.WriteLine("  AudioVolumeController.exe up                 - Volume step up");
            Console.WriteLine("  AudioVolumeController.exe down               - Volume step down");
            Console.WriteLine("  AudioVolumeController.exe info               - Show detailed audio info");
            Console.WriteLine("  AudioVolumeController.exe range              - Show volume range info");
            Console.WriteLine("  AudioVolumeController.exe steps              - Show volume step info");
            Console.WriteLine();
            Console.WriteLine("Examples:");
            Console.WriteLine("  AudioVolumeController.exe set 75");
            Console.WriteLine("  AudioVolumeController.exe mute");
            Console.WriteLine("  AudioVolumeController.exe up");
        }

        static int GetVolume(AudioVolumeController controller)
        {
            try
            {
                int volume = controller.VolumePercentage;
                Console.WriteLine($"Current Volume: {volume}%");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Failed to get volume: {ex.Message}");
                return 1;
            }
        }

        static int SetVolume(AudioVolumeController controller, string[] args)
        {
            if (args.Length < 2)
            {
                Console.Error.WriteLine("Error: Please specify a volume percentage (0-100)");
                return 1;
            }

            if (!int.TryParse(args[1], out int percentage) || percentage < 0 || percentage > 100)
            {
                Console.Error.WriteLine("Error: Volume must be a number between 0 and 100");
                return 1;
            }

            try
            {
                controller.VolumePercentage = percentage;
                Console.WriteLine($"Volume set to {percentage}%");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Failed to set volume: {ex.Message}");
                return 1;
            }
        }

        static int SetMute(AudioVolumeController controller, bool mute)
        {
            try
            {
                controller.IsMuted = mute;
                Console.WriteLine($"Audio {(mute ? "muted" : "unmuted")}");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Failed to {(mute ? "mute" : "unmute")} audio: {ex.Message}");
                return 1;
            }
        }

        static int ToggleMute(AudioVolumeController controller)
        {
            try
            {
                controller.ToggleMute();
                Console.WriteLine($"Audio {(controller.IsMuted ? "muted" : "unmuted")}");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Failed to toggle mute: {ex.Message}");
                return 1;
            }
        }

        static int VolumeStep(AudioVolumeController controller, bool up)
        {
            try
            {
                if (up)
                {
                    controller.VolumeUp();
                    Console.WriteLine("Volume stepped up");
                }
                else
                {
                    controller.VolumeDown();
                    Console.WriteLine("Volume stepped down");
                }
                Console.WriteLine($"Current Volume: {controller.VolumePercentage}%");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Failed to step volume {(up ? "up" : "down")}: {ex.Message}");
                return 1;
            }
        }

        static int ShowVolumeRange(AudioVolumeController controller)
        {
            try
            {
                var rangeInfo = controller.GetVolumeRange();
                Console.WriteLine("\n=== Volume Range Information ===");
                Console.WriteLine($"Minimum Level: {rangeInfo.MinDB:F2} dB");
                Console.WriteLine($"Maximum Level: {rangeInfo.MaxDB:F2} dB");
                Console.WriteLine($"Step Increment: {rangeInfo.Increment:F2} dB");
                Console.WriteLine("===============================");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Failed to get volume range: {ex.Message}");
                return 1;
            }
        }

        static int ShowVolumeSteps(AudioVolumeController controller)
        {
            try
            {
                var stepInfo = controller.GetVolumeStepInfo();
                Console.WriteLine("\n=== Volume Step Information ===");
                Console.WriteLine($"Current Step: {stepInfo.CurrentStep}");
                Console.WriteLine($"Total Steps: {stepInfo.StepCount}");
                Console.WriteLine($"Progress: {stepInfo.CurrentStep}/{stepInfo.StepCount} " +
                                 $"({(stepInfo.StepCount > 0 ? (double)stepInfo.CurrentStep / stepInfo.StepCount * 100 : 0):F1}%)");
                Console.WriteLine("===============================");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Failed to get volume step info: {ex.Message}");
                return 1;
            }
        }
    }
}