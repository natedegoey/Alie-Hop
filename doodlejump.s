#####################################################################
#
# CSC258H5S Fall 2020 Assembly Final Project
# University of Toronto, St. George
#
# Student: Nathan DeGoey, 1006314329
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Game Over
# 2. Player names
# 3. On Screen Notifications
# 4. Sound and Background Music
# 5. Scoreboard
# 6. Fancier Graphics (somewhat)
#
#
# Any additional information that the TA needs to know:
# - hope you enjoy my game!
#
#####################################################################
.data
		displayAddress: .word 0x10008000
		offsetDisplayAddress: .word 0x10008014
		lowerAddress: .word 0x10008c04
		offsetLowerAddress: .word 0x10008c18
		offsetLowerAddress2: .word 0x10008c30
		offsetLowerAddress3: .word 0x10008c48
		bufferAddress: .word 0x10008000 #fix for the flashiness
		bottomRightAddress: .word 0x10008ffc
		bottomBarrier: .word 31 #the bottom barrier of the display
		sky: .word 0xe6eff4
		platform: .word 0x3f1736
		doodler: .word 0xfa8072
		title: .word 0x4ee018
		letter: .word 0x0a1ba9
		doodler_XPos: .word 14 #the X position of the base of the doodler (should be 14)
		doodler_YPos: .word 28 #the Y position of the base of the doodler (should be 28)
		startPlat_X: .word 13 #(should be 13)
		startPlat_Y: .word 29 #start at the bottom of the display (should be 29)
		platOne_X: .space 4 #reserve space in memory for the X value of platform one
		platOne_Y: 23 #reserve space in memory for the Y value of platform one
		platTwo_X: .space 4
		platTwo_Y: 17
		platThree_X: .space 4
		platThree_Y: 11
		platFour_X: .space 4
		platFour_Y: 5
		maxJump: .word 10 #set the max height to 10
		jumpHeight: .word 0 #used to count where in the jump the doodler currently is
		maxPlatShift: .word 8 #set the max shift of the platforms to 6
		shiftHeight: .word 0 #used to count how much the platform as shifted so far
		current_pop_up: .word 0 #used to store the number containing the current pop up, which will be updated when a new 
					#platform is landed on and checked everytime the screen is looped.
		purple_colour: .word 0xb21bd0
		red_colour: .word 0xdd254f
		orange_colour: .word 0xff763b
		pop_up_colour: .word 0xb21bd0 #default is purple
		
		#values for the scoreboard
		ones_digit: .word 0 #set the digit to a starting value of 0
		tens_digit: .word 0 #set the digit to a starting value of 0
		
		note: .word 77 #idea: an array of notes that the loop goes through during gameplay. The notes are
		# a simple 8-bit type song. Values found in MIDI doc and Youtube video.
		notes: .space 96 
		notes_ind: .word 0 #curr index in the notes array. starts at 0. Will get incremented in the loop
		max_notes_ind: .word 96
		curr_note: .word 0
		#sound library
		E_note: .word 76#64
		F_note: .word 77#65
		G_note: .word 79#67
		A_note: .word 81#69
		
		#player name. Start the letters off by painting A (value 1).
		first_letter: .word 1
		second_letter: .word 1
		third_letter: .word 1
		fourth_letter: .word 1
		letter_count: .word 0 #the count of how many letters are currently counted
		
		
		#these are saved here for the reset
		orgdoodler_XPos: .word 14 #the X position of the base of the doodler (should be 14)
		orgdoodler_YPos: .word 28 #the Y position of the base of the doodler (should be 28)
		orgstartPlat_X: .word 13 #(should be 13)
		orgstartPlat_Y: .word 29 #start at the bottom of the display (should be 29)
		orgplatOne_X: .space 4 #reserve space in memory for the X value of platform one
		orgplatOne_Y: 23 #reserve space in memory for the Y value of platform one
		orgplatTwo_X: .space 4
		orgplatTwo_Y: 17
		orgplatThree_X: .space 4
		orgplatThree_Y: 11
		orgplatFour_X: .space 4
		orgplatFour_Y: 5
		
		
		
.text
main:
		jal PAINTWELCOME #paint the welcome screen when the system is booted up
		j check_s_input #immediately check for keyboard input to start the game
main2:		
		j check_s_inputAgain #if game over, then wait for s input again to keep playing
		
Exit:
		li $v0, 10 # terminate the program gracefully
		syscall

PAINTWELCOME:
		#paint the sky for the welcome screen
		lw $t0, displayAddress # $t0 stores the base address for display. PERSONAL CONVENTION...THIS WILL ALWAYS BE TRUE
		lw $t1, sky # $t1 stores the background colour code
		lw $t4, bottomRightAddress # $t4 stores the last address for display
		addi $sp, $sp, -4 #add space to the stack for storing $ra
		sw $ra, 0($sp) #push the value of $ra onto the stack
		jal SKY #jump to SKY and set a new $ra to return back here
		#draw the starting platform
		jal STORESTARTXY
		jal DRAWPLATFORM
		#draw the doodler
		lw $t3, doodler # $t3 stores the sprite colour code
		jal DRAWDOODLER
		jal PAINTWELCOMETEXT
		lw $ra, 0($sp) #Since $ra has been changed from the jump to all of the above functions, load the proper one back into $ra
		addi $sp, $sp, 4 #return the stack pointer to the start of the stack
		jr $ra #jump back to main
		
check_s_inputAgain:
		lw $t8, 0xffff0000 #store the keyboard register in t8
		beq $t8, 1, s_inputAgain #check if t8 is equal to 1. If it is, then branch to keyboard_input
		j check_s_inputAgain
			
check_s_input:
		lw $t8, 0xffff0000 #store the keyboard register in t8
		beq $t8, 1, s_input #check if t8 is equal to 1. If it is, then branch to keyboard_input
		j check_s_input
			
s_inputAgain:
		lw $t7, 0xffff0004
		beq $t7, 0x73, respond_to_sAgain #s
		j check_s_input #put this in a loop so that it waits for the proper keys to be pressed
		
s_input:
		lw $t7, 0xffff0004
		beq $t7, 0x73, respond_to_s #s
		j check_s_input #put this in a loop so that it waits for the proper keys to be pressed
		
respond_to_sAgain:	#start the game
		jal RESET #since this method happens when teh game is started again, reset everything and start again
		j SETUP #this may be unnecessary
		j LOOP	
		
respond_to_s:	#start the game
		jal get_player_name
		j SETUP #this may be unnecessary
		j LOOP	

keyboard_input:
		lw $t7, 0xffff0004
		beq $t7, 0x6a respond_to_j #j
		beq $t7, 0x6b, respond_to_k #k
		j LOOP #either j LOOP or jr $ra
		
respond_to_j:
		lw $a1, doodler_XPos #load the current y-pos of the doodler into $a1
		li $a0, 1
		beq $a1, $a0, SKIP #do not allow the doodler to cross the screen
		addi $a1, $a1, -1 #add 1 to the y-pos of the doodler into $a1
		sw $a1, doodler_XPos #update doodler_YPos with the updated YPos 
		j LOOP #not sure if this should be jr $ra or j LOOP

respond_to_k:
		lw $a1, doodler_XPos #load the current y-pos of the doodler into $a1
		li $a0, 29
		beq $a1, $a0, SKIP #do not allow the doodler to cross the screen
		addi $a1, $a1, 1 #add 1 to the y-pos of the doodler into $a1
		sw $a1, doodler_XPos #update doodler_YPos with the updated YPos 
		j LOOP #not sure if this should be jr $ra or j LOOP

SKIP:
		j LOOP #jump back to the loop if this method is reached
		
get_player_name:
		#a method that will check for keyboard input before starting the game to check for the player name
		#the name can be maximum 4 letters, and after the fourth letter is chosen, the game automatically starts
		#each letter will fill the specified index in memory for the player name.
		lw $t8, 0xffff0000 #store the keyboard register in t8
		beq $t8, 1, player_name_input #check if t8 is equal to 1. If it is, then branch to player_name_input
		j get_player_name #put this in a loop until all four letters are spelt out

player_name_input:
		lw $t7, 0xffff0004
		lw $t9, letter_count #t9 holds the current letter count
		#need a response to every lowercase letter of english alphabet
		beq $t7, 0x61, store_a
		beq $t7, 0x62, store_b
		beq $t7, 0x63, store_c
		beq $t7, 0x64, store_d
		beq $t7, 0x65, store_e
		beq $t7, 0x66, store_f
		beq $t7, 0x67, store_g
		beq $t7, 0x68, store_h
		beq $t7, 0x69, store_i
		beq $t7, 0x6a, store_j
		beq $t7, 0x6b, store_k
		beq $t7, 0x6c, store_l
		beq $t7, 0x6d, store_m
		beq $t7, 0x6e, store_n
		beq $t7, 0x6f, store_o
		beq $t7, 0x70, store_p
		beq $t7, 0x71, store_q
		beq $t7, 0x72, store_r
		beq $t7, 0x73, store_s
		beq $t7, 0x74, store_t
		beq $t7, 0x75, store_u
		beq $t7, 0x76, store_v
		beq $t7, 0x77, store_w
		beq $t7, 0x78, store_x
		beq $t7, 0x79, store_y
		beq $t7, 0x7a, store_z
		
