.syntax unified
.global main
.global SysTick_Handler
.global GPIOTE_IRQHandler

@ GPIOTE Constants
.set GPIOTE_EVENTS_IN0, 0x40006100
.set GPIOTE_EVENTS_IN1, 0x40006104
.set GPIOTE_EVENTS_IN2, 0x40006108
.set GPIOTE_INTENSET, 0x40006304
.set GPIOTE_CONFIG0, 0x40006510
.set GPIOTE_CONFIG1, 0x40006514
.set GPIOTE_CONFIG2, 0x40006518

@ NVIC Constants
.set NVIC_ISER0, 0xE000E100

@ Priority
.set SHPR3, 0xE000ED20
.set NVIC_IPR1, 0xE000E404

@ Systick
.set ADR_SYST_CSR, 0xE000E010
.set ADR_SYST_RVR, 0xE000E014

.type main, %function
main:
  bl init_leds
  bl set_GPIOTE_CONFIG
  bl set_systick

stay:
  ldr r0, =health
  ldr r1, [r0]
  cmp r1, 0
  ble loop_hungry
  ldr r0, =wellbeing
  ldr r1, [r0]
  cmp r1, 0
  ble loop_sad
  bl draw_duck
  b stay
.size main, .-main

.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  push {r4-r12, lr}
  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r1, [r0]
  cmp r1, 1
  IT eq
  bleq button_A

  ldr r0, =GPIOTE_EVENTS_IN1
  ldr r1, [r0]
  cmp r1, 1
  IT eq
  bleq button_B

  ldr r0, =GPIOTE_EVENTS_IN2
  ldr r1, [r0]
  cmp r1, 1
  IT eq
  bleq sensor

  pop {r4-r12, lr}
  bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler

.type SysTick_Handler, %function
SysTick_Handler:
  push {r4-r12, lr}
  ldr r0, =health
  ldr r1, [r0]
  cmp r1, 0
  IT gt
  blgt minus
  str r1, [r0]
  ldr r0, =wellbeing
  ldr r1, [r0]
  cmp r1, 0
  IT gt
  blgt minus
  str r1, [r0]
  pop {r4-r12, lr}
  bx lr
.size SysTick_Handler, .-SysTick_Handler

minus:
  push {lr}
  subs r1, 1
  pop {lr}
  bx lr

button_A:
  push {lr}
  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r1, =0
  str r1, [r0]
  ldr r0, =health
  ldr r1, [r0]
  cmp r1, 800
  IT lt
  bllt draw_eat_apple
  ldr r0, =health
  ldr r1, [r0]
  cmp r1, 800
  IT ge
  blge draw_full
  pop {lr}
  bx lr

button_B:
  push {lr}
  ldr r0, =GPIOTE_EVENTS_IN1
  ldr r1, [r0]
  ldr r1, =0
  str r1, [r0]
  ldr r0, =wellbeing
  ldr r1, [r0]
  cmp r1, 800
  IT lt
  bllt play_ball
  ldr r0, =wellbeing
  ldr r1, [r0]
  cmp r1, 800
  IT ge
  blge draw_tired
  pop {lr}
  bx lr

sensor:
  push {lr}
  ldr r0, =GPIOTE_EVENTS_IN2
  ldr r1, =0
  str r1, [r0]
  bl draw_heart
  pop {lr}
  bx lr

play_ball:
  push {lr}
  bl draw_ball_up
  bl draw_ball_down
  pop {lr}
  bx lr

set_GPIOTE_CONFIG:
  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 0 << 13 | 1 << 16)
  str r1, [r0]

  ldr r0, =GPIOTE_CONFIG1
  ldr r1, =(1 | 23 << 8 | 0 << 13 | 1 << 16)
  str r1, [r0]

  ldr r0, =GPIOTE_CONFIG2
  ldr r1, =(1 | 4 << 8 | 1 << 13 | 2 << 16)
  str r1, [r0]

  ldr r0, =GPIOTE_INTENSET
  ldr r1, =0b111
  str r1, [r0]

  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6)
  str r1, [r0]

  ldr r0, =NVIC_IPR1
  ldr r1, =(1 << 21)
  str r1, [r0]
  bx lr

set_systick:
  ldr r0, =ADR_SYST_CSR
  ldr r1, =0b111
  str r1, [r0]

  ldr r0, =ADR_SYST_RVR
  ldr r1, =0x800000
  str r1, [r0]

  ldr r0, =SHPR3
  ldr r1, =(7 << 29)
  str r1, [r0]

  bx lr

