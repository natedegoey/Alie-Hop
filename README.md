# Alie-Hop
Assembly Language Project. My own spin on the popular mobile flash game Doodle Jump. Culminating assignment in my Computer Organization class at the University of Toronto (CSC258H1).
Made using MIPS assembly language in the MARS IDE simulated envrionment. Used with a simulated bitmap display and keyboard input. Use the "j" and "k" keys to move left and right, respectively. While working through the project, I implemented the working game (similar to doodle jump) and continued to personalize the project by adding sound effects, a scoreboard that updates in real time, the ability to enter your name before you start the game, the ability to retry, some fancier graphics, and random pop-up messages to encourage the player to keep playing!
I am super proud of this project. This was my first time working in Assembly, and while it was a huge learning curve, I am extremely happy with how my game turned out!
Final Score: 100%

SETUP AND GAMEPLAY INSTRUCTIONS:
1. Open the project in MARS version 4.5.
2. Navigate to the Tools tab in the menu bar.
3. From Tools, select Bitmap Display.
4. In the display, configure the following settings:
  - Unit Width in Pixels: 8
  - Unit Height in Pixels: 8
  - Display Width in Pixels: 256
  - Display Height in Pixels: 256
  - Base address for display: 0x10008000 ($gp)
5. Once finished setting up the proper configurations, select Connect to MIPS.
6. Navigate back to the Tools tab and select Keyboard and Display MMIO Simulator.
7. In the simulator, select Connect to MIPS.
8. Rearrange the windows for easy access to the keyboard simulator and easy viewing of the bitmap display

TO PLAY:
1. In the main MIPS window, select the Assemble button (a Wrench and Screw Driver forming an X).
2. Select the green RUN button immediately beside the Assemble button. You should now see the title screen in the bitmap display.
3. In order to start the game, click in the bottom KEYBOARD box from the keyboard simulator, then follow these steps:
  - type 's' (must be lowercase)
  - type in exactly 4 digits that represent your character name (try 'alie' if you'd like, or any combination of lowercase letters from the english alphabet).
  - the game will start immediately after you have finished typing your name. Press the 'j' and 'k' keys (left and right, respectively) to move ALIE.
4. The game continues infinitely until ALIE misses a platform and hits the bottom of the screen. At this point a GAME OVER menu will be displayed, 
  showing the players name and score. The player can simply press 's' again to retry with the same name.
5. If you would like to restart with a different name, press the green STOP button in the MIPS window, and repeat TO PLAY steps, entering in a new 4 digit name.

I sincerely hope you enjoy playing ALIE-HOP as much as I enjoyed making it.