store_a:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 1
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_b:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 2 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_c:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 3 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_d:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 4 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_e:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 5 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_f:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 6 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_g:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 7 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_h:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 8 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_i:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 9 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case	
store_j:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 10 #the 10th letter of the alphabet
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
		
store_k: 
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 11 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_l:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 12 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_m:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 13 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_n:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 14 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_o:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 15 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_p:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 16
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_q:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 17 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_r:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 18 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_s:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 19 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_t:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 20 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_u:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 21 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_v:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 22 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_w:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 23 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_x:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 24 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_y:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 25 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
store_z:
		#Check what value t9 holds (the letter count)
		addi $t6, $zero, 26 
		addi $t4, $zero, 0
		beq $t9, $t4, store_letter_one #0 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_two #1 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_three #2 case
		addi $t4, $t4, 1
		beq $t9, $t4, store_letter_four #3 case
		
store_letter_one:
		#t6 holds the current letter, so store that value in memory
		sw $t6, first_letter
		#update letter count
		addi $t9, $t9, 1
		sw $t9, letter_count
		j get_player_name #jumps back to get player name to await the next letter
store_letter_two:
		#t6 holds the current letter, so store that value in memory
		sw $t6, second_letter
		#update letter count
		addi $t9, $t9, 1
		sw $t9, letter_count
		j get_player_name #jumps back to get player name to await the next letter
store_letter_three:
		#t6 holds the current letter, so store that value in memory
		sw $t6, third_letter
		#update letter count
		addi $t9, $t9, 1
		sw $t9, letter_count
		j get_player_name #jumps back to get player name to await the next letter
store_letter_four:
		#t6 holds the current letter, so store that value in memory
		sw $t6, fourth_letter
		#got the fourth letter, jump back to the orginal return address
		jr $ra
		
RESET:
		#function used to reset vales in memory when the game is restarted.
		#do not forget to reset the jumpHeight and ShiftHeight to zero for a new game
		lw $a0, orgdoodler_XPos
		sw $a0, doodler_XPos
		
		lw $a0, orgdoodler_YPos
		sw $a0, doodler_YPos
		
		lw $a0, orgstartPlat_X
		sw $a0, startPlat_X
		
		lw $a0, orgstartPlat_Y
		sw $a0, startPlat_Y
		
		lw $a0, orgplatOne_X
		sw $a0, platOne_X
		
		lw $a0, orgplatOne_Y
		sw $a0, platOne_Y
		
		lw $a0, orgplatTwo_X
		sw $a0, platTwo_X
		
		lw $a0, orgplatTwo_Y
		sw $a0, platTwo_Y
		
		lw $a0, orgplatThree_X
		sw $a0, platThree_X
		
		lw $a0, orgplatThree_Y
		sw $a0, platThree_Y
		
		lw $a0, orgplatFour_X
		sw $a0, platFour_X
		
		lw $a0, orgplatFour_Y
		sw $a0, platFour_Y
		
		#reset jumpHeight and shiftHeight
		addi $a0, $zero, 0
		sw $a0, jumpHeight
		sw $a0, shiftHeight
		#reset scoreboard
		sw $a0, ones_digit
		sw $a0, tens_digit
		#reset current_pop_up to 0 so that there is not a pop up right away
		sw $a0, current_pop_up
		jr $ra
		
		

		
SETUP:
		#SOME COMMENTS, THERE IS NO NEED TO PAINT HERE
		#set the necessary registers for the call to SKY
		lw $t0, displayAddress # $t0 stores the base address for display. PERSONAL CONVENTION...THIS WILL ALWAYS BE TRUE
		#lw $t1, sky # $t1 stores the background colour code
		#lw $t4, bottomRightAddress # $t4 stores the last address for display
		#jal SKY #jump to SKY and set $ra
		#set the necessary registers for the call to DRAWPLATFORM
		#lw $t2, platform # $t2 stores the platform colour code https://www.color-hex.com/color/621514
		jal STOREXY #randomly generate an X and Y value and store them in the stack to be used in DRAWPLATFORM
		addi $t9, $zero, 0 #the index $t9 is initialized to 0
		#store the X in memory
		sw $a0,platOne_X($t9) #a0 contains the X value (see STOREXY)
		lw $a1, platOne_Y #set a1 to the predetermined Y value that is already stored in memory
		#jal DRAWPLATFORM #jump to DRAWPLATFORM and set $ra
		jal STOREXY
		#store the X in memory
		sw $a0,platTwo_X($t9)
		lw $a1, platTwo_Y
		#jal DRAWPLATFORM
		jal STOREXY
		#store the X in memory
		sw $a0,platThree_X($t9)
		lw $a1, platThree_Y
		#jal DRAWPLATFORM
		jal STOREXY
		#store the X in memory
		sw $a0,platFour_X($t9)
		lw $a1, platFour_Y
		#jal DRAWPLATFORM
		#draw the starting platform
		jal STORESTARTXY
		#jal DRAWPLATFORM
		#draw the doodler
		#lw $t3, doodler # $t3 stores the sprite colour code
		#jal DRAWDOODLER
		
		#set up the notes array. Remember, the notes are just values between 0 and 127
		#load the proper note into a0
		#store the contents of a0 into the notes array at index t9 (starts at 0)
		#increment t9 to go to the next index of the notes array
		#repeat with a new note, until notes array is filled
		lw $a0, E_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, E_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, E_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		###
		lw $a0, F_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, F_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, F_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, F_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		###
		lw $a0, G_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, G_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, G_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, G_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		###
		lw $a0, A_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, A_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, A_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, A_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		###
		lw $a0, G_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, G_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, G_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, G_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		###
		lw $a0, F_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, F_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, F_note
		sw $a0, notes($t9)
		addi $t9, $t9, 4
		lw $a0, F_note
		sw $a0, notes($t9)
		###
		
		j LOOP #once setup is finished, jump to the main loop
		
reset_notes_ind:
		#a function to reset the notes index
		#t9 should have the notes index at this point
		addi $t9, $zero, 0 #reset t9 to 0
		sw $t9, notes_ind #use t9 to reset the notes_ind to 0
		j LOOP #jump back to the main loop