loop_hungry:
  bl draw_hungry
  ldr r0, =health
  ldr r1, [r0]
  cmp r1, 0
  bgt stay
  b loop_hungry

loop_sad:
  bl draw_sad
  ldr r0, =wellbeing
  ldr r1, [r0]
  cmp r1, 0
  bgt stay
  b loop_sad

draw_picture:
  push {r0-r12, lr}
  ldr r4, =4
  ldr r5, =0
  ldr r9, =0x777
loop:
  bl turn_off
  cmp r5, 5
  beq repeat
  cmp r5, 0
  IT eq
  bleq row_1
  cmp r5, 1
  IT eq
  bleq row_2
  cmp r5, 2
  IT eq
  bleq row_3
  cmp r5, 3
  IT eq
  bleq row_4
  cmp r5, 4
  IT eq
  bleq row_5
  mul r6, r5, r4
  ldr r1, [r7, r6]
  cmp r1, 0b10000
  beq column_1
  cmp r1, 0b01000
  beq column_2
  cmp r1, 0b00100
  beq column_3
  cmp r1, 0b00010
  beq column_4
  cmp r1, 0b00001
  beq column_5
  cmp r1, 0b11000
  beq column_6
  cmp r1, 0b10100
  beq column_7
  cmp r1, 0b10010
  beq column_8
  cmp r1, 0b10001
  beq column_9
  cmp r1, 0b01100
  beq column_10
  cmp r1, 0b01010
  beq column_11
  cmp r1, 0b01001
  beq column_12
  cmp r1, 0b00110
  beq column_13
  cmp r1, 0b00101
  beq column_14
  cmp r1, 0b00011
  beq column_15
  cmp r1, 0b11100
  beq column_16
  cmp r1, 0b11010
  beq column_17
  cmp r1, 0b11001
  beq column_18
  cmp r1, 0b10110
  beq column_19
  cmp r1, 0b10101
  beq column_20
  cmp r1, 0b10011
  beq column_21
  cmp r1, 0b01110
  beq column_22
  cmp r1, 0b01101
  beq column_23
  cmp r1, 0b01011
  beq column_24
  cmp r1, 0b00111
  beq column_25
  cmp r1, 0b11110
  beq column_26
  cmp r1, 0b11101
  beq column_27
  cmp r1, 0b11011
  beq column_28
  cmp r1, 0b10111
  beq column_29
  cmp r1, 0b01111
  beq column_30
  cmp r1, 0b11111
  beq column_31
  add r5, 1
  b loop

repeat:
  cmp r9, 0
  bls exit
  ldr r5, =0
  subs r9, 1
  b loop

exit:
  pop {r0-r12, lr}
  bx lr

help_to_draw:
  push {r0-r12, lr}
  mov r10, 0
draw_loop:
  cmp r10, r4
  bge exit
  mov r5, 20
  add r7, r5
  bl draw_picture
  add r10, 1
  bl turn_off
  ldr r0, =0xffffffff
  bl delay
  b draw_loop


draw_duck:
  push {r0-r12, lr}
  mov r4, 2
  ldr r7, =duck
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr

draw_eat_apple:
  push {r0-r12, lr}
  ldr r0, =health
  ldr r1, [r0]
  adds r1, 80
  str r1, [r0]
  mov r4, 18
  ldr r7, =eat_apple
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr


draw_full:
  push {r0-r12, lr}
  mov r4, 31
  ldr r7, =full
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr

draw_hungry:
  push {r0-r12, lr}
  mov r4, 15
  ldr r7, =hungry
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr


draw_ball_up:
  push {r0-r12, lr}
  ldr r0, =wellbeing
  ldr r1, [r0]
  add r1, 50
  str r1, [r0]
  mov r4, 4
  ldr r7, =ball_up
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr

draw_ball_down:
  push {r0-r12, lr}
  mov r4, 5
  ldr r7, =ball_down
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr

draw_sad:
  push {r0-r12, lr}
  mov r4, 9
  ldr r7, =sad
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr

draw_tired:
  push {r0-r12, lr}
  mov r4, 35
  ldr r7, =tired
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr


draw_heart:
  push {r0-r12, lr}
  mov r4, 3
  ldr r7, =heart
  subs r7, 20
  bl help_to_draw
  pop {r0-r12, lr}
  bx lr


