    org $1000

*-------------------------------------------------------
*Known bugs
*-------------------------------------------------------
*Temporary visual overload of the player stats does not affect actual values
*Some messages just get a random d inserted in them here and there I have no clue why
*If the player would be skilled enough he could exceed the max bounds of the variables but that invloves conquering more than 10 castles

*-------------------------------------------------------
*Validation values to be used, modify as needed
*-------------------------------------------------------
exit                    EQU 0      used to exit assembly program
min_horses              EQU 1      min number of horses you must have or the else the game will be over
oats_per_gold           EQU 20     the amount of oats you get per gold coin
soldier_cost            EQU 20     the gold cost of one soldier
horse_cost              EQU 20     the gold cost of one horse
stable_boy_cost         EQU 10     the gold coft of one stable boy
starting_gold           EQU 300    the gold the player recives at the start of the game
min_input_value         EQU 0      the minimum number you can enter when you are buying/spending resources
max_input_value         EQU 100    the maximum number you can enter when you are buying/spending resources 
soldier_chance_high     EQU 20     the chance that the soldier might die while attacking(high)
soldier_chance_medium   EQU 15     the chance that the soldier might die while attacking(medium)
soldier_chance_low      EQU 10     the chance that the soldier might die while attacking(low)
horse_chance_high       EQU 25     the chance that the horse might die while attacking(high)
horse_chance_medium     EQU 20     the chance that the horse might die while attacking(medium)
horse_chance_low        EQU 15     the chance that the horse might die while attacking(low)
plunder_chance          EQU 25     the chance the soldiers plunder some resources while plundering
plunder_gold_range      EQU 45     the range of the gold that can be plundered
plunder_feed_range      EQU 100    the range of the feed that can be plundered
defender_chance_low     EQU 25     the chance that the defender might die while defending(low)
defender_chance_high    EQU 50     the chance that the defender might die while defending(high)
distance_multiplier     EQU 50     multiplier used on genrated distance to get nice value for travel cost
oats_per_fifty_km       EQU 100    the amount of oats used by the horses per 50 kilometers of travel
oats_per_siege_day      EQU 50     the amount of feed consumed by horses per day during the siege
bonus_gold_for_castle   EQU 500    the gold recived for conquering a castle 
score_for_castle        EQU 1000   the default score recived for taking over a castle

*Start of Game
start:
    move.w  #starting_gold,money    put starting gold into players gold
    move.w  #1,difficulty_level     we set the difficulty level to level 1
    clr.w   horses_stored           set horses stored to 0
    clr.w   feed_stored             set feed stored to 0 
    clr.w   stable_boys_stored      set stable boys stored to 0
    clr.w   soldiers_stored         set soldiers stored to 0
    clr.w   journey_cost            set the journey cost to 0
    clr.w   score                   sets the score of the player to 0
    lea     $4000,A3                assign address A3 to that memory location
    
    bsr     welcome         branch to the welcome subroutine
    bsr     game            branch to the game subroutine
    jmp     start           
*Game loop
    org     $3000           the rest of the program is to be located from 3000 onwards

*-------------------------------------------------------
*----------------Generate Castle North------------------
*-------------------------------------------------------
generate_castle_north:
    move.w  #5,random_number_max        max number of defenders that can be generated
    bsr     random_number_gen
    move.w  random_number,D4            the genrated number of defenders
    mulu    difficulty_level,D4         defender increasesd by the difficulty level
    move.w  D4,castle_defenders_north   
    move.w  #25,random_number_max       max number of defence that can be generated  
    bsr     random_number_gen           
    move.w  random_number,D4
    mulu    difficulty_level,D4
    move.w  D4,castle_defence_north
    move.w  #3,random_number_max        max number for ditance that can be generated
    bsr     random_number_gen
    move.w  random_number,D4
    mulu    #distance_multiplier,D4     generated distance by the distance multiplier to get nice distances eg 50 km 
    move.w  D4,castle_distance_north
    rts
*-------------------------------------------------------
*----------------Generate Castle East-------------------
*-------------------------------------------------------
generate_castle_east:
*Same as genrate castle north but for east direction
    move.w  #5,random_number_max
    bsr     random_number_gen
    move.w  random_number,D4
    mulu    difficulty_level,D4
    move.w  D4,castle_defenders_east
    move.w  #25,random_number_max
    bsr     random_number_gen
    move.w  random_number,D4
    mulu    difficulty_level,D4
    move.w  D4,castle_defence_east
    move.w  #3,random_number_max
    bsr     random_number_gen
    move.w  random_number,D4
    mulu    #distance_multiplier,D4
    move.w  D4,castle_distance_east
    rts
*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------
game:
    bsr     generate_castle_north   branch out to genrate caste north subroutine
    bsr     generate_castle_east    branch out to genrate caste east subroutine
    bsr     market                  branch out to market subroutine
    bsr     castle_siege_intro      branch out to castle intro subroutine
    jmp     game                    back to the top of game with level being in one higher
    rts                             return from game: subroutine
          
end:
    simhalt

*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------
welcome:
    bsr     endl            branch to endl subroutine
    lea     welcome_msg,A1  assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    bsr     endl            branch to endl subroutine
    move.b  #23,D0          move literal 23 to DO
    move.l  #100,D1         delay amount
    trap    #15 
    rts                     return from welcome: subroutine