LOOP: 
		#start with a sleep, cause it needs its rest
		li $v0, 32
		li $a0, 75
		syscall
		
		jal CHECKFAIL #check for failure right at the beginning so as not to waste a loop runtime
		
		#FUNCTION FOR PLAYING SOUND, CUT IT OUT FOR NOW BECAUSE IT WAS ANNOYING
		#playsound THIS ACTUALLY WORKS, NOW JUST FIGURE OUT A WAY TO SLOW THE SOUND DOWN WHILE MAINTAINING A PLAYABLE SPEED
		#lw $t9, notes_ind
		#lw $t8, max_notes_ind
		#beq $t9, $t8, reset_notes_ind #reset the notes_ind and jump back to the loop
		#if not equal, this means that the notes_ind is still a valid index in the notes array
		#lw $t7, notes($t9)
		#sw $t7, curr_note
		#addi $t9, $t9, 4 #update notes ind
		#sw $t9, notes_ind
		#everything should be set up, so now load the sound into a0 and play the sound
		#li $v0, 31
		#lw $a0, curr_note
		#li $a1, -1 #time in miliseconds (negative values mean 1 second)
		#li $a2, 80 #strings 81 - synth
		#li $a3, 50 #volume
		#syscall #play the note
		
		#check for keyboard input
		lw $t8, 0xffff0000 #store the keyboard register in t8
		beq $t8, 1, keyboard_input #check if t8 is equal to 1. If it is, then branch to keyboard_input
		#update the location of all platforms and other objects
		
		#redraw the screen
		#set the necessary registers for the call to SKY
		lw $t0, displayAddress # $t0 stores the base address for display. PERSONAL CONVENTION...THIS WILL ALWAYS BE TRUE
		lw $t1, sky # $t1 stores the background colour code
		lw $t4, bottomRightAddress # $t4 stores the last address for display
		jal SKY #jump to SKY and set $ra
		jal DRAWSCORETENS #draw the current score of the tens digit and return
		lw $t0, offsetDisplayAddress
		jal DRAWSCOREONES #draw the current score of the ones digit and return
		lw $t0, displayAddress
		#draw the current pop-up
		jal DRAWPOPUP
		#set the necessary registers for the call to DRAWPLATFORM
		lw $t2, platform # $t2 stores the platform colour code https://www.color-hex.com/color/621514
		lw $t4, platOne_X #load the value of platOne_X into $t4
		lw $t5, platOne_Y #load the value of platOne_Y into $t5
		addi $sp, $sp, -8 #create room in the stack for the X value
		sw $t4, 4($sp) #store the X-value in the stack
		sw $t5, 0($sp) #store the Y-value in the stack
		jal DRAWPLATFORM #jump to DRAWPLATFORM and set $ra
		lw $t4, platTwo_X #load the value of platOne_X into $t4
		lw $t5, platTwo_Y #load the value of platOne_Y into $t5
		addi $sp, $sp, -8 #create room in the stack for the X value
		sw $t4, 4($sp) #store the X-value in the stack
		sw $t5, 0($sp) #store the Y-value in the stack
		jal DRAWPLATFORM
		lw $t4, platThree_X #load the value of platOne_X into $t4
		lw $t5, platThree_Y #load the value of platOne_Y into $t5
		addi $sp, $sp, -8 #create room in the stack for the X value
		sw $t4, 4($sp) #store the X-value in the stack
		sw $t5, 0($sp) #store the Y-value in the stack
		jal DRAWPLATFORM
		lw $t4, platFour_X #load the value of platOne_X into $t4
		lw $t5, platFour_Y #load the value of platOne_Y into $t5
		addi $sp, $sp, -8 #create room in the stack for the X value
		sw $t4, 4($sp) #store the X-value in the stack
		sw $t5, 0($sp) #store the Y-value in the stack
		jal DRAWPLATFORM
		jal STORESTARTXY
		jal DRAWPLATFORM
		#update the position of the doodler
		lw $t3, doodler # $t3 stores the sprite colour code
		jal DRAWDOODLER #important to draw the doodler before everything
		lw $a0, jumpHeight #set $a0 to jumpHeight
		lw $a1, maxJump #set a1 to maxJump
		#first, check if the jumpHeight is at its max
		beq $a0, $a1, RESETJUMPHEIGHT #if these are equal, reset the jumpHeight and come back to the loop.
		bgt $a0, $zero, UPDATEJUMP #note that if a0 is gt 0, that means we are in a jumping phase, so then update the jump
		#note that the code will only come here if we are not in a "jump state". This means the doodler should be falling and checking for jumps
		jal DOODLERFALL
		jal DRAWDOODLER #this kinda gives it a "fast moving while falling vibe"
		#check all of the jump conditions to see if the sprite is on a platform
		jal CHECKJUMPSTART

		#go back to step 1
		j LOOP #jump back to the beginning of the loop to create it infinitely

		
UPDATEJUMP:	#update the jump height and go back to the loop
		lw $a0, jumpHeight
		addi $a0, $a0, 1
		sw $a0, jumpHeight
		#update the doodlers y position by 1
		lw $a1, doodler_YPos #load the current y-pos of the doodler into $a1
		addi $a1, $a1, -1 #minus 1 to the y-pos of the doodler into $a1
		sw $a1, doodler_YPos #update doodler_YPos with the updated YPos
		#should check here that the shiftHeight does not equal maxPlatShift
		lw $t4, maxPlatShift
		lw $t5, shiftHeight
		beq $t4, $t5, SKIP #if the shiftHieght equals the maxPlatShift, DO NOT UPDATE, JUST GO BACK TO THE LOOP
		#if we made it here, we can update the shift height for this iteration
		addi $t5, $t5, 1 #add one to the shift height here
		sw $t5, shiftHeight #store the updated shiftHeight back in memory
		j UPDATEPLATFORMS
		j LOOP
		
UPDATEPLATFORMS:
		#each platform is "lowered" on the screen in this format:
		#load the current_Y value into a1
		#increment a1 by to lower it by 1 unit
		#store the updated value back into the Y value of the platform
		lw $a2, bottomBarrier
		#for each platform position Y position, check if it is greater than the bottomBarrier, and if it is, repaint it at the top with a new X-coor
		#first, check if any of the platforms need to be redrawn, in wihc case, just redraw that platform in this iteration and do not update the rest
		#this hsould fix the issue that they new platforms are "falling behind" in the program
		lw $a1, platFour_Y
		bgt $a1, $a2, DRAWNEWPLATFORMFOUR
		lw $a1, platThree_Y
		bgt $a1, $a2, DRAWNEWPLATFORMTHREE
		lw $a1, platTwo_Y
		bgt $a1, $a2, DRAWNEWPLATFORMTWO
		lw $a1, platOne_Y
		bgt $a1, $a2, DRAWNEWPLATFORMONE
		lw $a1, startPlat_Y
		bgt $a1, $a2, DRAWNEWPLATFORMSTART
		#if we have gotten here, none of them needed to be redrawn in this iteration, so update the poritions of all of them
		#note that this ideally only occurs mid-jump
		#update the fourth platform
		lw $a1, platFour_Y
		addi $a1, $a1, 1
		sw, $a1, platFour_Y
		#update the third platform
		lw $a1, platThree_Y 
		addi $a1, $a1, 1
		sw, $a1, platThree_Y
		#update the second platform 
		lw $a1, platTwo_Y 
		addi $a1, $a1, 1
		sw, $a1, platTwo_Y 
		#update the first platform
		lw $a1, platOne_Y 
		addi $a1, $a1, 1
		sw, $a1, platOne_Y 
		#update the starting platform
		lw $a1, startPlat_Y 
		addi $a1, $a1, 1
		sw $a1, startPlat_Y
		
		j LOOP #update the platforms then jump back to the loop
		
DRAWNEWPLATFORMFOUR:
		#load a new X and Y value into stack so that the new platform is drawn correctly
		#When this method is called, a1 refers to the platforms Y position.
		addi $a1, $a1, -32 #subtract enough from the platform that it appears to be spawning from the top of the display
		sw $a1, platFour_Y
		jal GENERATERANDOMXVALUE
		#now, a0 refers to the random x value
		sw $a0, platFour_X # store the new random X in memory
		j LOOP

DRAWNEWPLATFORMTHREE:
		#load a new X and Y value into stack so that the new platform is drawn correctly
		#When this method is called, a1 refers to the platforms Y position.
		addi $a1, $a1, -32 #subtract enough from the platform that it appears to be spawning from the top of the display
		sw $a1, platThree_Y
		jal GENERATERANDOMXVALUE
		#now, a0 refers to the random x value
		sw $a0, platThree_X # store the new random X in memory
		j LOOP
		
DRAWNEWPLATFORMTWO:
		#load a new X and Y value into stack so that the new platform is drawn correctly
		#When this method is called, a1 refers to the platforms Y position.
		addi $a1, $a1, -32 #subtract enough from the platform that it appears to be spawning from the top of the display
		sw $a1, platTwo_Y
		jal GENERATERANDOMXVALUE
		#now, a0 refers to the random x value
		sw $a0, platTwo_X # store the new random X in memory
		j LOOP
		
DRAWNEWPLATFORMONE:
		#load a new X and Y value into stack so that the new platform is drawn correctly
		#When this method is called, a1 refers to the platforms Y position.
		addi $a1, $a1, -32 #subtract enough from the platform that it appears to be spawning from the top of the display
		sw $a1, platOne_Y 
		jal GENERATERANDOMXVALUE
		#now, a0 refers to the random x value
		sw $a0, platOne_X # store the new random X in memory
		j LOOP
		
DRAWNEWPLATFORMSTART:
		#load a new X and Y value into stack so that the new platform is drawn correctly
		#When this method is called, a1 refers to the platforms Y position.
		addi $a1, $a1, -32 #subtract enough from the platform that it appears to be spawning from the top of the display
		sw $a1, startPlat_Y 
		jal GENERATERANDOMXVALUE
		#now, a0 refers to the random x value
		sw $a0, startPlat_X # store the new random X in memory
		j LOOP

GENERATERANDOMXVALUE:
		li $v0, 42
		li $a0, 1 #x-value
		li $a1, 25 #the maximum number will be 29. This will set the random x-coor of the platform.
		syscall
		jr $ra
		
		
CHECKJUMPSTART:	#Now that we are here, check if the Doodler's X_Pos is in the range of the starting platform
		lw $a0, doodler_YPos #load the doodler's Y pos into a0
		lw $a1, startPlat_Y #load the starting platforms Y pos into a1
		bne $a0, $a1, CHECKJUMPONE #check if the doodler's Y pos is the same as the starting platform's Y pos. if not, check for the next platform
		lw $a2, doodler_XPos
		lw $a3, startPlat_X
		beq $a2, $a3, DOODLERJUMP # checks if the X_pos of the doodler aligns with the range of the platform
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		j LOOP #we've concluded that the X values don't align, so jump to LOOP
		
