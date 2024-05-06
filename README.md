# NWNGamepadControls
A Unity/AutoIT repo to map Gamepad controls to mouse movements and clicks in the Game Neverwinter Nights

## Installation
First, you need a build of the Unity project found here (TBD link) that outputs Gamepad controls to text files for consumption by AutoIT. Then simply run the `NWNCustomControls.au3` file and follow the instructions in the dialogue boxes that appear.

## Control Layout

- **Left Stick**
  - Moves the mouse relative to your character or last selected center position
  - Press-in to unlock from its current position and move the cursur freely
  - Press-in again to re-lock from the current position
  - Double press-in the stick to reset your cursor position to your character
- **Right Stick**
  - Moves the camera left or right (vertical axis is unused)
  - Press-in and hold to "free rotate" the camera
- **Left Bumper**
  - Presses Tab
- **Right Bumper**
  - Hold to activate "hot slot" mode if used with D-Pad
    - In hot slot mode, use the D-Pad to control which slot to select, and A to select it
    - Your mouse will return to its previous position upon release of the bumper
    - See D-Pad section for more details
- **Left Trigger**
  - Zoom out
- **Right Trigger**
  - Zoom in
- **Left Menu Button**
  - Opens your Inventory
- **Right Menu Button**
  - Opens the pause menu
- **D-Pad**
  - Moves your cursor "1 square" in any directon (if not in hot slot mode)
    - Pressing and holding has no effect
    - Note that your cursor may not be "lined up" on the expected grid (reach goal will solve this)
  - If holding the right bumper (and therefore in "hot slot" mode), controls which slot is selected
    - Use the Up/Down of the d-pad to move to upper or lower slots (wraps around)
      - The main slot is treated as the "center" slot row
      - The Ctrl slots are treated as the "lower" slot row
      - The Shift slots are treated as the "upper" slot row
    - Once on the desired slot, press A or B to click how you want
      - If you need to right click keep holding the right bumper, and you will automatically have your cursor centered and controllable via the left stick
      - If you need to left click, you can release the right bumper as there are no further actions you would need to take
    - All other controls are disabled while you are holding the right bumper
    - The selected hot slot is saved, so the next time you press the right bumper your cursor will be in the same position
  - If holding the Left Bumper, each direction is mapped to a voice command shortcut. Release the bumper to initiate the voiceover
    - N: Follow me (v+e+e)
    - NE: Hi (v+s+s)
    - E: Bye (v+s+a)
    - SE: Laugh (v+x+w)
    - S: Attack (v+w+e)
    - SW: Battlecry (v+w+r)
    - W: Hold (v+w+x)
    - NW: Guard (v+w+f)
    - NES: Look here (v+e+w)
    - ESW: Bored (v+s+x)
    - SWN: Threaten (v+x+e)
    - NS: Thanks (v+x+x)
    - EW: Cheer (v+x+d)
    - NESW: Cuss (v+x+c)
  - Press and hold the down button to initiate a scroll down (if not in hot slot mode)
  - Press and hold the up button to initiate a scroll up (if not in hot slot mode)
- **A**
  - Left click
- **B**
  - Right Click
- **X**
  - Rest
  - If holding right bumper, toggle Journal
  - If holding left bumper, toggle character sheet
- **Y**
  - Toggle Map
  - If holding right bumper, toggle Spell Book
  - If holding left bumper, toggle Player List