.type turn_off, %function
turn_off:
  push {r0, lr}
  mov r0, 0b11111
  bl write_column_pins
  mov r0, 0b00000
  bl write_row_pins
  pop {r0, lr}
  bx lr
.size turn_off, .-turn_off

row_1:
  push {r0, lr}
  mov r0, 0b00001
  bl write_row_pins
  pop {r0, lr}
  bx lr

row_2:
  push {r0, lr}
  mov r0, 0b00010
  bl write_row_pins
  pop {r0, lr}
  bx lr

row_3:
  push {r0, lr}
  mov r0, 0b00100
  bl write_row_pins
  pop {r0, lr}
  bx lr

row_4:
  push {r0, lr}
  mov r0, 0b01000
  bl write_row_pins
  pop {r0, lr}
  bx lr

row_5:
  push {r0, lr}
  mov r0, 0b10000
  bl write_row_pins
  pop {r0, lr}
  bx lr

column_1:
  push {r0}
  mov r0, 0b11110
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_2:
  push {r0}
  mov r0, 0b11101
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_3:
  push {r0}
  mov r0, 0b11011
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_4:
  push {r0}
  mov r0, 0b10111
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_5:
  push {r0}
  mov r0, 0b01111
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_6:
  push {r0}
  mov r0, 0b11100
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_7:
  push {r0}
  mov r0, 0b11010
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_8:
  push {r0}
  mov r0, 0b10110
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_9:
  push {r0}
  mov r0, 0b01110
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_10:
  push {r0}
  mov r0, 0b11001
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_11:
  push {r0}
  mov r0, 0b10101
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_12:
  push {r0}
  mov r0, 0b01101
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_13:
  push {r0}
  mov r0, 0b10011
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_14:
  push {r0}
  mov r0, 0b01011
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_15:
  push {r0}
  mov r0, 0b00111
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_16:
  push {r0}
  mov r0, 0b11000
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_17:
  push {r0}
  mov r0, 0b10100
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_18:
  push {r0}
  mov r0, 0b01100
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_19:
  push {r0}
  mov r0, 0b10010
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_20:
  push {r0}
  mov r0, 0b01010
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_21:
  push {r0}
  mov r0, 0b00110
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_22:
  push {r0}
  mov r0, 0b10001
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_23:
  push {r0}
  mov r0, 0b01001
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_24:
  push {r0}
  mov r0, 0b00101
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_25:
  push {r0}
  mov r0, 0b00011
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_26:
  push {r0}
  mov r0, 0b10000
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_27:
  push {r0}
  mov r0, 0b01000
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_28:
  push {r0}
  mov r0, 0b00100
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_29:
  push {r0}
  mov r0, 0b00010
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_30:
  push {r0}
  mov r0, 0b00001
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

column_31:
  push {r0}
  mov r0, 0b00000
  bl write_column_pins
  pop {r0}
  adds r5, 1
  b loop

.data
health:
  .word 500

wellbeing:
  .word 500


duck:
  .word 0b00000, 0b01110, 0b11011, 0b10001, 0b11111
  .word 0b00000, 0b01110, 0b10001, 0b10001, 0b11111


eat_apple:
  .word 0b00000, 0b00001, 0b00010, 0b00010, 0b00001 @apple
  .word 0b00000, 0b00011, 0b00101, 0b00100, 0b00011
  .word 0b00001, 0b00111, 0b01010, 0b01000, 0b00111
  .word 0b00010, 0b01110, 0b10101, 0b10001, 0b01110
  .word 0b00010, 0b01110, 0b10101, 0b10001, 0b01110
  .word 0b00100, 0b11100, 0b01010, 0b00010, 0b11100
  .word 0b01000, 0b11000, 0b10100, 0b00100, 0b11000
  .word 0b10001, 0b10000, 0b01000, 0b01000, 0b10001 @eat
  .word 0b00001, 0b00010, 0b10011, 0b10010, 0b00001
  .word 0b00111, 0b00010, 0b00001, 0b00010, 0b00111
  .word 0b00111, 0b01001, 0b01110, 0b01000, 0b00111
  .word 0b11110, 0b01011, 0b00101, 0b01001, 0b11110
  .word 0b01110, 0b10011, 0b11101, 0b10001, 0b01110
  .word 0b11100, 0b10110, 0b01010, 0b10010, 0b11100 @out of screen
  .word 0b11000, 0b01100, 0b10100, 0b00100, 0b11000
  .word 0b10000, 0b11000, 0b01000, 0b01000, 0b10000
  .word 0b00000, 0b10000, 0b10000, 0b10000, 0b00000
  .word 0b00000, 0b00000, 0b00000, 0b00000, 0b00000