*-------------------------------------------------------
*------------------Castle Siege Routine-----------------
*-------------------------------------------------------
castle_siege_intro:
*Only used the player enters the castle siege routine
    cmp     #0,horses_stored                checks if player left behind all his horses
    beq     replay          
    cmp     #0,soldiers_stored              checks if player left behind all his knights 
    beq     replay
    move.w  #1,siege_current_day            starts day one of siege
castle_siege_day:
*Castle information
    clr     total_plundered_feed
    clr     total_plundered_gold
    clr     soldiers_killed
    clr     horses_killed
    clr     defenders_killed
    clr     defence_destroyed
    bsr     clear_screen
    bsr     player_stats
    bsr     decorate
    lea     castle_siege_day_msg,A1
    move.w  siege_current_day,D1
    move.b  #17,D0      
    trap    #15                              show the current day of the siege
    bsr     endl
    lea     castle_defence_msg,A1
    move.w  castle_defence_left,D1
    move.b  #17,D0
    trap    #15                              show the remianing defence left
    bsr     endl
    lea     castle_defenders_msg,A1
    move.w  castle_defenders_left,D1
    move.b  #17,D0
    trap    #15                              show the remaining defenders left
    bsr     decorate
castle_siege_paths:
*Possible actions
    lea     castle_paths_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp     #1,D1
    beq     castle_siege_charge
    cmp     #2,D1
    beq     castle_siege_flank
    cmp     #3,D1
    beq     castle_siege_plunder
castle_siege_path_invalid:
*Player did not choose any of the avaiable options
    lea     error_msg,A1            load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    jmp     castle_siege_paths
castle_siege_charge:
*Player wants to charge at the castle
    bsr     clear_screen
    bsr     player_stats
    lea     castle_charge_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp     #min_input_value,D1
    beq     castle_siege_day
    blt     castle_siege_boundry_error
    cmp     #max_input_value,D1
    bgt     castle_siege_boundry_error
    cmp     soldiers_stored,D1
    bgt     castle_siege_not_enough_knights
    cmp     horses_stored,D1
    bgt     castle_siege_not_enough_horses
    move.w  D1,units_attacking
    bsr     charge_loop
    jmp     castle_siege_loss_gain    
castle_siege_flank:
*Player wants to flank the castle dont know how that works but sure
    bsr     clear_screen
    bsr     player_stats
    lea     castle_flank_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp     #min_input_value,D1
    beq     castle_siege_day
    blt     castle_siege_boundry_error
    cmp     #max_input_value,D1
    bgt     castle_siege_boundry_error
    cmp     soldiers_stored,D1
    bgt     castle_siege_not_enough_knights
    cmp     horses_stored,D1
    bgt     castle_siege_not_enough_horses
    move.w  D1,units_attacking
    bsr     flank_loop
    jmp     castle_siege_loss_gain     
castle_siege_plunder:
*Player wants to plunder nearby villages to sustain his resources
    bsr     clear_screen
    bsr     player_stats
    lea     castle_plunder_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp     #min_input_value,D1
    beq     castle_siege_day
    blt     castle_siege_boundry_error
    cmp     #max_input_value,D1
    bgt     castle_siege_boundry_error
    cmp     soldiers_stored,D1
    bgt     castle_siege_not_enough_knights
    cmp     horses_stored,D1
    bgt     castle_siege_not_enough_horses
    move.w  D1,units_attacking
    bsr     plunder_loop
    jmp     castle_siege_loss_gain    
castle_siege_victory:
*Player has succesfuly conquered the castle
    bsr     clear_screen
    bsr     decorate
    lea     castle_victory_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    move.b  #23,D0                  move literal 23 to DO
    move.l  #300,D1                 delay amount
    trap    #15
    move.w  #bonus_gold_for_castle,D4
    mulu    difficulty_level,D4
    add.w   D4,money
    move.w  score_for_castle,D4
    divu    siege_current_day,D4
    add.w   D4,score      
    add.w   #1,difficulty_level     increases the difficult level for next castle
    rts
castle_siege_loss_gain:
*The resources the player has gained/lost
    bsr     clear_screen
    bsr     decorate
    move.w  horses_killed,D4
    cmp     horses_stored,D4
    bge     replay
    sub.w   D4,horses_stored
    lea     killed_horses_msg,A1
    move.w  horses_killed,D1
    move.b  #17,D0
    trap    #15                     Messege for how many horses player lost
    bsr     endl
    move.w  soldiers_killed,D4
    cmp     soldiers_stored,D4
    bge     replay
    sub.w   D4,soldiers_stored
    lea     killed_soldiers_msg,A1
    move.w  soldiers_killed,D1
    move.b  #17,D0
    trap    #15                      Messege for how many soldiers player lost
    move.w  total_plundered_feed,D4
    add.w   D4,feed_stored
    lea     feed_gained_msg,A1
    move.w  total_plundered_feed,D1
    move.b  #17,D0
    trap    #15                      Messege for how much feed the player plundered
    move.w  horses_stored,D4
    mulu.w  #oats_per_siege_day,D4   Calucaltes the total feed cost for all the horses
    cmp     feed_stored,D4
    bge     replay
    sub.w   D4,feed_stored
    lea     feed_lost_msg,A1
    move.w  D4,D1
    move.b  #17,D0
    trap    #15                      Messege for how much feed the player lost
    move.w  total_plundered_gold,D4
    add.w   D4,money
    lea     gold_gained_msg,A1
    move.w  total_plundered_gold,D1
    move.b  #17,D0
    trap    #15                      Messege for how much gold the player gained
    move.w  defenders_killed,D4
    cmp     castle_defenders_left,D4
    bge     castle_siege_victory
    sub.w   D4,castle_defenders_left
    lea     killed_defenders_msg,A1
    move.w  soldiers_killed,D1
    move.b  #17,D0
    trap    #15                      Messege for how many defenders the player killed
    move.w  defence_destroyed,D4
    cmp     castle_defence_left,D4
    bge     castle_siege_victory
    sub.w   D4,castle_defence_left
    lea     defence_destroyed_msg,A1
    move.w  defence_destroyed,D1
    move.b  #17,D0
    trap    #15                      Messege for how many defence the player destroyed
    bsr     decorate
    move.b  #23,D0                   move literal 23 to DO
    move.l  #200,D1                  delay amount
    trap    #15
    add.w   #1,siege_current_day
    jmp     castle_siege_day