CHECKJUMPONE:	#Now that we are here, check if the Doodler's X_Pos is in the range of the starting platform
		lw $a0, doodler_YPos #load the doodler's Y pos into a0
		lw $a1, platOne_Y #load the platforms Y pos into a1
		bne $a0, $a1, CHECKJUMPTWO #check if the doodler's Y pos is the same as the starting platform's Y pos. if not, check for the next platform
		lw $a2, doodler_XPos
		lw $a3, platOne_X
		beq $a2, $a3, DOODLERJUMP # checks if the X_pos of the doodler aligns with the range of the platform
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		j LOOP #we've concluded that the X values don't align, so jump to LOOP
		
CHECKJUMPTWO:	#Now that we are here, check if the Doodler's X_Pos is in the range of the starting platform
		lw $a0, doodler_YPos #load the doodler's Y pos into a0
		lw $a1, platTwo_Y #load the platforms Y pos into a1
		bne $a0, $a1, CHECKJUMPTHREE #check if the doodler's Y pos is the same as the starting platform's Y pos. if not, check for the next platform
		lw $a2, doodler_XPos
		lw $a3, platTwo_X
		beq $a2, $a3, DOODLERJUMP # checks if the X_pos of the doodler aligns with the range of the platform
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		j LOOP #we've concluded that the X values don't align, so jump to LOOP

CHECKJUMPTHREE:	#Now that we are here, check if the Doodler's X_Pos is in the range of the starting platform
		lw $a0, doodler_YPos #load the doodler's Y pos into a0
		lw $a1, platThree_Y #load the platforms Y pos into a1
		bne $a0, $a1, CHECKJUMPFOUR #check if the doodler's Y pos is the same as the starting platform's Y pos. if not, check for the next platform
		lw $a2, doodler_XPos
		lw $a3, platThree_X
		beq $a2, $a3, DOODLERJUMP # checks if the X_pos of the doodler aligns with the range of the platform
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		j LOOP #we've concluded that the X values don't align, so jump to LOOP
		
CHECKJUMPFOUR:	#Now that we are here, check if the Doodler's X_Pos is in the range of the starting platform
		lw $a0, doodler_YPos #load the doodler's Y pos into a0
		lw $a1, platFour_Y #load the platforms Y pos into a1
		bne $a0, $a1, LOOP #check if the doodler's Y pos is the same as the starting platform's Y pos. if not, go back to LOOP
		lw $a2, doodler_XPos
		lw $a3, platFour_X
		beq $a2, $a3, DOODLERJUMP # checks if the X_pos of the doodler aligns with the range of the platform
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		add $a3, $a3, 1
		beq $a2, $a3, DOODLERJUMP
		j LOOP #we've concluded that the X values don't align, so jump to LOOP
		
DOODLERJUMP: 	
		lw $a3, jumpHeight #a3 stores the jump height (a counter)
		addi $a3, $a3, 1 #add 1 to the counter jumpHeight, since the doodler should have risen by 1 unit
		sw $a3, jumpHeight #store the updated jumpHeight back in memory
		lw $a0, doodler_YPos #load the current y-pos of the doodler into $a1
		addi $a0, $a0, -1 #minus 1 to the y-pos of the doodler into $a1
		sw $a0, doodler_YPos #update doodler_YPos with the updated YPos 
		#play sound
		li $v0, 31 #tells us we want to make a sound
		lw $a0, note #note in memory. since it is in memory, you may be able to change this.
		li $a1, 100 #negative values mean 1 second. positive is measures in miliseconds
		li $a2, 81 #midi patch
		li $a3, 75 #volume
		syscall #play the sound
		
		jal UPDATESCORE #update the score board and return
		jal GenerateRandomPopUp #since a new platform has been hit, store a new rando popup number in current_pop_up
		j LOOP #go back to the main loop and try again
		
RESETJUMPHEIGHT:
		sw $zero, jumpHeight #reset the jump height using the zero register
		sw $zero, shiftHeight #reset the shiftHeight so that the platforms will be able to shift again
		j LOOP #after resetting the jump height, go back to the loop

DOODLERFALL:	
		lw $a1, doodler_YPos #load the current y-pos of the doodler into $a1
		addi $a1, $a1, 1 #add 1 to the y-pos of the doodler into $a1
		sw $a1, doodler_YPos #update doodler_YPos with the updated YPos 
		jr $ra #go back to the loop
		
		
SKY:		
		beq $t0, $t4, whileExit 
		sw $t1, 0($t0) # paint the current address the colour stored in $t1
		addi $t0, $t0, 4 # add 4 to the current address
		j SKY
		
whileExit:
		#all but the last square are painted, so paint that square
		sw $t1, 0($t0)
		lw $t0, displayAddress #reset t0 to the starting address
		jr $ra
		
DRAWPLATFORM:
		lw $a1, 0($sp) #get the y value from the stack and store it in a1
		addi $sp, $sp, 4
		lw $a0, 0($sp) #get the x value from the stack and store it in a0
		addi $sp, $sp, 4
		sll $a1, $a1, 7 #multiply the y-value by 128 
		add $a1, $a1, $t0 #Make sure the y-value is in the range of the display
		sll $a0, $a0, 2 #Multiply by 4 in order to ensure that the address is a multiple of 4
		add $a0, $a0, $a1 #add the random number in $a2 with the proper y value so that it is aligned in the proper row
		sw $t2, 0($a0) #paint the address in $a0 and the next 4 units the platform colour
		sw $t2, 4($a0)
		sw $t2, 8($a0)
		sw $t2, 12($a0)
		
		jr $ra #jump back to the caller
		
DRAWDOODLER:
		lw $a1, doodler_YPos #get the y value from memory and store it in a1
		lw $a0, doodler_XPos #get the x value from memory and store it in a0
		sll $a1, $a1, 7 #multiply the y-value by 128 
		add $a1, $a1, $t0 #Make sure the y-value is in the range of the display
		sll $a0, $a0, 2 #Multiply by 4 in order to ensure that the address is a multiple of 4
		add $a0, $a0, $a1 #add the random number in $a2 with the proper y value so that it is aligned in the proper row
		#Now, draw the doodler based on the base position
		sw $t3, 0($a0) #a0 holds the base of the sprite
		sw $t3, 4($a0)
		sw $t3, -132($a0)
		sw $t3, -120($a0)
		sw $t3, -128($a0)
		sw $t3, -124($a0)
		sw $t3, -256($a0)
		sw $t3, -252($a0)
		sw $t3, -388($a0)
		sw $t3, -376($a0)
		
		jr $ra
		

STOREXY:
		#The next few lines store a random number in $a0 to get the x-value and store it in the sp
		li $v0, 42
		li $a0, 0 #x-value
		li $a1, 29 #the maximum number will be 30. This will set the random x-coor of the platform.
		syscall
		addi $sp, $sp, -4 #Move stack pointer down one word for the X
		sw $a0, 0($sp) #Push the x-value onto the stack
		jr $ra
STORESTARTXY:
		lw $a1, startPlat_Y
		lw $a0, startPlat_X
		addi $sp, $sp, -8 #Move stack pointer down two words (for both the x and y values)
		sw $a0, 4($sp) #Push the x-value onto the stack
		sw $a1, 0($sp) #push the y-value onto the stack
		
		jr $ra
		
UPDATESCORE: 
		# a function for displaying the score
		#first, check the values of the ones and tens digit (max 99)
		lw $a0, ones_digit
		lw $a1, tens_digit
		addi $a2, $zero, 9 #set register a2 to a value of 9 (past the maximum value of a digit)
		beq $a0, $a2, reset_ones_and_up_tens
		#if not, then the ones_digit has not yet reached its maximum, so update it ones_digit by 1
		addi $a0, $a0, 1
		sw $a0, ones_digit
		
		jr $ra #return to DOODLERJUMP
		
DRAWSCOREONES:
		# a function to draw the current score
		#lw $t0, offsetDisplayAddress
		lw $a0, ones_digit
		addi $a3, $zero, 0 #a3 starts at 0
		beq $a0, $a3, draw_zero #check the ones_digit
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_one
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_two
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_three
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_four
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_five
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_six
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_seven
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_eight
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_nine #if we get here and it hasn't drawn yet, then something is wrong
		
DRAWSCORETENS:
		# a function to draw the current score
		lw $a0, tens_digit 
		#lw $t0, displayAddress
		addi $a3, $zero, 0 #a3 starts at 0
		beq $a0, $a3, draw_zero #check the ones_digit
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_one
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_two
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_three
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_four
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_five
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_six
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_seven
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_eight
		addi, $a3, $a3, 1
		beq $a0, $a3, draw_nine #if we get here and it hasn't drawn yet, then something is wrong