full:
  .word 0b00001, 0b00000, 0b00000, 0b00000, 0b00001 @I
  .word 0b00011, 0b00001, 0b00001, 0b00001, 0b00011
  .word 0b00111, 0b00010, 0b00010, 0b00010, 0b00111
  .word 0b01110, 0b00100, 0b00100, 0b00100, 0b01110
  .word 0b11101, 0b01001, 0b01000, 0b01000, 0b11100 @'
  .word 0b11010, 0b10010, 0b10000, 0b10000, 0b11000
  .word 0b10101, 0b00101, 0b00001, 0b00001, 0b10001 @M
  .word 0b01010, 0b01011, 0b00010, 0b00010, 0b00010
  .word 0b10101, 0b10111, 0b00101, 0b00101, 0b00101
  .word 0b01010, 0b01110, 0b01010, 0b01010, 0b01010
  .word 0b10100, 0b11100, 0b10100, 0b10100, 0b10100
  .word 0b01001, 0b11001, 0b01001, 0b01001, 0b01001 @F
  .word 0b10011, 0b10010, 0b10011, 0b10010, 0b10010
  .word 0b00111, 0b00100, 0b00111, 0b00100, 0b00100
  .word 0b01110, 0b01000, 0b01110, 0b01000, 0b01000
  .word 0b11101, 0b10001, 0b11101, 0b10001, 0b10001 @U
  .word 0b11010, 0b00010, 0b11010, 0b00010, 0b00011
  .word 0b10101, 0b00101, 0b10101, 0b00101, 0b00111
  .word 0b01010, 0b01010, 0b01010, 0b01010, 0b01110
  .word 0b10101, 0b10101, 0b10101, 0b10101, 0b11101 @L
  .word 0b01010, 0b01010, 0b01010, 0b01010, 0b11011
  .word 0b10100, 0b10100, 0b10100, 0b10100, 0b10111
  .word 0b01000, 0b01000, 0b01000, 0b01000, 0b01110
  .word 0b10001, 0b10001, 0b10001, 0b10001, 0b11101 @L
  .word 0b00010, 0b00010, 0b00010, 0b00010, 0b11011
  .word 0b00100, 0b00100, 0b00100, 0b00100, 0b10111
  .word 0b01000, 0b01000, 0b01000, 0b01000, 0b01110
  .word 0b10000, 0b10000, 0b10000, 0b10000, 0b11100
  .word 0b00000, 0b00000, 0b00000, 0b00000, 0b11000
  .word 0b00000, 0b00000, 0b00000, 0b00000, 0b10000
  .word 0b00000, 0b00000, 0b00000, 0b00000, 0b00000

hungry:
  .word 0b01010, 0b01010, 0b01110, 0b01010, 0b01010 @H
  .word 0b01010, 0b01010, 0b01110, 0b01010, 0b01010 
  .word 0b01010, 0b01010, 0b01110, 0b01010, 0b01010 
  .word 0b01010, 0b01010, 0b01010, 0b01010, 0b01110 @U
  .word 0b01010, 0b01010, 0b01010, 0b01010, 0b01110 
  .word 0b01010, 0b01010, 0b01010, 0b01010, 0b01110 
  .word 0b01110, 0b01010, 0b01110, 0b00010, 0b01110 @G
  .word 0b01110, 0b01010, 0b01110, 0b00010, 0b01110 
  .word 0b01110, 0b01010, 0b01110, 0b00010, 0b01110
  .word 0b01010, 0b01100, 0b01000, 0b01000, 0b01000 @R
  .word 0b01010, 0b01100, 0b01000, 0b01000, 0b01000 
  .word 0b01010, 0b01100, 0b01000, 0b01000, 0b01000 
  .word 0b01010, 0b01010, 0b00100, 0b00100, 0b00100 @Y
  .word 0b01010, 0b01010, 0b00100, 0b00100, 0b00100 
  .word 0b01010, 0b01010, 0b00100, 0b00100, 0b00100 


ball_up:
  .word 0b01110, 0b11011, 0b10001, 0b10001, 0b01110
  .word 0b11011, 0b10001, 0b10001, 0b01110, 0b00000
  .word 0b10001, 0b10001, 0b01110, 0b00000, 0b00000
  .word 0b10001, 0b01110, 0b00000, 0b00000, 0b00000