castle_siege_not_enough_horses:
*The player did not have enough horses to carry out his action
    bsr     clear_screen             branch out to clear_screen subroutine
    lea     not_enough_horses_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #23,D0                   move literal 23 to DO
    move.l  #100,D1                  delay amount
    trap    #15
    jmp     castle_siege_day 
castle_siege_not_enough_knights:
*The player did not have enough knights to carry out his action
    bsr     clear_screen            branch out to clear_screen subroutine
    lea     not_enough_knights_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #23,D0                  move literal 23 to DO
    move.l  #100,D1                 delay amount
    trap    #15
    jmp     castle_siege_day 
castle_siege_boundry_error:
*The player has went outside of the bounds
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     exceeded_input_boundry
    move.b  #23,D0                  move literal 23 to DO
    move.l  #100,D1                 delay amount
    trap    #15
    jmp     castle_siege_day 

*-------------------------------------------------------
*--------------------------Market-----------------------
*-------------------------------------------------------
market:
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    bsr     decorate                branch out to decorate subroutine
    lea     market_msg,A1           load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    bsr     decorate                branch out to decorate subroutine
market_path_options:
    lea     market_path_msg,A1      load in the referance to messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #1,D1                   Compare literal 1 with conntents of D1
    beq     market_path_1           If result is they are equal go to market_path_1
    cmp     #2,D1                   Compare literal 2 with conntents of D1
    beq     market_path_2           If result is they are equal go to market_path_2
    cmp     #3,D1                   Compare literal 3 with conntents of D1
    beq     market_path_3           If result is they are equal go to market_path_3
    cmp     #4,D1                   Compare literal 4 with conntents of D1
    beq     market_path_4           If result is they are equal go to market_path_4
market_path_invalid:
    *Player did not choose any of the given options
    lea     error_msg,A1            load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    jmp     market_path_options     tells the execution program to jump to market_path_options
market_path_1:
    *Player choose to go to Farm
    jmp     farm                    tells the execution program to jump to farm
market_path_2:
    *Player choose to go to Stables
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    jmp     stables                 tells the execution program to jump to stables
market_path_3:
    *Player choose to go to Armory
    jmp     armoury                 tells the execution program to jump to armoury
market_path_4:
    *Player choose to Head Out
    jmp     head_out                tells the execution program to jump to head_out
 
*-------------------------------------------------------
*--------------------------Farm-------------------------
*-------------------------------------------------------
farm:
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    bsr     decorate                branch out to decorate subroutine
    lea     farm_msg,A1             load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    bsr     decorate                branch out to decorate subroutine
farm_buy:
    lea     farm_buy_msg,A1         load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #0,D1                   Compare literal 0 with conntents of D1
    beq     market
    blt     farm_out_of_range
    cmp     #max_input_value,D1
    bgt     farm_out_of_range
    cmp     money,D1
    ble     farm_success
farm_error:
    *player did not have enough gold to do that
    bsr     not_enough_gold
    jmp     farm_buy
farm_success:
    move.w  D1,D4
    muls.w  #oats_per_gold,D4
    add.w   D4,feed_stored
    clr     D4
    sub.w   D1,money
    jmp     farm
farm_out_of_range:
    *player entered a number out of range
    bsr     exceeded_input_boundry
    jmp     farm_buy
    
*-------------------------------------------------------
*-----------------------Stables-------------------------
*-------------------------------------------------------    
stables:
    bsr     decorate                branch out to decorate subroutine
    lea     stable_msg,A1           load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    bsr     decorate                branch out to decorate subroutine
stables_path_options:
    lea     stable_path_msg,A1      load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #1,D1                   Compare literal 1 with conntents of D1
    beq     stables_path_1          If result is they are equal go to stables_path_1 
    cmp     #2,D1                   Compare literal 2 with conntents of D1
    beq     stables_path_2          If result is they are equal go to stables_path_2 
    cmp     #3,D1                   Compare literal 3 with conntents of D1
    beq     stables_path_3          If result is they are equal go to stables_path_3 
stables_invalid_path:
    *player did not choose any of path options
    lea     error_msg,A1            load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    jmp     stables_path_options