draw_zero:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 224($t0)
		sw $t3, 228($t0)
		sw $t3, 348($t0)
		sw $t3, 476($t0)
		sw $t3, 604($t0)
		sw $t3, 732($t0)
		sw $t3, 736($t0)
		sw $t3, 740($t0)
		sw $t3, 356($t0)
		sw $t3, 484($t0)
		sw $t3, 612($t0)
		jr $ra #this will be the loop call of DRAWSCORE
draw_one:
		lw $t3, title
		sw $t3, 228($t0)
		sw $t3, 356($t0)
		sw $t3, 484($t0)
		sw $t3, 612($t0) #right line
		sw $t3, 740($t0)
		jr $ra #this will be the loop call of DRAWSCORE
draw_two:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 224($t0)
		sw $t3, 228($t0) #top line
		sw $t3, 476($t0)
		sw $t3, 604($t0)
		sw $t3, 732($t0) #left side
		sw $t3, 736($t0)
		sw $t3, 740($t0) #bottom line
		sw $t3, 356($t0)
		sw $t3, 480($t0) #right line
		sw $t3, 484($t0) #middle bit
		jr $ra #this will be the loop call of DRAWSCORE
draw_three:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 224($t0)
		sw $t3, 228($t0) #top line
		sw $t3, 476($t0)
		sw $t3, 732($t0) #left side
		sw $t3, 736($t0)
		sw $t3, 740($t0) #bottom line
		sw $t3, 356($t0)
		sw $t3, 480($t0)
		sw $t3, 612($t0) #right line
		sw $t3, 484($t0) #middle bit
		jr $ra #this will be the loop call of DRAWSCORE
draw_four:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 228($t0) #top line
		sw $t3, 348($t0)
		sw $t3, 476($t0)#left side
		sw $t3, 740($t0) #bottom line
		sw $t3, 356($t0)
		sw $t3, 480($t0)
		sw $t3, 612($t0) #right line
		sw $t3, 484($t0) #middle bit
		jr $ra #this will be the loop call of DRAWSCORE
draw_five:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 224($t0)
		sw $t3, 228($t0) #top line
		sw $t3, 348($t0)
		sw $t3, 476($t0)
		sw $t3, 732($t0) #left side
		sw $t3, 736($t0)
		sw $t3, 740($t0) #bottom line
		sw $t3, 480($t0)
		sw $t3, 612($t0) #right line
		sw $t3, 484($t0) #middle bit
		jr $ra #this will be the loop call of DRAWSCORE
draw_six:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 224($t0)
		sw $t3, 228($t0) #top line
		sw $t3, 348($t0)
		sw $t3, 476($t0)
		sw $t3, 604($t0)
		sw $t3, 732($t0) #left side
		sw $t3, 736($t0)
		sw $t3, 740($t0) #bottom line
		sw $t3, 480($t0)
		sw $t3, 612($t0) #right line
		sw $t3, 484($t0) #middle bit
		jr $ra #this will be the loop call of DRAWSCORE
draw_seven:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 224($t0)
		sw $t3, 228($t0) #top line
		sw $t3, 356($t0)
		sw $t3, 484($t0)
		sw $t3, 612($t0) #right line
		sw $t3, 740($t0)
		jr $ra #this will be the loop call of DRAWSCORE
draw_eight:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 224($t0)
		sw $t3, 228($t0) #top line
		sw $t3, 348($t0)
		sw $t3, 476($t0)
		sw $t3, 604($t0)
		sw $t3, 732($t0) #left side
		sw $t3, 736($t0)
		sw $t3, 740($t0) #bottom line
		sw $t3, 356($t0)
		sw $t3, 480($t0)
		sw $t3, 612($t0) #right line
		sw $t3, 484($t0) #middle bit
		jr $ra #this will be the loop call of DRAWSCORE
draw_nine:
		lw $t3, title
		sw $t3, 220($t0) #t0 will hold the display address if this is a call from 10's, and offsetDisplayAddress if the call is from 1's.
		sw $t3, 224($t0)
		sw $t3, 228($t0) #top line
		sw $t3, 348($t0)
		sw $t3, 476($t0)
		sw $t3, 732($t0) #left side
		sw $t3, 736($t0)
		sw $t3, 740($t0) #bottom line
		sw $t3, 356($t0)
		sw $t3, 480($t0)
		sw $t3, 612($t0) #right line
		sw $t3, 484($t0) #middle bit
		jr $ra #this will be the loop call of DRAWSCORE

		
reset_ones_and_up_tens:
		# a helper function to reset a digit in a score board from 9 to 0. currently just resets the ones_digit
		#a0 has the value of the ones digit, a1 has the value of the 10's digit
		addi $a0, $zero, 0
		sw $a0, ones_digit
		#update 10's
		addi $a1, $a1, 1
		sw $a1, tens_digit
		jal DRAWSCOREONES
		jal DRAWSCORETENS 
		j LOOP #return back to the address established by the call to UPDATESCORE
		
DRAWGAMEOVER:
		lw $t3, doodler # $t3 stores the sprite colour code
		sw $t3, 532($t0) #notice t0 stores the displayAddress (from the Caller GAMEOVER)
		sw $t3, 528($t0)
		sw $t3, 652($t0)
		sw $t3, 780($t0)
		sw $t3, 908($t0)
		sw $t3, 1040($t0)
		sw $t3, 1044($t0)
		sw $t3, 920($t0)
		sw $t3, 788($t0)
		sw $t3, 792($t0)
		sw $t3, 552($t0)
		sw $t3, 556($t0)
		sw $t3, 576($t0)
		sw $t3, 584($t0)
		sw $t3, 600($t0)
		sw $t3, 604($t0)
		sw $t3, 608($t0)
		sw $t3, 612($t0)
		sw $t3, 676($t0)
		sw $t3, 688($t0)
		sw $t3, 700($t0)
		sw $t3, 708($t0)
		sw $t3, 716($t0)
		sw $t3, 728($t0)
		sw $t3, 804($t0)
		sw $t3, 808($t0)
		sw $t3, 812($t0)
		sw $t3, 816($t0)
		sw $t3, 828($t0)
		sw $t3, 844($t0)
		sw $t3, 856($t0)
		sw $t3, 860($t0)
		sw $t3, 864($t0)
		sw $t3, 932($t0)
		sw $t3, 944($t0)
		sw $t3, 956($t0)
		sw $t3, 972($t0)
		sw $t3, 984($t0)
		sw $t3, 1060($t0)
		sw $t3, 1072($t0)
		sw $t3, 1084($t0)
		sw $t3, 1100($t0)
		sw $t3, 1112($t0)
		sw $t3, 1116($t0)
		sw $t3, 1120($t0)
		sw $t3, 1124($t0)
		sw $t3, 1424($t0) #Start of "Over"
		sw $t3, 1428($t0)
		sw $t3, 1444($t0)
		sw $t3, 1460($t0)
		sw $t3, 1472($t0)
		sw $t3, 1476($t0)
		sw $t3, 1480($t0)
		sw $t3, 1484($t0)
		sw $t3, 1496($t0)
		sw $t3, 1500($t0)
		sw $t3, 1504($t0)
		sw $t3, 1508($t0)
		sw $t3, 1548($t0)
		sw $t3, 1676($t0)
		sw $t3, 1804($t0)
		sw $t3, 1936($t0)
		sw $t3, 1560($t0)
		sw $t3, 1572($t0)
		sw $t3, 1588($t0)
		sw $t3, 1600($t0)
		sw $t3, 1624($t0)
		sw $t3, 1636($t0)
		sw $t3, 1688($t0)
		sw $t3, 1700($t0)
		sw $t3, 1716($t0)
		sw $t3, 1728($t0)
		sw $t3, 1732($t0)
		sw $t3, 1736($t0)
		sw $t3, 1752($t0)
		sw $t3, 1756($t0)
		sw $t3, 1760($t0)
		sw $t3, 1816($t0)
		sw $t3, 1832($t0)
		sw $t3, 1840($t0)
		sw $t3, 1856($t0)
		sw $t3, 1880($t0)
		sw $t3, 1888($t0)
		sw $t3, 1940($t0)
		sw $t3, 1964($t0)
		sw $t3, 1984($t0)
		sw $t3, 1988($t0)
		sw $t3, 1992($t0)
		sw $t3, 1996($t0)
		sw $t3, 2008($t0)
		sw $t3, 2020($t0)
		
		jr $ra #go back to GAMEOVER once everything is drawn