ball_down:
  .word 0b10001, 0b01110, 0b00000, 0b00000, 0b00000
  .word 0b10001, 0b10001, 0b01110, 0b00000, 0b00000
  .word 0b11011, 0b10001, 0b10001, 0b01110, 0b00000
  .word 0b01110, 0b11011, 0b10001, 0b10001, 0b01110
  .word 0b01110, 0b11011, 0b10001, 0b10001, 0b01110

sad:
  .word 0b01110, 0b01000, 0b01110, 0b00010, 0b01110 @S
  .word 0b01110, 0b01000, 0b01110, 0b00010, 0b01110 
  .word 0b01110, 0b01000, 0b01110, 0b00010, 0b01110 
  .word 0b00100, 0b01010, 0b01110, 0b01010, 0b01010 @A
  .word 0b00100, 0b01010, 0b01110, 0b01010, 0b01010 
  .word 0b00100, 0b01010, 0b01110, 0b01010, 0b01010 
  .word 0b01100, 0b01010, 0b01010, 0b01010, 0b01100 @D
  .word 0b01100, 0b01010, 0b01010, 0b01010, 0b01100 
  .word 0b01100, 0b01010, 0b01010, 0b01010, 0b01100 

tired:
  .word 0b00001, 0b00000, 0b00000, 0b00000, 0b00001 @I
  .word 0b00011, 0b00001, 0b00001, 0b00001, 0b00011
  .word 0b00111, 0b00010, 0b00010, 0b00010, 0b00111
  .word 0b01110, 0b00100, 0b00100, 0b00100, 0b01110
  .word 0b11101, 0b01001, 0b01000, 0b01000, 0b11100 @'
  .word 0b11010, 0b10010, 0b10000, 0b10000, 0b11000
  .word 0b10101, 0b00101, 0b00001, 0b00001, 0b10001 @M
  .word 0b01010, 0b01011, 0b00010, 0b00010, 0b00010
  .word 0b10101, 0b10111, 0b00101, 0b00101, 0b00101
  .word 0b01010, 0b01110, 0b01010, 0b01010, 0b01010
  .word 0b10100, 0b11100, 0b10100, 0b10100, 0b10100
  .word 0b01001, 0b11000, 0b01000, 0b01000, 0b01000 @T
  .word 0b10011, 0b10001, 0b10001, 0b10001, 0b10001
  .word 0b00111, 0b00010, 0b00010, 0b00010, 0b00010
  .word 0b01110, 0b00100, 0b00100, 0b00100, 0b00100
  .word 0b11101, 0b01000, 0b01000, 0b01000, 0b01001 @I
  .word 0b11011, 0b10001, 0b10001, 0b10001, 0b10011
  .word 0b10111, 0b00010, 0b00010, 0b00010, 0b00111
  .word 0b01110, 0b00100, 0b00100, 0b00100, 0b01110
  .word 0b11101, 0b01001, 0b01001, 0b01001, 0b11101 @R
  .word 0b11011, 0b10010, 0b10011, 0b10011, 0b11010
  .word 0b10111, 0b00101, 0b00111, 0b00110, 0b10101
  .word 0b01110, 0b01010, 0b01110, 0b01100, 0b01010
  .word 0b11101, 0b10101, 0b11101, 0b11001, 0b10101 @E
  .word 0b11011, 0b01010, 0b11011, 0b10010, 0b01011
  .word 0b10111, 0b10100, 0b10111, 0b00100, 0b10111
  .word 0b01110, 0b01000, 0b01110, 0b01000, 0b01110
  .word 0b11101, 0b10001, 0b11101, 0b10001, 0b11101 @D
  .word 0b11011, 0b00010, 0b11010, 0b00010, 0b11011
  .word 0b10110, 0b00101, 0b10101, 0b00101, 0b10110
  .word 0b01100, 0b01010, 0b01010, 0b01010, 0b01100
  .word 0b11000, 0b10100, 0b10100, 0b10100, 0b11000
  .word 0b10000, 0b01000, 0b01000, 0b01000, 0b10000
  .word 0b00000, 0b10000, 0b10000, 0b10000, 0b00000
  .word 0b00000, 0b00000, 0b00000, 0b00000, 0b00000

heart:
  .word 0b00000, 0b00000, 0b00100, 0b00000, 0b00000
  .word 0b00000, 0b01010, 0b01110, 0b00100, 0b00000
  .word 0b01010, 0b10101, 0b10001, 0b01010, 0b00100