stables_path_1:
    *player choose to buy horses
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    lea     stables_horse_msg,A1    load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #0,D1
    beq     stables
    blt     stables_out_of_range
    cmp     #max_input_value,D1
    bgt     stables_out_of_range
    move.w  D1,D4
    muls.w  #horse_cost,D4          multipliy the horse cost by the number of horses we want to buy to get total cost
    cmp     money,D4                
    bgt     stables_invalid_gold
    add.w   D1,horses_stored
    sub.w   D4,money
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    jmp     stables   
stables_path_2:
    *player choose to buy stable boys
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    lea     stables_boy_msg,A1      load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #0,D1
    beq     stables
    blt     stables_out_of_range
    cmp     #max_input_value,D1
    bgt     stables_out_of_range
    move.w  D1,D4
    muls.w  #stable_boy_cost,D4     multipliy the stable boy cost by the number of stable boys we want to buy to get total cost
    cmp     money,D4   
    bgt     stables_invalid_gold
    add.w   D1,stable_boys_stored
    sub.w   D4,money
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    jmp     stables 
stables_path_3:
    *player choose to go back to the market
    jmp     market
stables_invalid_gold: 
    *player does not have enough gold to buy
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    bsr     not_enough_gold
    jmp     stables
stables_out_of_range:
    *player entered a number out of range
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    bsr     exceeded_input_boundry
    jmp     stables
    
*-------------------------------------------------------
*-----------------------Armoury-------------------------
*-------------------------------------------------------
armoury:
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    bsr     decorate                branch out to decorate subroutine
    lea     armoury_msg,A1          load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    bsr     decorate                branch out to decorate subroutine
armoury_buy:
    lea     armoury_buy_msg,A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #0,D1                   Compare literal 0 with conntents of D1
    beq     market
    blt     armoury_out_of_range
    cmp     #max_input_value,D1
    bgt     armoury_out_of_range
    move.w  D1,D4
    muls.w  #soldier_cost,D4        multipliy the soldier cost by the number of soldiers we want to buy to get total cost
    cmp     money,D4   
    bgt     armoury_invalid_gold
    add.w   D1,soldiers_stored
    sub.w   D4,money
    jmp     armoury 
armoury_invalid_gold:
    *Player does not have enough gold to buy
    bsr     not_enough_gold
    jmp     armoury_buy
armoury_out_of_range:
    *player entered a number out of range
    bsr     exceeded_input_boundry
    jmp     armoury_buy
    
*-------------------------------------------------------
*-----------------------Head Out------------------------
*-------------------------------------------------------
head_out:
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    bsr     decorate                branch out to decorate subroutine
    lea     head_out_msg,A1         load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    bsr     decorate
head_out_paths:
    lea     head_out_paths_msg,A1   load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #1,D1                   Compare literal 1 with conntents of D1
    beq     head_out_path_1
    cmp     #2,D1                   Compare literal 2 with conntents of D1
    beq     head_out_path_2
    cmp     #3,D1                   Compare literal 3 with conntents of D1
    beq     head_out_path_3
head_out_path_invalid:
    *player did not choose any of path options
    lea     error_msg,A1            load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    jmp     head_out_paths
head_out_path_1:
    *player decided to head out north
    move.w  castle_distance_north,D4
    move.w  D4,distance_to_castle
    move.w  castle_defence_north,D5
    move.w  D5,castle_defence_left
    move.w  castle_defenders_north,D6
    move.w  D6,castle_defenders_left   
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    bsr     decorate                branch out to decorate subroutine
    lea     head_out_north_msg,A1   load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    lea     head_out_distance_msg,A1
    move.w  distance_to_castle,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    lea     head_out_defence_msg,A1
    move.w  castle_defence_left,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    lea     head_out_defenders_msg,A1
    move.w  castle_defenders_left,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    divu    #distance_multiplier,D4
    mulu    #oats_per_fifty_km,D4
    mulu    horses_stored,D4
    move.w  D4,journey_cost
    lea     head_out_cost_msg,A1
    move.w  journey_cost,D1         load in the referance to the messege into A1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     decorate
    lea     head_out_warning_msg,A1 load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    bsr     decorate                branch out to decorate subroutine
    lea     head_out_confirm_msg,A1 load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #1,D1                   Compare literal 1 with conntents of D1
    beq     journey_loss
    jmp     head_out
head_out_path_2:
    *player decided to head out east
    move.w  castle_distance_east,D4
    move.w  D4,distance_to_castle
    move.w  castle_defence_east,D5
    move.w  D5,castle_defence_left
    move.w  castle_defenders_east,D6
    move.w  D6,castle_defenders_left
    bsr     clear_screen            branch out to clear_screen subroutine
    bsr     player_stats            branch out to player_stats subroutine
    bsr     decorate                branch out to decorate subroutine
    lea     head_out_east_msg,A1    load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    lea     head_out_distance_msg,A1
    move.w  distance_to_castle,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    lea     head_out_defence_msg,A1
    move.w  castle_defence_left,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    lea     head_out_defenders_msg,A1
    move.w  castle_defenders_left,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    divu    #distance_multiplier,D4
    mulu    #oats_per_fifty_km,D4
    mulu    horses_stored,D4
    move.w  D4,journey_cost
    lea     head_out_cost_msg,A1
    move.w  journey_cost,D1         load in the referance to the messege into A1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     decorate
    lea     head_out_warning_msg,A1 load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    bsr     decorate                branch out to decorate subroutine
    lea     head_out_confirm_msg,A1 load in the referance to the messege into A1
    move.b  #14,D0                  move in literal 14 to D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1
    move.b  #4,D0                   move in literal 4 to D0
    trap    #15                     interpret value in D0, which results in reading a number from the keyboard and storing it in D1
    cmp     #1,D1                   Compare literal 1 with conntents of D1
    beq     journey_loss
    jmp     head_out
