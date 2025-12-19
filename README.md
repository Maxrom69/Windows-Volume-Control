# WindowsVolumeControl
Control Windows Volume with MIDI interface.

Importent, this is my first project for coding,
I used AI to create a Python program for using
Your MIDI interface (Only knobs buttons work, for now)
For setting your Windows audio,Input,output and
Open software Ex:Chrome, Steam, Media Player...ect
There some corections to do, but I guest I am
At the right place.
======================================================

USER GUIDE
==========


📖 MIDI Volume Controller: Session Mixer - User Guide
=====================================================
This application allows you to use a standard MIDI controller (potentiometers, faders, and buttons) to manage your Windows system volume and volume for individual applications.
=====================================================


🚀 Getting Started
==================
When you launch the application (.exe or .ps1), the script will first check for your saved configuration.
Prompt	Action Required	Result
Enter (1) to RE-MAP	Select 1 if you are setting up the device for the first time, have changed your MIDI controller, or want to change control assignments.	Starts the interactive 6-step learning process.
Enter (2) to LOAD	Select 2 if you have already completed the learning process and saved the midi_config.json file.	Loads controls immediately and starts mixing.
==================================================



🎧 How to Use the Application Mixer
===================================
The console will display the status of the currently selected app (e.g., [SELECTED APP: 2/3] Mozilla Firefox Volume: [...] 75%).
Press the App Selector (CC#26) button to cycle through all running applications that have active audio sessions (e.g., games, browsers, chat apps, etc.).
Once the desired application is displayed, move the App Volume (CC#9) fader to adjust its volume independently of the Master Volume.


🚫 Troubleshooting and Exiting
==============================
To Stop the Program: Press Ctrl + C in the console window.
Missing midi_config.json: If the file is missing or corrupted, the program will automatically default to the re-mapping process (Step 1).
"No MIDI devices found!": Ensure your MIDI controller is powered on and correctly connected to your computer before launching the application.
"High-level execution error..." (DLL/Module errors in .exe): This usually means the executable was not built correctly. Ensure your build includes the --hidden-import mido.backends.rtmidi flag.
