---
title: "Design Proposal"
author: Xinyun Zhou
email: u7326123@anu.edu.au
---

<!-- write your design proposal here -->
I will create a digital pet of a duck. My digital pet will include the following features:  
1. The value of health (store in the memory, maximum of 120, minimum of 0).
2. The value of wellbeing (store in the memory, maximum of 120, minimum of 0).
3. Have a meal when I press button A, short anime of eating (+30 in health until health is equal to 120). If health is 120, a short anime to present the pet doesn't need to feed.
4. Play with the ball when I press button B, short anime of playing (+30 in wellbeing until wellbeing is equal to 120). If wellbeing is 120, a short anime to show the pet is tired.
5. Using the SysTick timer to countdown, every time the countdown is equal to 0, the health will -10 and wellbeing will -10.
6. When health is equal to 0, show an anime of hungry (voice of hungry if possible)
7. When wellbeing is equal to 0, show an anime of crying (voice of cry)
8. If there is no instruction for more than 5 seconds, the pet will play by itself. (a short anime)
9. (try) Using the sensor. The pet will kiss you (anime) when the finger is close to the microbit.