head_out_path_3:
    *player decided to head back to the market
    jmp     market

*-------------------------------------------------------
*-------------------Not Enough gold---------------------
*-------------------------------------------------------
not_enough_gold:
    lea     not_enough_gold_msg,A1      load in the referance to the messege into A1
    move.b  #14,D0                      move in literal 14 to D0
    trap    #15                         interpret value in D0, which results in displaying what is in A1
    rts                                 return from not_enough_gold subrutine
    
*-------------------------------------------------------
*------Exceeded Buying/Resource Spending Boundry--------
*-------------------------------------------------------
exceeded_input_boundry:
    clr.l   D1
    lea     error_input_boundry_msg,A1  load in the referance to the messege into A1
    move.b  #14,D0                      move in literal 14 to D0
    trap    #15                         interpret value in D0, which results in displaying what is in A1
    rts                                 return from not_enough_gold subrutine
 
*-------------------------------------------------------
*-------------------Journey Loss------------------------
*All resources lost upon takeing a journey are caculated here
*-------------------------------------------------------
journey_loss:
    move.w     journey_cost,D5          move # in journey_cost to D5
    cmp        feed_stored,D5           compare # in feed_stored with D5
    bgt        journey_recalculate_1    if D5 is greater jump to journey_recalculate_1
journey_continue_1:
    move.w     horses_stored,D5         move # in horses_stored to D5 
    cmp        stable_boys_stored,D5    compare # in stable_boys_stored with D5
    bgt        journey_recalculate_2    if D5 is greater jump to journey_recalculate_2
journey_continue_2:
    move.w     horses_stored,D5         move # in horses_stored to D5
    cmp        soldiers_stored,D5       compare # in soldiers_stored with D5
    blt        journey_recalculate_3    if D5 is smaller jump to journey_recalculate_3
journey_continue_3:
    move.w     distance_to_castle,D6    move # in distance to D6
    divu       #50,D6                   divide # in D6 by 50
    mulu       #100,D6                  multiplie # in D6 by 100
    mulu       horses_stored,D6         multiplie # in D6 by # in horses_stored to give us total feed cost for the journey
    sub.w      D6,feed_stored           subtract the feed cost from feed stored
    rts                                 return from this subroutine(Now jumps to where market was called)
journey_recalculate_1:
    move.w     feed_stored,D5           move # in feed_stored to D5 
    move.w     distance_to_castle,D6    move # in distance to D6
    divu       #50,D6                   divide # in D6 by 50
    mulu       #100,D6                  multiplie # in D6 by 100
    divu       D6,D5                    divide the # in D5 by D6
    move.w     D5,horses_stored         move the # horses we can bring to horses_stored
    jmp        journey_continue_1
journey_recalculate_2:
    move.w     stable_boys_stored,D6    move # in feed_stored to D6
    move.w     D6,horses_stored         set the number of horses we can bring to the number of stable hands we have
    jmp        journey_continue_2
journey_recalculate_3:
    move.w     D5,soldiers_stored       set the number of kinghts we can bring to the number of horses we have
    jmp        journey_continue_3
*-------------------------------------------------------
*---------------Random Number Generator-----------------
*-------------------------------------------------------
random_number_gen:
    move.b  #8,D0
    trap    #15
    and.l   #$5FFFFF,D1                 prevents the overflow for division
    divu    100,D1                      number between 0 and 99
    swap    D1
    add     #1,D1
    move.w  D1,D2
    divu    random_number_max,D2        the max for the number we want to generate
    swap    D2                          the remianing from after division ie the genrated number we want
    add     #1,D2                       
    move.w  D2,random_number
    clr.l   D1
    clr.l   D2
    rts
*-------------------------------------------------------
*-----------------Display Player Stats------------------
*Show the number of soldiers and horses the player has
*along with the feed and the money the player has
*-------------------------------------------------------
player_stats:

    bsr     decorate                branch out to decorate subroutine
    lea     your_gold_msg,A1        move your gold message to A1
    move.w  money,D1                move the money the player has into D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    lea     horses_msg,A1           move horse message to A1
    move.w  horses_stored,D1        move the amount of horses the player has into D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    lea     your_feed_msg,A1
    move.w  feed_stored,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine
    lea     your_stable_boy_msg,A1
    move.w  stable_boys_stored,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1
    bsr     endl                    branch out to endl subroutine       
    lea     your_soldier_msg,A1
    move.w  soldiers_stored,D1
    move.b  #17,D0                  move literal 17 into D0
    trap    #15                     interpret value in D0, which results in displaying what is in A1 and D1   
    bsr     decorate                branch out to decorate subroutine
    move.b  #23,D0                  move literal 23 to DO
    move.l  #100,D1                 delay amount
    trap    #15
    rts

*-------------------------------------------------------
*-----------------------Flank Loop----------------------
*-------------------------------------------------------
flank_loop:
    move.w  units_attacking,D6
    mulu.w  #1,D6
    move.w  D6,defence_destroyed
    move.w  units_attacking,D4