PAINTSTART: 
		#t2 is the argument colour for this method
		#t0 stores the display address, so build off of that
		sw $t2, 2700($t0)#s
		sw $t2, 2704($t0)
		sw $t2, 2576($t0)
		sw $t2, 2444($t0)
		sw $t2, 2316($t0)
		sw $t2, 2320($t0)
		sw $t2, 2456($t0)#dash
		sw $t2, 2460($t0)
		sw $t2, 2468($t0)
		sw $t2, 2484($t0)
		sw $t2, 2496($t0)
		sw $t2, 2504($t0)
		sw $t2, 2512($t0)
		sw $t2, 2520($t0)
		sw $t2, 2532($t0)
		sw $t2, 2340($t0)
		sw $t2, 2344($t0)
		sw $t2, 2352($t0)
		sw $t2, 2356($t0)
		sw $t2, 2360($t0)
		sw $t2, 2372($t0)
		sw $t2, 2384($t0)
		sw $t2, 2388($t0)
		sw $t2, 2392($t0)
		sw $t2, 2400($t0)
		sw $t2, 2404($t0)
		sw $t2, 2408($t0)
		sw $t2, 2600($t0)
		sw $t2, 2612($t0)
		sw $t2, 2624($t0)
		sw $t2, 2628($t0)
		sw $t2, 2632($t0)
		sw $t2, 2640($t0)
		sw $t2, 2644($t0)
		sw $t2, 2660($t0)
		sw $t2, 2724($t0)
		sw $t2, 2728($t0)
		sw $t2, 2740($t0)
		sw $t2, 2752($t0)
		sw $t2, 2760($t0)
		sw $t2, 2768($t0)
		sw $t2, 2776($t0)
		sw $t2, 2788($t0)
		#end of s-start
		jr $ra

PAINTWELCOMETEXT:
		lw $t2, title
		#start of Title
		sw $t2, 544($t0)
		sw $t2, 668($t0)
		sw $t2, 796($t0)
		sw $t2, 924($t0)
		sw $t2, 1052($t0)
		sw $t2, 548($t0)
		sw $t2, 560($t0)
		sw $t2, 576($t0)
		sw $t2, 580($t0)
		sw $t2, 584($t0)
		sw $t2, 680($t0)
		sw $t2, 688($t0)
		sw $t2, 708($t0)
		sw $t2, 800($t0)
		sw $t2, 804($t0)
		sw $t2, 808($t0)
		sw $t2, 816($t0)
		sw $t2, 836($t0)
		sw $t2, 848($t0)
		sw $t2, 852($t0)
		sw $t2, 856($t0)
		sw $t2, 936($t0)
		sw $t2, 944($t0)
		sw $t2, 964($t0)
		sw $t2, 1064($t0)
		sw $t2, 1072($t0)
		sw $t2, 1076($t0)
		sw $t2, 1080($t0)
		sw $t2, 1088($t0)
		sw $t2, 1092($t0)
		sw $t2, 1096($t0)
		sw $t2, 1320($t0)
		sw $t2, 1332($t0)
		sw $t2, 1340($t0)
		sw $t2, 1344($t0)
		sw $t2, 1348($t0)
		sw $t2, 1352($t0)
		sw $t2, 1360($t0)
		sw $t2, 1364($t0)
		sw $t2, 1368($t0)
		sw $t2, 1372($t0)
		sw $t2, 1448($t0)
		sw $t2, 1460($t0)
		sw $t2, 1468($t0)
		sw $t2, 1480($t0)
		sw $t2, 1488($t0)
		sw $t2, 1500($t0)
		sw $t2, 1576($t0)
		sw $t2, 1580($t0)
		sw $t2, 1584($t0)
		sw $t2, 1588($t0)
		sw $t2, 1596($t0)
		sw $t2, 1608($t0)
		sw $t2, 1616($t0)
		sw $t2, 1620($t0)
		sw $t2, 1624($t0)
		sw $t2, 1628($t0)
		sw $t2, 1704($t0)
		sw $t2, 1716($t0)
		sw $t2, 1724($t0)
		sw $t2, 1736($t0)
		sw $t2, 1744($t0)
		sw $t2, 1832($t0)
		sw $t2, 1844($t0)
		sw $t2, 1852($t0)
		sw $t2, 1856($t0)
		sw $t2, 1860($t0)
		sw $t2, 1864($t0)
		sw $t2, 1872($t0)
		#jump to PAINTSTART to display start instructions
		addi $sp, $sp, -4
		sw $ra, 0($sp) #push the current $ra onto the stack before the jal call
		jal PAINTSTART
		lw $ra, 0($sp)
		addi $sp, $sp, 4 #store the original $ra back into $ra and reset sp
		jr $ra #jump back to the main method
		
DRAWPOPUP:
		#load value of current_pop_up into $a0
		lw $a0, current_pop_up
		#load counter into $a1, starting at 0
		addi $a1, $zero, 0
		#check a0 against a1 to see if they are equal, and if so, branch to the appropriate DRAWPOPUP___ method. if not, increment a1 and check again
		#each method will draw the current pop up and return back to the loop by calling jr $ra after the pop up is drawn
		#since we do not want pop ups all the time, some values of a1 will branch to NOPOPUP, which just jumps back to the loop and nothing is drawn
		lw $t0, displayAddress #just put this here since it is common to all of the draw functions
		beq $a0, $a1, NOPOPUP #0 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, NOPOPUP #1 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, NOPOPUP #2 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, NOPOPUP #3 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, NOPOPUP #4 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, NOPOPUP #5 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, WOWPOPUP #6 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, YAYPOPUP #7 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, GOPOPUP #8 case
		addi $a1, $a1, 1 #increment a1 by 1
		beq $a0, $a1, POGPOPUP #9 case
		#we do not need a jr ra here since this method will always go to another method before ending, which will return us back to the appropriate place
		
NOPOPUP:	#do not draw a pop up and just go back to the loop. We don't want too many pop ups after all!
		jr $ra
WOWPOPUP:
		#grab the current pop_up_colour and store it in $t4
		lw $t4, pop_up_colour
		#draw WOW!
		sw $t4, 684($t0)
		sw $t4, 812($t0)
		sw $t4, 700($t0)
		sw $t4, 820($t0)
		sw $t4, 828($t0)
		sw $t4, 944($t0)
		sw $t4, 952($t0)
		
		sw $t4, 708($t0)
		sw $t4, 712($t0)
		sw $t4, 716($t0)
		sw $t4, 836($t0)
		sw $t4, 844($t0)
		sw $t4, 964($t0)
		sw $t4, 968($t0)
		sw $t4, 972($t0)
		
		sw $t4, 724($t0)
		sw $t4, 740($t0)
		sw $t4, 852($t0)
		sw $t4, 860($t0)
		sw $t4, 868($t0)
		sw $t4, 984($t0)
		sw $t4, 992($t0)
		
		sw $t4, 620($t0)
		sw $t4, 748($t0)
		sw $t4, 1004($t0)
		jr $ra
YAYPOPUP:
		#grab the current pop_up_colour and store it in $t4
		lw $t4, pop_up_colour
		#draw YAY!
		sw $t4, 2228($t0)
		sw $t4, 2352($t0)
		sw $t4, 2480($t0)
		sw $t4, 2608($t0)
		sw $t4, 2484($t0)
		sw $t4, 2488($t0)
		sw $t4, 2616($t0)
		sw $t4, 2360($t0)
		
		sw $t4, 2240($t0)
		sw $t4, 2256($t0)
		sw $t4, 2372($t0)
		sw $t4, 2380($t0)
		sw $t4, 2504($t0)
		sw $t4, 2632($t0)
		
		sw $t4, 2200($t0)
		sw $t4, 2216($t0)
		sw $t4, 2332($t0)
		sw $t4, 2340($t0)
		sw $t4, 2464($t0)
		sw $t4, 2592($t0)
		
		sw $t4, 2264($t0)
		sw $t4, 2392($t0)
		sw $t4, 2648($t0)
		
		jr $ra
GOPOPUP:
		#grab the current pop_up_colour and store it in $t4
		lw $t4, pop_up_colour
		#draw GO!
		sw $t4, 136($t0)
		sw $t4, 140($t0)
		sw $t4, 260($t0)
		sw $t4, 388($t0)
		sw $t4, 516($t0)
		sw $t4, 648($t0)
		sw $t4, 652($t0)
		sw $t4, 528($t0)
		sw $t4, 400($t0)
		sw $t4, 396($t0)
		
		sw $t4, 156($t0)
		sw $t4, 160($t0)
		sw $t4, 280($t0)
		sw $t4, 292($t0)
		sw $t4, 408($t0)
		sw $t4, 536($t0)
		sw $t4, 668($t0)
		sw $t4, 672($t0)
		sw $t4, 548($t0)
		sw $t4, 420($t0)
		
		sw $t4, 172($t0)
		sw $t4, 300($t0)
		sw $t4, 428($t0)
		sw $t4, 684($t0)
		
		jr $ra
