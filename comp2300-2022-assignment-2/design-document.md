---
title: "COMP2300 Assignment Design Document"
author: Xinyun Zhou
email: u7326123@anu.edu.au
---

<!-- write your design document here -->
### What
I use ARMv7 assembly code on my microbit to create a small digital pet by the LED display that the player would be able to take care of. The pet has two states, one is health and another is happiness. The maximum value of both of these states is 800. When any of these two states rich the maximum, there will be a short anime to show that value is max. Health and happiness will decrease over time. Also, when any of these two states is equal to 0, there will be a short anime to let the player know the pet's state. The player would be able to press button A to feed the pet (+80 health) or press button B to play with the pet (+50 happiness). The player will be able to touch the microbit (sensor), and the pet will kiss the player. The digital pet is work when the microbit is powered over USB but not connected to a computer. The digital pet is interaction for a fun experience of more than 1 minute.

### How
To draw the picture, I used a function called `draw_picture`. This function would be able to read 5 binary numbers to draw an image. These 5 binary numbers mean 5 rows of LEDs. Each binary number has 5 digits that each digit represents different columns of LEDs. 0 represents turn_off and 1 means turn_on. I save these binary numbers in the memory and use the for loop to combine them into an image.     
I'm using the `help_to_draw` function to help me draw the anime. The `help_to_draw` function would be able to read the memory and use the input from the memory to the `draw_picture` function and draw the image. Then the  `help_to_draw` function would combine the images and make them into anime.    
I store the health state and happiness state in memory. Every time I'm trying to reduce or increase the value of the state, I will load the memory, make changes, and store it back in the memory.     
I used the `SysTick` to reduce the value of health state and happiness. When the `SysTick` counts down to 0, health and happiness will decrease by 1.    
Because I decide to use three buttons to represent different animes, so I used the if then else functions to check the buttons I pressed in the `GPIOTE_IRQHandler`.    

### Why
The reason that I decide to use the `draw_picture` function is that I found that there is a lot of duplicate code for me to write if I try to draw the picture one by one. I'm using the `help_to_draw` function to try to reduce the duplicate as well. Also, using the `draw_picture` function and the `help_to_draw` function makes me much easier to debug and write the code.      
I decide to use the `SysTick` to reduce the value of the health state and happiness state because the `SysTick` is decreasing every second whatever the main function does. `SysTick_Handler` will interrupt the program when the `SysTick` counts down to 0.      
The good thing about my final design is that I'm using a lot of memory stuff. I'm getting familiar with loading the memory and storing the memory. I have used the interrupt (the `SysTick` and buttons) in this task and these interrupt did the thing I wish.     
The thing that I'm doing not well is that some part of my code doesn't meet the AAPCS requirement. I have tried to follow the AAPCS but I found that my code will make confusion sometimes. And my final design is not complete everything I planned in the design proposal.     