flank_loop_next:
    move.w  #100,random_number_max              
    bsr     random_number_gen
    move.w  random_number,D5
    cmp     #defender_chance_high,D5
    blt     flank_kill_defender
flank_loop_next2:    
    sub     #1,D4                                  decrement loop counter
    bne     charge_loop_next                       repeat until D0=0
    move.w  castle_defenders_left,D4
flank_loop_next3:
    move.w  #100,random_number_max
    bsr     random_number_gen
    move.w  random_number,D5
    cmp     #soldier_chance_medium,D5
    blt     flank_kill_horse
flank_loop_next4:
    move.w  #100,random_number_max
    bsr     random_number_gen
    move.w  random_number,D5
    cmp     #horse_chance_medium,D5
    blt     flank_kill_knight
flank_loop_next5:
    sub     #1,D4                                 decrement loop counter
    bne     flank_loop_next3                      repeat until D0=0
    rts
flank_kill_defender:
    add.w   #1,defenders_killed
    jmp     flank_loop_next2
flank_kill_knight:
    add.w   #1,soldiers_killed
    jmp     flank_loop_next5
flank_kill_horse:
    add.w   #1,horses_killed
    jmp     flank_loop_next4

*-------------------------------------------------------
*-----------------------Charge Loop---------------------
*-------------------------------------------------------
charge_loop:
    move.w  units_attacking,D6
    mulu.w  #3,D6
    move.w  D6,defence_destroyed
    move.w  units_attacking,D4
charge_loop_next:
    move.w  #100,random_number_max
    bsr     random_number_gen
    move.w  random_number,D5
    cmp     #defender_chance_low,D5
    blt     charge_kill_defender
charge_loop_next2:    
    sub     #1,D4                                  decrement loop counter
    bne     charge_loop_next                       repeat until D0=0
    move.w  castle_defenders_left,D4
charge_loop_next3:
    move.w  #100,random_number_max
    bsr     random_number_gen
    move.w  random_number,D5
    cmp     #soldier_chance_low,D5
    blt     charge_kill_horse
charge_loop_next4:
    move.w  #100,random_number_max
    bsr     random_number_gen
    move.w  random_number,D5
    cmp     #horse_chance_high,D5
    blt     charge_kill_knight
charge_loop_next5:
    sub     #1,D4                                  decrement loop counter
    bne     charge_loop_next3                      repeat until D0=0
    rts
charge_kill_defender:
    add.w   #1,defenders_killed
    jmp     charge_loop_next2
charge_kill_knight:
    add.w   #1,soldiers_killed
    jmp     charge_loop_next5
charge_kill_horse:
    add.w   #1,horses_killed
    jmp     charge_loop_next4
*-------------------------------------------------------
*----------------------Plunder Loop---------------------
*-------------------------------------------------------
plunder_loop:
    move.w  units_attacking,D4
plunder_loop_next:
    move.w  #100,random_number_max
    bsr     random_number_gen
    move.w  random_number,D5
    cmp.w   #plunder_chance,D5
    blt     plunder_resource
plunder_loop_next2:    
    sub     #1,D4                                   decrement loop counter
    bne     plunder_loop_next                       repeat until D0=0
    move.w  castle_defenders_left,D4
plunder_loop_next3:
    move.w  #100,random_number_max
    bsr     random_number_gen
    move.w  random_number,D5
    cmp.w   #soldier_chance_high,D5
    blt     plunder_kill_knight
plunder_loop_next4:
    move.w  #100,random_number_max
    bsr     random_number_gen
    move.w  random_number,D5
    cmp.w   #horse_chance_low,D5
    blt     plunder_kill_horse
plunder_loop_next5:
    sub.w   #1,D4                                   decrement loop counter
    bne     plunder_loop_next3                      repeat until D0=0
    rts
plunder_resource:
    move.w  #plunder_feed_range,random_number_max
    bsr     random_number_gen
    move.w  random_number,total_plundered_feed
    move.w  #plunder_gold_range,random_number_max
    bsr     random_number_gen
    move.w  random_number,total_plundered_gold
    jmp     plunder_loop_next2
plunder_kill_knight:
    add.w   #1,soldiers_killed
    jmp     plunder_loop_next4
plunder_kill_horse:
    add.w   #1,horses_killed
    jmp     plunder_loop_next5
    
*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------
loop:
    move.b  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     next    repeat until D0=0

*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------
decorate:
    move.b  #80, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
*-------------------------------------------------------
*------------------------Replay-------------------------
*-------------------------------------------------------
replay:
    bsr     clear_screen
    lea     score_msg,A1
    move.w  score,D1
    move.b  #17,D0
    trap    #15            Show the score of the player               
    bsr     endl
    lea     replay_msg,A1
    move.b  #14,D0
    trap    #15            Shows the replay messege
    
    move.b  #4,D0
    trap    #15

    cmp     #exit,D1
    beq     end            If SR Z register contains 1 beq => Branch Equals
    rts

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------

crlf:                    dc.b    $0D,$0A,0
error_msg:               dc.b    'Invalid input try again... '
                         dc.b    $0D,$0A,0
error_input_boundry_msg: dc.b    'The number you tried to enter is outside the bounds'
                         dc.b    $0D,$0A
                         dc.b    'The number can only be between 0 and 100'
                         dc.b    $0D,$0A
                         dc.b    'Try again with a diffrent number'
                         dc.b    $0D,$0A,0