POGPOPUP:
		#grab the current pop_up_colour and store it in $t4
		lw $t4, pop_up_colour
		#draw POG
		sw $t4, 2856($t0)
		sw $t4, 2860($t0)
		sw $t4, 2864($t0)
		sw $t4, 2984($t0)
		sw $t4, 2996($t0)
		sw $t4, 3112($t0)
		sw $t4, 3116($t0)
		sw $t4, 3120($t0)
		sw $t4, 3240($t0)
		sw $t4, 3368($t0)
		
		sw $t4, 2880($t0)
		sw $t4, 2884($t0)
		sw $t4, 3004($t0)
		sw $t4, 3016($t0)
		sw $t4, 3132($t0)
		sw $t4, 3144($t0)
		sw $t4, 3260($t0)
		sw $t4, 3272($t0)
		sw $t4, 3392($t0)
		sw $t4, 3396($t0)
		
		sw $t4, 2900($t0)
		sw $t4, 2904($t0)
		sw $t4, 3024($t0)
		sw $t4, 3152($t0)
		sw $t4, 3280($t0)
		sw $t4, 3412($t0)
		sw $t4, 3416($t0)
		sw $t4, 3292($t0)
		sw $t4, 3164($t0)
		sw $t4, 3160($t0)
		
		sw $t4, 2916($t0)
		sw $t4, 3044($t0)
		sw $t4, 3172($t0)
		sw $t4, 3428($t0)
		jr $ra
		
GenerateRandomPopUp:
		#A function that generates a random input and uses it to decide which message to display on screen
		li $v0, 42
		li $a0, 0 
		li $a1, 10 #random number from 0 to 9
		syscall
		#a random number between 0 and 9 is now stored in a0
		#this function will be called everytime a platform is hit, 
		#and that will then set a random message to display until it is called again (on another platform hit)
		sw $a0, current_pop_up
		#generate a random colour for the pop up
		li $v0, 42
		li $a0, 0 
		li $a1, 3 #random number from 0 to 3
		syscall
		addi $a2, $zero, 0 #set a2 to 0 for a counter
		beq $a0, $a2, pop_up_colour_purple #0 case
		addi $a2, $a2, 1
		beq $a0, $a2, pop_up_colour_red #1 case
		addi $a2, $a2, 1
		beq $a0, $a2, pop_up_colour_orange #2 case
		jr $ra #go back to doodlerJump

pop_up_colour_purple: 
		lw $t7, purple_colour
		sw $t7, pop_up_colour
		jr $ra #go back to doodlerJump

pop_up_colour_red: 
		lw $t7, red_colour
		sw $t7, pop_up_colour
		jr $ra #go back to doodlerJump
		
pop_up_colour_orange: 
		lw $t7, orange_colour
		sw $t7, pop_up_colour
		jr $ra #go back to doodlerJump
		
DRAWFIRSTLETTER:
		lw $a0, first_letter
		addi $t6, $zero, 1 #starting value of 1, which corresponds to the letter a
		#check what the first letter is
		beq $a0, $t6, draw_a
		addi $t6, $t6, 1
		beq $a0, $t6, draw_b
		addi $t6, $t6, 1
		beq $a0, $t6, draw_c
		addi $t6, $t6, 1
		beq $a0, $t6, draw_d
		addi $t6, $t6, 1
		beq $a0, $t6, draw_e
		addi $t6, $t6, 1
		beq $a0, $t6, draw_f
		addi $t6, $t6, 1
		beq $a0, $t6, draw_g
		addi $t6, $t6, 1
		beq $a0, $t6, draw_h
		addi $t6, $t6, 1
		beq $a0, $t6, draw_i
		addi $t6, $t6, 1
		beq $a0, $t6, draw_j
		addi $t6, $t6, 1
		beq $a0, $t6, draw_k
		addi $t6, $t6, 1
		beq $a0, $t6, draw_l
		addi $t6, $t6, 1
		beq $a0, $t6, draw_m
		addi $t6, $t6, 1
		beq $a0, $t6, draw_n
		addi $t6, $t6, 1
		beq $a0, $t6, draw_o
		addi $t6, $t6, 1
		beq $a0, $t6, draw_p
		addi $t6, $t6, 1
		beq $a0, $t6, draw_q
		addi $t6, $t6, 1
		beq $a0, $t6, draw_r
		addi $t6, $t6, 1
		beq $a0, $t6, draw_s
		addi $t6, $t6, 1
		beq $a0, $t6, draw_t
		addi $t6, $t6, 1
		beq $a0, $t6, draw_u
		addi $t6, $t6, 1
		beq $a0, $t6, draw_v
		addi $t6, $t6, 1
		beq $a0, $t6, draw_w
		addi $t6, $t6, 1
		beq $a0, $t6, draw_x
		addi $t6, $t6, 1
		beq $a0, $t6, draw_y
		addi $t6, $t6, 1
		beq $a0, $t6, draw_z
		
DRAWSECONDLETTER:
		lw $a0, second_letter
		addi $t6, $zero, 1 #starting value of 1, which corresponds to the letter a
		#check what the first letter is
		beq $a0, $t6, draw_a
		addi $t6, $t6, 1
		beq $a0, $t6, draw_b
		addi $t6, $t6, 1
		beq $a0, $t6, draw_c
		addi $t6, $t6, 1
		beq $a0, $t6, draw_d
		addi $t6, $t6, 1
		beq $a0, $t6, draw_e
		addi $t6, $t6, 1
		beq $a0, $t6, draw_f
		addi $t6, $t6, 1
		beq $a0, $t6, draw_g
		addi $t6, $t6, 1
		beq $a0, $t6, draw_h
		addi $t6, $t6, 1
		beq $a0, $t6, draw_i
		addi $t6, $t6, 1
		beq $a0, $t6, draw_j
		addi $t6, $t6, 1
		beq $a0, $t6, draw_k
		addi $t6, $t6, 1
		beq $a0, $t6, draw_l
		addi $t6, $t6, 1
		beq $a0, $t6, draw_m
		addi $t6, $t6, 1
		beq $a0, $t6, draw_n
		addi $t6, $t6, 1
		beq $a0, $t6, draw_o
		addi $t6, $t6, 1
		beq $a0, $t6, draw_p
		addi $t6, $t6, 1
		beq $a0, $t6, draw_q
		addi $t6, $t6, 1
		beq $a0, $t6, draw_r
		addi $t6, $t6, 1
		beq $a0, $t6, draw_s
		addi $t6, $t6, 1
		beq $a0, $t6, draw_t
		addi $t6, $t6, 1
		beq $a0, $t6, draw_u
		addi $t6, $t6, 1
		beq $a0, $t6, draw_v
		addi $t6, $t6, 1
		beq $a0, $t6, draw_w
		addi $t6, $t6, 1
		beq $a0, $t6, draw_x
		addi $t6, $t6, 1
		beq $a0, $t6, draw_y
		addi $t6, $t6, 1
		beq $a0, $t6, draw_z
		
DRAWTHIRDLETTER:
		lw $a0, third_letter
		addi $t6, $zero, 1 #starting value of 1, which corresponds to the letter a
		#check what the first letter is
		beq $a0, $t6, draw_a
		addi $t6, $t6, 1
		beq $a0, $t6, draw_b
		addi $t6, $t6, 1
		beq $a0, $t6, draw_c
		addi $t6, $t6, 1
		beq $a0, $t6, draw_d
		addi $t6, $t6, 1
		beq $a0, $t6, draw_e
		addi $t6, $t6, 1
		beq $a0, $t6, draw_f
		addi $t6, $t6, 1
		beq $a0, $t6, draw_g
		addi $t6, $t6, 1
		beq $a0, $t6, draw_h
		addi $t6, $t6, 1
		beq $a0, $t6, draw_i
		addi $t6, $t6, 1
		beq $a0, $t6, draw_j
		addi $t6, $t6, 1
		beq $a0, $t6, draw_k
		addi $t6, $t6, 1
		beq $a0, $t6, draw_l
		addi $t6, $t6, 1
		beq $a0, $t6, draw_m
		addi $t6, $t6, 1
		beq $a0, $t6, draw_n
		addi $t6, $t6, 1
		beq $a0, $t6, draw_o
		addi $t6, $t6, 1
		beq $a0, $t6, draw_p
		addi $t6, $t6, 1
		beq $a0, $t6, draw_q
		addi $t6, $t6, 1
		beq $a0, $t6, draw_r
		addi $t6, $t6, 1
		beq $a0, $t6, draw_s
		addi $t6, $t6, 1
		beq $a0, $t6, draw_t
		addi $t6, $t6, 1
		beq $a0, $t6, draw_u
		addi $t6, $t6, 1
		beq $a0, $t6, draw_v
		addi $t6, $t6, 1
		beq $a0, $t6, draw_w
		addi $t6, $t6, 1
		beq $a0, $t6, draw_x
		addi $t6, $t6, 1
		beq $a0, $t6, draw_y
		addi $t6, $t6, 1
		beq $a0, $t6, draw_z
		