welcome_msg:             dc.b    '************************************************************'
                         dc.b    $0D,$0A
                         dc.b    'ZorkQuest: Assault on Egreth Castle'
                         dc.b    $0D,$0A
                         dc.b    '************************************************************'
                         dc.b    $0D,$0A,0
market_msg:              dc.b    'Your are in the MARKET...'
                         dc.b    $0D,$0A
                         dc.b    'To buy feed go to the Farm'
                         dc.b    $0D,$0A
                         dc.b    'To buy horses or stable boys go to the Stables'
                         dc.b    $0D,$0A
                         dc.b    'To buy soldiers go to Armory'
                         dc.b    $0D,$0A
                         dc.b    'To attack a castle simply head out'
                         dc.b    $0D,$0A
                         dc.b    'When you are BUYING the BIGGEST number you can enter is 100',0
market_path_msg:         dc.b    'Where do you want to go to?'
                         dc.b    $0D,$0A
                         dc.b    'Farm(1), Stables(2), Armory(3), Head Out(4): ',0
farm_msg:                dc.b    'You are in the FARM...'
                         dc.b    $0D,$0A
                         dc.b    'For 1 gold you get 20 oats'
                         dc.b    $0D,$0A
                         dc.b    '1 horse eats 100 oats per 50 meters of travel'
                         dc.b    $0D,$0A
                         dc.b    '1 horse eats 50 oats per day during siege'
                         dc.b    $0D,$0A
                         dc.b    'Oats are automaticly consumed if you run out of feed you, lose'
                         dc.b    $0D,$0A
                         dc.b    'If there is not enough oats for a horse the horse will die',0
farm_buy_msg:            dc.b    'Enter the amount of gold you want to spend'
                         dc.b    $0D,$0A
                         dc.b    'Or type in 0 to return to the Market: ',0
stable_msg:              dc.b    'Your are in the STABLES'
                         dc.b    $0D,$0A
                         dc.b    'Each horse needs a stable boy to travel or it will be left behind'
                         dc.b    $0D,$0A
                         dc.b    'Each horse needs a knight to go into battle else it can not fight'
                         dc.b    $0D,$0A
                         dc.b    'Stable boys are never lost'
                         dc.b    $0D,$0A
                         dc.b    'If you dont have any horses in battlefield the game is over',0
stables_horse_msg:       dc.b    'You are in the STABLES... buying horses...'
                         dc.b    $0D,$0A
                         dc.b    'Each horse costs 20 gold'
                         dc.b    $0D,$0A
                         dc.b    'Type in how many horses you want to buy or type 0 to go back: ',0
stables_boy_msg:         dc.b    'You are in the STABLES... buying stable boys...'
                         dc.b    $0D,$0A
                         dc.b    'Each stable boy costs 10 gold'
                         dc.b    $0D,$0A
                         dc.b    'Type in how many stable boys you want to buy or type 0 to go back: ',0
stable_path_msg:         dc.b    'To buy horses(1), to buy stable boys(2), to go back to the market(3): ',0
armoury_msg:             dc.b    'You are in the ARMOURY...'
                         dc.b    $0D,$0A
                         dc.b    'Each knight needs a horse to go into battle or to travel to new mission'
                         dc.b    $0D,$0A
                         dc.b    'If a knight does not have a horse to travel the knight is lost'
                         dc.b    $0D,$0A
                         dc.b    'If you run out of knights during battle you lose'
                         dc.b    $0D,$0A
                         dc.b    'Each knight costs 20 gold',0
armoury_buy_msg:         dc.b    'Enter the amount of knights(soldiers) you want to buy'
                         dc.b    $0D,$0A
                         dc.b    'Or type in 0 to return to the market: ',0
head_out_msg:            dc.b    'You are heading out from the castle...'
                         dc.b    $0D,$0A
                         dc.b    'Once you head out you will not be able to come back here'
                         dc.b    $0D,$0A
                         dc.b    'The difficult of each castle you can head to is the same',0
head_out_paths_msg:      dc.b    'To head out North(1), to head out East(2), to go back to the Market(3): ',0
head_out_east_msg:       dc.b    'You are about to head out East...'
                         dc.b    $0D,$0A,0 
head_out_north_msg:      dc.b    'You are about to head out North...'
                         dc.b    $0D,$0A,0
head_out_distance_msg:   dc.b    'The distance to that castle is: ',0
head_out_defence_msg:    dc.b    'The defence of that castle is: ',0
head_out_defenders_msg:  dc.b    'The number of defenders the castle has is: ',0 
head_out_cost_msg:       dc.b    'The total feed cost for all your horses is: ',0
head_out_warning_msg:    dc.b    $0D,$0A
                         dc.b    'Makes sure you have enough feed and stable boys for your horses'
                         dc.b    $0D,$0A
                         dc.b    'If you head out with 0 horses or knights this will result in game over'
                         dc.b    $0D,$0A
                         dc.b    'Make sure you have enough horses for your knights',0
head_out_confirm_msg:    dc.b    'Type in 1 to confirm type in any thing else to go back: ',0
castle_siege_day_msg:    dc.b    'You are laying siege to this castle... it is day: ',0
castle_defence_msg:      dc.b    'The remaining defence of this castle is: ',0
castle_defenders_msg:    dc.b    'The number of remaining defenders in this castle is: ',0
castle_paths_msg:        dc.b    'The castle will fall if it has no more defence or defenders...'
                         dc.b    $0D,$0A
                         dc.b    'Enter 1 to carry out a charge attack (strong vs defence)'
                         dc.b    $0D,$0A
                         dc.b    'Enter 2 to carry out a flank attack (strong vs defenders)'
                         dc.b    $0D,$0A
                         dc.b    'Enter 3 to plunder the nearby area around the castle (deals no damge)'
                         dc.b    $0D,$0A
                         dc.b    'Enter your order: ',0