DRAWFOURTHLETTER:
		lw $a0, fourth_letter
		addi $t6, $zero, 1 #starting value of 1, which corresponds to the letter a
		#check what the first letter is
		beq $a0, $t6, draw_a
		addi $t6, $t6, 1
		beq $a0, $t6, draw_b
		addi $t6, $t6, 1
		beq $a0, $t6, draw_c
		addi $t6, $t6, 1
		beq $a0, $t6, draw_d
		addi $t6, $t6, 1
		beq $a0, $t6, draw_e
		addi $t6, $t6, 1
		beq $a0, $t6, draw_f
		addi $t6, $t6, 1
		beq $a0, $t6, draw_g
		addi $t6, $t6, 1
		beq $a0, $t6, draw_h
		addi $t6, $t6, 1
		beq $a0, $t6, draw_i
		addi $t6, $t6, 1
		beq $a0, $t6, draw_j
		addi $t6, $t6, 1
		beq $a0, $t6, draw_k
		addi $t6, $t6, 1
		beq $a0, $t6, draw_l
		addi $t6, $t6, 1
		beq $a0, $t6, draw_m
		addi $t6, $t6, 1
		beq $a0, $t6, draw_n
		addi $t6, $t6, 1
		beq $a0, $t6, draw_o
		addi $t6, $t6, 1
		beq $a0, $t6, draw_p
		addi $t6, $t6, 1
		beq $a0, $t6, draw_q
		addi $t6, $t6, 1
		beq $a0, $t6, draw_r
		addi $t6, $t6, 1
		beq $a0, $t6, draw_s
		addi $t6, $t6, 1
		beq $a0, $t6, draw_t
		addi $t6, $t6, 1
		beq $a0, $t6, draw_u
		addi $t6, $t6, 1
		beq $a0, $t6, draw_v
		addi $t6, $t6, 1
		beq $a0, $t6, draw_w
		addi $t6, $t6, 1
		beq $a0, $t6, draw_x
		addi $t6, $t6, 1
		beq $a0, $t6, draw_y
		addi $t6, $t6, 1
		beq $a0, $t6, draw_z
		
draw_a:
		sw $t3, 4($t0)
		sw $t3, 128($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 264($t0)
		sw $t3, 384($t0)
		sw $t3, 392($t0)
		jr $ra
draw_b:
		sw $t3, 0($t0)
		sw $t3, 128($t0)
		sw $t3, 132($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 264($t0)
		sw $t3, 384($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra
draw_c:
		sw $t3, 0($t0)
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 128($t0)
		sw $t3, 256($t0)
		sw $t3, 384($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra
draw_d:
		sw $t3, 8($t0)
		sw $t3, 128($t0)
		sw $t3, 132($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 264($t0)
		sw $t3, 384($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra
draw_e:
		sw $t3, 0($t0)
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 128($t0)
		sw $t3, 512($t0)
		sw $t3, 516($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 520($t0)
		sw $t3, 384($t0)
		jr $ra
draw_f:
		sw $t3, 0($t0)
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 128($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 384($t0)
		jr $ra
draw_g:
		sw $t3, 0($t0)
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 128($t0)
		sw $t3, 512($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 264($t0)
		sw $t3, 516($t0)
		sw $t3, 520($t0)
		sw $t3, 392($t0)
		jr $ra
draw_h:
		sw $t3, 0($t0)
		sw $t3, 128($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 264($t0)
		sw $t3, 384($t0)
		sw $t3, 392($t0)
		jr $ra
draw_i:
		sw $t3, 8($t0)
		sw $t3, 264($t0)
		sw $t3, 392($t0)
		jr $ra
draw_j:
		#t0 holds the starting address
		#t3 holds the colour
		sw $t3, 8($t0)
		sw $t3, 264($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra #after drawing each letter, jump back to draw the next one or finish if this is the fourth letter

draw_k:
		sw $t3, 0($t0)
		sw $t3, 128($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 384($t0)
		sw $t3, 392($t0)
		jr $ra
draw_l:
		sw $t3, 0($t0)
		sw $t3, 128($t0)
		sw $t3, 256($t0)
		sw $t3, 384($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra
draw_m:
		sw $t3, 252($t0)
		sw $t3, 268($t0)
		sw $t3, 380($t0)
		sw $t3, 128($t0)
		sw $t3, 396($t0)
		sw $t3, 136($t0)
		sw $t3, 260($t0)
		jr $ra
draw_n:
		sw $t3, 128($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 264($t0)
		sw $t3, 384($t0)
		sw $t3, 392($t0)
		jr $ra
draw_o:
		sw $t3, 128($t0)
		sw $t3, 132($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 264($t0)
		sw $t3, 384($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra
draw_p:
		sw $t3, 0($t0)
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 128($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 264($t0)
		sw $t3, 384($t0)
		jr $ra
draw_q:
		sw $t3, 0($t0)
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 128($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 264($t0)
		sw $t3, 392($t0)
		jr $ra
draw_r:
		sw $t3, 0($t0)
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 128($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 260($t0)
		sw $t3, 384($t0)
		sw $t3, 392($t0)
		jr $ra
draw_s:
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 132($t0)
		sw $t3, 264($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra
draw_t:	
		sw $t3, 0($t0)
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 132($t0)
		sw $t3, 260($t0)
		sw $t3, 388($t0)
		jr $ra
draw_u:
		sw $t3, 128($t0)
		sw $t3, 136($t0)
		sw $t3, 256($t0)
		sw $t3, 264($t0)
		sw $t3, 384($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra
draw_v:
		sw $t3, 124($t0)
		sw $t3, 140($t0)
		sw $t3, 256($t0)
		sw $t3, 264($t0)
		sw $t3, 388($t0)
		jr $ra
draw_w:
		sw $t3, 124($t0)
		sw $t3, 140($t0)
		sw $t3, 252($t0)
		sw $t3, 268($t0)
		sw $t3, 260($t0)
		sw $t3, 384($t0)
		sw $t3, 392($t0)
		jr $ra
draw_x:
		sw $t3, 128($t0)
		sw $t3, 136($t0)
		sw $t3, 260($t0)
		sw $t3, 384($t0)
		sw $t3, 392($t0)
		jr $ra
draw_y:
		sw $t3, 0($t0)
		sw $t3, 8($t0)
		sw $t3, 132($t0)
		sw $t3, 260($t0)
		sw $t3, 388($t0)
		jr $ra
draw_z:
		sw $t3, 4($t0)
		sw $t3, 8($t0)
		sw $t3, 136($t0)
		sw $t3, 260($t0)
		sw $t3, 388($t0)
		sw $t3, 392($t0)
		jr $ra
			
CHECKFAIL:	#a function to check if the sprite has fallen off the bottom of the screen
		lw $a0, doodler_YPos #load a0 with the doodlers YPos
		lw $a1, bottomBarrier #load a1 with the bottomBarrier
		beq $a0, $a1, GAMEOVER #go to game over if equal, meaning that the user has lost the game
		jr $ra #if not equal, go back to the caller
		
GAMEOVER: 	#a function that displays the gameover is over
		#paint the sky for the gameOver screen
		lw $t0, displayAddress # $t0 stores the base address for display. PERSONAL CONVENTION...THIS WILL ALWAYS BE TRUE
		lw $t1, sky # $t1 stores the background colour code
		lw $t4, bottomRightAddress # $t4 stores the last address for display
		jal SKY #draw the sky
		jal DRAWGAMEOVER #draw game over screen
		lw $t2, platform #load th eclour of $t2 for the PAINTSTART function
		jal PAINTSTART #paint the start again to tell the player that they may try again
		lw $t0, offsetLowerAddress
		jal DRAWSCOREONES	#move game over down for this to be set, or else it overlaps...optional.
		lw $t0, lowerAddress
		jal DRAWSCORETENS
		lw $t3, letter #letter colour
		jal DRAWFIRSTLETTER #draw the player name with lower address as the starting value t0
		lw $t0, offsetLowerAddress
		jal DRAWSECONDLETTER
		lw $t0, offsetLowerAddress2
		jal DRAWTHIRDLETTER
		lw $t0, offsetLowerAddress3
		jal DRAWFOURTHLETTER
		j main2 #jump back to main 2, which waits for a user input of s to start again