castle_charge_msg:       dc.b    'You are about to order your knights to charge attack...'
                         dc.b    $0D,$0A
                         dc.b    'Enter the number of knights you want to send out to battle'
                         dc.b    $0D,$0A
                         dc.b    'Or enter in 0 to go back: ',0
castle_flank_msg:        dc.b    'You are about to order your knights to flank attack...'
                         dc.b    $0D,$0A
                         dc.b    'Enter the number of knights you want to send out to battle'
                         dc.b    $0D,$0A
                         dc.b    'Or enter in 0 to go back: ',0
castle_plunder_msg:      dc.b    'You are about to order your knights to plunder the area...'
                         dc.b    $0D,$0A
                         dc.b    'This can get you extra feed and gold'
                         dc.b    $0D,$0A
                         dc.b    'Your horses and knights can still die'
                         dc.b    $0D,$0A
                         dc.b    'Enter the number of knights you want to send out to battle'
                         dc.b    $0D,$0A
                         dc.b    'Or enter in 0 to go back: ',0
not_enough_horses_msg:   dc.b    'You do not have enough horses to do that',0
not_enough_knights_msg:  dc.b    'You do not have enough knights to do that',0
killed_horses_msg:       dc.b    'Horses lost: ',0
killed_soldiers_msg:     dc.b    $0D,$0A
                         dc.b    'Knights lost: ',0
killed_defenders_msg:    dc.b    $0D,$0A
                         dc.b    'Defenders killed: ',0
defence_destroyed_msg:   dc.b    $0D,$0A
                         dc.b    'Defence destroyed: ',0
gold_gained_msg:         dc.b    $0D,$0A
                         dc.b    'Gold plundered: ',0
feed_gained_msg:         dc.b    $0D,$0A
                         dc.b    'Feed plundered: ',0   
feed_lost_msg:           dc.b    $0D,$0A
                         dc.b    'Feed consumed by horses: ',0                                
your_gold_msg:           dc.b    'Number of gold you have is: ',0
your_feed_msg:           dc.b    'Number of feed you have is: ',0
your_stable_boy_msg:     dc.b    'Number of stable boys you have is: ',0
your_soldier_msg:        dc.b    'Number of soldiers you have is: ',0
not_enough_gold_msg:     dc.b    'You do not have enough gold to do that! Try a diffrent amount...'
                         dc.b    $0D,$0A,0
castle_victory_msg:      dc.b    'You have conquered the castle: ',0
horses_msg:              dc.b    'Number of horses you have is: ',0
gameplay_msg:            dc.b    'Add Gameplay !',0
update_msg:              dc.b    'Update Gameplay !',0
draw_msg:                dc.b    'Draw Screen !',0
hit_msg:                 dc.b    'Strike!',0
miss_msg:                dc.b    'Miss!',0
loop_msg:                dc.b    '.',0
replay_msg:              dc.b    'You have been defeated during your siege'
                         dc.b    $0D,$0A
                         dc.b    'Enter 0 to quit any other number to replay: ',0
score_msg:               dc.b    'Your score is: ',0

feed_stored:            ds.w    1   the amount of feed the player has
soldiers_stored:        ds.w    1   the amount of soldiers the player has
stable_boys_stored:     ds.w    1   the amount of stable boys the player has
horses_stored:          ds.w    1   the amount of horses the player has
money:                  ds.w    1   the gold the player has
distance_to_castle:     ds.w    1   the distance to the castle the player wants to travel to
journey_cost:           ds.w    1   the feed cost for the journey for all the horses
score:                  ds.w    1   the score the player has
difficulty_level:       ds.w    1   the current difficulty level multiplier
castle_defence_left:    ds.w    1   the defence left of the castle being attacked by the player
castle_defenders_left:  ds.w    1   the defenders left in the castle being attacked by the player
siege_current_day:      ds.w    1   the current day of the siege
random_number:          ds.w    1   random number that has been generated
random_number_max:      ds.w    1   max size of the random number we want to generate
total_plundered_gold:   ds.w    1   the total gold the player has plundered today
total_plundered_feed:   ds.w    1   the total feed the player has plundered today
castle_defence_north:   ds.w    1   the amount of defence the castle in the north has
castle_defenders_north: ds.w    1   the amount of defenders the castle in the north has
castle_distance_north:  ds.w    1   the distance to the castle in the north
castle_defence_east:    ds.w    1   the amount of defence the castle in the east has
castle_defenders_east:  ds.w    1   the amount of defenders the castle in the east has
castle_distance_east:   ds.w    1   the distance to the castle in the east
units_attacking:        ds.w    1   the amount of units the player is attacking with
soldiers_killed:        ds.w    1   the number of soliders that died during todays battle
horses_killed:          ds.w    1   the number of horses that died during todays battle
defenders_killed:       ds.w    1   the amount of defenders killed during todays battle
defence_destroyed:      ds.w    1   the amount of defence destoyred during todays battle


    end start











*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
